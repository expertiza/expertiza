# app/services/mcp_review_service.rb
class MCPReviewService
  VALID_SCORE_RANGE = (0..100) # adjust if your rubric uses different scale

  def initialize(mcp_client: MCPServerClient.new)
    @mcp = mcp_client
  end

  # Sends a review/response to the MCP server for LLM evaluation.
  # Accepts either a response_id (Expertiza) or a model instance.
  # Returns MCP server response (parsed JSON).
  def send_peer_review(response_id: nil)
    response = find_response(response_id)
    return response
    raise ActiveRecord::RecordNotFound, "response not found" unless response

    payload = build_mcp_payload_for(response).merge(extra_metadata)
    @mcp.send_review(payload)
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

  # Build a JSON payload expected by MCP. Adapt to the exact MCP schema you implement.
  def build_mcp_payload_for(response)
    {
      request_id: SecureRandom.uuid,
      response_id: response.try(:id) || response.try(:response_id) || response['id'],
      review_text: response.try(:review_text) || response.try(:comments) || response.try(:body) || response.to_s,
      author_id: response.try(:user_id) || response.try(:author_id),
      course_id: response.try(:course_id),
      metadata: {
        model: 'expertiza',
        sent_at: Time.current.iso8601
      }
    }
  end

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

  # Try various likely model names used in Expertiza. Adapt to your actual models.
  def find_response(response_id)
    return nil if response_id.blank?

    response = Response.find(response_id)
    map       = response.map

    # same logic as `questionnaire_from_response`
    first_score   = response.scores.first
    questionnaire = response.questionnaire_by_answer(first_score)

    questions      = questionnaire.questions.order(:seq) # like sort_questions
    scores_by_q_id = response.scores.index_by(&:question_id)

    {
      response: {
        id: response.id,
        map_id: response.map_id,
        round: response.round,
        additional_comment: response.additional_comment,
        is_submitted: response.is_submitted,
        visibility: response.visibility
      },
      questionnaire: {
        id: questionnaire.id,
        name: questionnaire.name,
        min_score: questionnaire.min_question_score,
        max_score: questionnaire.max_question_score
      },
      questions: questions.map do |q|
        score = scores_by_q_id[q.id]

        {
          id: q.id,
          text: q.txt,
          seq: q.seq,
          weight: q.weight,
          answer: score&.answer,
          comments: score&.comments
        }
      end
    }
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
