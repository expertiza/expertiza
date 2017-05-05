# E1731 changes: New LocalDbCalc class used to store and retrieve total scores from db
class LocalDbCalc
  def self.compute_total_score(assignment)
    total = 0
    teams = AssignmentTeam.where(parent_id: assignment.id)
    teams.each do |team|
      response_maps = team.review_mappings
      response_maps.each do |map|
        record = LocalDbScore.where(response_map_id: map.map_id).last
        next if record.nil?
        score = record[:score]
        total += score unless score.nil?
      end
    end
    total
  end

  # Calculates and stores scores in local_db_scores table for each response map for each round
  def self.store_total_scores(assignment)
    fetch_contributors_and_rounds(assignment)
    (1..@rounds).each do |round|
      fetch_questions(assignment, round)
      @contributors.each do |contributor|
        next unless contributor
        maps = ReviewResponseMap.where(reviewee_id: contributor.id)
        maps.each do |map|
          next if map.response.empty?
          @response = Response.where(map_id: map.map_id).last
          if map.type.eql?('ReviewResponseMap')
            # If its ReviewResponseMap then only consider those response which are submitted.
            @response = nil unless @response.is_submitted
          end
          score = Answer.get_total_score(response: [@response], questions: @questions)
          if score == -1
            LocalDbScore.create(score_type: "ReviewLocalDBScore", round: round, score: 0, response_map_id: map.map_id)
          else
            LocalDbScore.create(score_type: "ReviewLocalDBScore", round: round, score: score, response_map_id: map.map_id)
          end
        end
      end
    end
    assignment.update_attribute(:local_scores_stored, true)
  end
end

private

def fetch_contributors_and_rounds(assignment)
  @contributors = assignment.contributors
  @rounds = assignment.rounds_of_reviews
end

def fetch_questions(assignment, round)
  review_questionnaire_id = assignment.review_questionnaire_id(round)
  @questions = Question.where(questionnaire_id: review_questionnaire_id)
end
