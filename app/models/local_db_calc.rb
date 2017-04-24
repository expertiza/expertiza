# E1731 changes: New file. Not yet finished with the implementation
module LocalDbCalc
  def self.compute_total_score(assignment, scores)
    total = 0

    teams = AssignmentTeam.where(parent_id: assignment.id)
    teams.each { |team|
      response_maps = team.review_mappings
      response_maps.each { |map| total += LocalDbScore.where(response_map_id: map.id).pluck(:score) }
    }

    total
  end

  # To be modified
  def self.store_total_scores(assignment)
    contributors = assignment.contributors
    if assignment.varying_rubrics_by_round?
      rounds = assignment.rounds_of_reviews
      (1..rounds).each do |round|
        review_questionnaire_id = assignment.review_questionnaire_id(round)
        questions = Question.where(questionnaire_id: review_questionnaire_id)
        contributors.each do |contributor|
          if contributor
            @array_sort = []
            @sort_to = []

            maps = ReviewResponseMap.where(reviewee_id: contributor.id)
            maps.each do |map|
              next if map.response.empty?

              @all_responses = Response.where(map_id: map.map_id).last

              if map.type.eql?('ReviewResponseMap')
                # If its ReviewResponseMap then only consider those response which are submitted.
                @array_sort << @all_responses if @all_responses.is_submitted
              else
                @array_sort << @all_responses
              end

              # sort all versions in descending order and get the latest one.
              @sort_to = @array_sort.sort

              score = Answer.get_total_score(response: [@sort_to[0]], questions: questions)
              if score == -1
                LocalDbScore.create(review_type: "ReviewLocalDBScore", round: round, score: 0, response_map_id: map.map_id)
              else
                LocalDbScore.create(review_type: "ReviewLocalDBScore", round: round, score: score, response_map_id: map.map_id)
              end

              @array_sort.clear
              @sort_to.clear
            end
          end
        end
      end
    end
  end
end
