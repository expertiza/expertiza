class AssignmentStats
  attr_accessor :rounds, :name

  def initialize(assignment_id)
    @name = Assignment.find(assignment_id).name
    # These represent rounds
    aqs_with_round = AssignmentQuestionnaire.where(assignment_id: assignment_id).reject {|q| q.used_in_round.nil? }
    aqs_with_round.sort_by!(&:used_in_round) # { |q| q.used_in_round }
    # This hash maps question IDs to their zero-indexed positions within their questionnaire
    question_id_index_hash = {}
    aqs_with_round.each do |q|
      q.question_ids_in_order.each_with_index {|value, index| question_id_index_hash[value] = index }
    end
    # question_id_index_hash
    # This hash maps rounds to criteria to scores, max_scores and min_scores
    scores_hash = {}
    review_response_maps = ReviewResponseMap.where(reviewed_object_id: assignment_id)
    review_response_maps.each do |review_response_map|
      submitted_responses = review_response_map.response.reject {|r| !r.is_submitted }
      submitted_responses.each do |response|
        criteria_hash = scores_hash[response.round]
        if criteria_hash.nil?
          criteria_hash = {}
          scores_hash[response.round] = criteria_hash
        end
        answers = response.scores.reject {|s| s.answer.nil? }
        answers.each do |answer|
          criterion_hash = criteria_hash[answer.question_id]
          if criterion_hash.nil?
            criterion_hash = {}
            criteria_hash[answer.question_id] = criterion_hash
          end
          c_scores = criterion_hash[:scores]
          if c_scores.nil?
            c_scores = []
            criterion_hash[:scores] = c_scores
          end
          c_scores << answer.answer
          if criterion_hash[:max_score].nil?
            question = Question.find(answer.question_id)
            criterion_hash[:question_id] = answer.question_id
            criterion_hash[:max_score] = question.max_score
            criterion_hash[:min_score] = question.min_score
          end
        end
      end
    end
    @rounds = []
    scores_hash.each_value do |criteria_hash|
      @rounds << ReviewRoundStats.new(criteria_hash, question_id_index_hash)
    end
  end

  def number_of_rounds
    @rounds.length
  end
end
