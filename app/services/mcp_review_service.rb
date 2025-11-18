# app/services/mcp_review_service.rb
class MCPReviewService
  VALID_SCORE_RANGE = (0..100) # adjust if your rubric uses different scale

  def initialize(mcp_client: MCPServerClient.new)
    @mcp = mcp_client
  end

  # Sends  all review/response to the MCP server for LLM evaluation.
  # Accepts either a assignment_id (Expertiza) or a model instance.
  # Returns MCP server response (parsed JSON).
  
  def send_peer_review(assignment_id: nil)
    raise ArgumentError, "assignment_id is required" if assignment_id.blank?
    response_ids = find_response_ids(assignment_id)
    raise ActiveRecord::RecordNotFound, "response ids not found" unless response_ids
    for response_id in response_ids do
      response = find_response(response_id)
      @mcp.send_review(response)
    end
    return true
  end

  # Fetch LLM-generated result from MCP server (by MCP review ID)
  # Returns parsed JSON (expects llm_generated_score, llm_generated_feedback, ...).
  def get_llm_generated_score_and_feedback(mcp_review_id)
    result = @mcp.get_review(mcp_review_id)
    validate_mcp_result!(result)
    result
  end

  # Persist finalized grade/feedback to Expertiza DB.
  # target_model_sym can be :review_grades, :review_scores, :review_of_review_scores (defaults to :review_scores)
  # Returns the created ActiveRecord object (or raises).
  def publish_or_finalize_grade(mcp_review_id:, finalized_score:, finalized_feedback:, target_model_sym: :review_scores, actor: nil)
    # fetch MCP review to map to expertiza response_id if not provided separately
    mcp_review = @mcp.get_review(mcp_review_id)
    validate_mcp_result!(mcp_review, require_llm_fields: false) # allow finalize without llm fields

    response_id = mcp_review['response_id_of_expertiza'] || mcp_review['response_id'] || mcp_review['response_id_expertiza']
    raise "response_id not present in MCP record; include response_id when finalizing" if response_id.blank?

    unless VALID_SCORE_RANGE.include?(finalized_score.to_i)
      raise ArgumentError, "finalized_score must be within #{VALID_SCORE_RANGE}"
    end

    model = model_for_target(target_model_sym)
    raise "Unknown target model #{target_model_sym}" unless model

    # Try to create a record using a few common column names. Update as per your schema.
    attrs = {
      response_id: response_id,
      score: finalized_score,
      comments: finalized_feedback,
      created_at: Time.current,
      updated_at: Time.current
    }

    # If the model has different column names, adapt here (or provide exact model name).
    record = model.create!(attrs)
    # Optionally update the MCP record with finalized data
    begin
      @mcp.finalize_review(mcp_review_id, { finalized_score: finalized_score, finalized_feedback: finalized_feedback })
    rescue => e
      Rails.logger.warn("Failed to notify MCP of finalize: #{e.message}")
      # Not fatal for local save; MCP should be updated but we don't want finalize to completely fail
    end

    record
  end

  private



  # Very small validation example. Expand according to your rules.
  def validate_mcp_result!(result, require_llm_fields: true)
    raise "Invalid MCP result: blank" if result.blank? || !result.is_a?(Hash)
    if require_llm_fields
      unless result['llm_generated_score'] && result['llm_generated_feedback']
        raise "MCP result missing llm_generated_score or llm_generated_feedback"
      end
      score = result['llm_generated_score'].to_i
      unless VALID_SCORE_RANGE.include?(score)
        raise "LLM-generated score #{score} outside allowed range #{VALID_SCORE_RANGE}"
      end
    end
    true
  end

  # Find response ids from specific assignment
  def find_response_ids(assignment_id)
    return nil if assignment_id.blank? 
    Response.where(map_id: ResponseMap.where(reviewed_object_id: assignment_id, type: 'ReviewResponseMap').pluck(:id)).pluck(:id)
  end

  # Find the response and the questionnaire and scores from the response_id
  def find_response(response_id)
    return nil if response_id.blank?

    response = Response.find(response_id)
    questionnaire = get_questionnaire_from_response(response)
    
    build_response_data(response, questionnaire)
  end

  # Build the complete response data hash
  def build_response_data(response, questionnaire)
    {
      response_id_of_expertiza: response.id,
      course_name: response.map.assignment.course.name,
      assignment_name: response.map.assignment.name,
      round: response.round,
      scores: build_current_round_scores(response, questionnaire),
      additional_comment: response.additional_comment,
      previous_round_review: build_previous_round_review(response, questionnaire)
    }
  end

  # Get questionnaire from response (same logic as `questionnaire_from_response`)
  def get_questionnaire_from_response(response)
    first_score = response.scores.first
    response.questionnaire_by_answer(first_score)
  end

  # Build scores for current round
  def build_current_round_scores(response, questionnaire)
    questions = questionnaire.questions.order(:seq)
    scores_by_q_id = response.scores.index_by(&:question_id)

    filter_header_questions(questions).map do |question|
      score = scores_by_q_id[question.id]
      format_score_data(question, score, questionnaire)
    end
  end

  # Build previous round review data
  def build_previous_round_review(response, questionnaire)
    prev_response = Response.where(map_id: response.map_id, round: response.round - 1).first
    
    return "No previous round review" if prev_response.nil?

    {
      scores: build_previous_round_scores(prev_response, questionnaire),
      additional_comment: prev_response.additional_comment
    }
  end

  # Build scores for previous round
  def build_previous_round_scores(prev_response, questionnaire)
    filtered_scores = prev_response.scores.reject do |score|
      score.question.type == 'SectionHeader' || score.question.type == 'QuestionHeader'
    end

    filtered_scores.map do |score|
      format_score_data(score.question, score, questionnaire)
    end
  end

  # Format individual score data into hash
  def format_score_data(question, score, questionnaire)
    {
      question: question.txt,
      type: question.type,
      max_points: calculate_max_points(question, questionnaire),
      awarded_points: score&.answer,
      comments: score&.comments
    }
  end

  # Calculate max points for a question
  def calculate_max_points(question, questionnaire)
    if question.type == 'Checkbox'
      1
    elsif question.weight.present?
      question.weight * questionnaire.max_question_score
    else
      "Not Applicable"
    end
  end

  # Filter out header question types
  def filter_header_questions(questions)
    questions.reject { |q| q.type == 'SectionHeader' || q.type == 'QuestionHeader' }
  end

  def model_for_target(sym)
    mapping = {
      review_grades: 'ReviewGrade',
      review_scores: 'ReviewScore',
      review_of_review_scores: 'ReviewOfReviewScore'
    }
    klass_name = mapping[sym.to_sym]
    klass_name.safe_constantize
  end
end
