class MCPTeammateReviewService
  def initialize(mcp_client: MCPServerClient.new)
    @mcp = mcp_client
  end

  def send_teammate_reviews(assignment_id:)
    raise ArgumentError, 'assignment_id is required' if assignment_id.blank?

    assignment = Assignment.find(assignment_id)
    teammate_reviews = latest_teammate_responses(assignment_id).map do |response_id|
      build_teammate_review_item(response_id)
    end.compact

    payload = {
      course_id: assignment.course_id,
      course_name: assignment.course&.name,
      assignment_id: assignment.id,
      assignment_name: assignment.name,
      generated_at: Time.current,
      teammate_reviews: teammate_reviews
    }

    @mcp.send_teammate_assignment(payload)
  end

  def get_student_summary(assignment_participant:)
    assignment = assignment_participant.assignment
    @mcp.get_teammate_student_summary(
      assignment.course_id,
      assignment.id,
      assignment_participant.user_id
    )
  end

  private

  def latest_teammate_responses(assignment_id)
    Response.latest_submitted_teammate_review_response_ids_for_assignment(assignment_id)
  end

  def build_teammate_review_item(response_id)
    response = Response.find(response_id)
    questionnaire = get_questionnaire_from_response(response)
    map = response.map
    reviewee = AssignmentParticipant.find_by(id: map.reviewee_id)
    reviewer = AssignmentParticipant.find_by(id: map.reviewer_id)
    return nil if reviewee.nil? || reviewer.nil?

    {
      response_map_id: map.id,
      response_id: response.id,
      round: response.round || 1,
      reviewee_student_id: reviewee.user_id,
      reviewee_display_name: reviewee.user&.fullname,
      reviewer_student_id: reviewer.user_id,
      reviewer_display_name: reviewer.user&.fullname,
      additional_comments: response.additional_comment,
      responses: build_response_items(response, questionnaire)
    }
  end

  def get_questionnaire_from_response(response)
    first_score = response.scores.first
    response.questionnaire_by_answer(first_score)
  end

  def build_response_items(response, questionnaire)
    questions = filter_out_header_questions(questionnaire.questions.order(:seq))
    scores_by_q_id = response.scores.index_by(&:question_id)

    questions.map do |question|
      score = scores_by_q_id[question.id]
      {
        question_id: question.id,
        question_seq: question.seq,
        question: question.txt,
        score: score&.answer,
        answer: score&.comments,
        question_type: question.type,
        max_points_possible: max_points_possible_for_question(question, questionnaire)
      }
    end
  end

  def max_points_possible_for_question(question, questionnaire)
    if question.type == 'Checkbox'
      1
    elsif question.weight.present?
      question.weight * questionnaire.max_question_score
    else
      'Not Applicable'
    end
  end

  def filter_out_header_questions(questions)
    questions.reject { |question| question.type == 'SectionHeader' || question.type == 'QuestionHeader' }
  end
end
