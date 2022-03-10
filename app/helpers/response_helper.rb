module ResponseHelper
  # E-1973 - helper method to check if the current user is the reviewer
  # if the reviewer is an assignment team, we have to check if the current user is on the team
  def current_user_is_reviewer?(map, _reviewer_id)
    map.reviewer.current_user_is_reviewer? current_user.try(:id)
  end

  # sorts by sequence number
  def sort_questions(questions)
    questions.sort_by(&:seq)
  end

  # Creates a table to store total contribution for Cake question across all reviewers
  def store_total_cake_score
    @total_score = {}
    @questions.each do |question|
      next unless question.instance_of? Cake

      reviewee_id = ResponseMap.select(:reviewee_id, :type).where(id: @response.map_id.to_s).first
      total_score = question.get_total_score_for_question(reviewee_id.type, question.id, @participant.id, @assignment.id, reviewee_id.reviewee_id).to_s
      total_score = 0 if total_score.nil?
      @total_score[question.id] = total_score
    end
  end
end