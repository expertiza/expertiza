class PopupController < ApplicationController
  include StringOperationHelper
  include AuthorizationHelper
  ASSIGNMENT_NAME_SIMILARITY_THRESHOLD = 0.50

  def action_allowed?
    current_user_has_ta_privileges?
  end

  # this can be called from "response_report" by clicking student names from instructor end.
  def author_feedback_popup
    @response_id = params[:response_id]
    @reviewee_id = params[:reviewee_id]
    first_question_in_questionnaire = Answer.where(response_id: @response_id).first
    unless @response_id.nil? || first_question_in_questionnaire.nil?
      questionnaire_id = Question.find(first_question_in_questionnaire.question_id).questionnaire_id
      questionnaire = Questionnaire.find(questionnaire_id)
      @maxscore = questionnaire.max_question_score
      @scores = Answer.where(response_id: @response_id)
      @response = Response.find(@response_id)
      @total_percentage = @response.average_score
      @sum = @response.aggregate_questionnaire_score
      @total_possible = @response.maximum_score
    end

    @maxscore = 5 if @maxscore.nil?

    unless @response_id.nil?
      participant = Participant.find(@reviewee_id)
      @user = User.find(participant.user_id)
    end
  end

  # this can be called from "response_report" by clicking team names from instructor end.
  def team_users_popup
    @ip = session[:ip]
    @sum = 0
    @team = Team.find(params[:id])
    @assignment = Assignment.find(@team.parent_id)
    @team_users = TeamsUser.where(team_id: params[:id])

    # id2 is a response_map id
    unless params[:id2].nil?
      # E1973 - we set the reviewer id either to the student's user id or the current reviewer id
      # This results from reviewers being either assignment participants or assignment teams.
      # If the reviewer is a participant, the id is currently the id of the assignment participant.
      # However, we want their user_id. This is not possible for teams, so we just return the current id
      reviewer_id = ResponseMap.find(params[:id2]).reviewer_id
      # E2060 - we had to change this if/else clause in order to properly view reports page
      @reviewer_id = if @assignment.team_reviewing_enabled
                       reviewer_id
                     else
                       Participant.find(reviewer_id).user_id
                     end
      # get the last response in each round from response_map id
      (1..@assignment.num_review_rounds).each do |round|
        response = Response.where(map_id: params[:id2], round: round).last
        instance_variable_set('@response_round_' + round.to_s, response)
        next if response.nil?

        instance_variable_set('@response_id_round_' + round.to_s, response.id)
        instance_variable_set('@scores_round_' + round.to_s, Answer.where(response_id: response.id))
        questionnaire = Response.find(response.id).questionnaire_by_answer(instance_variable_get('@scores_round_' + round.to_s).first)
        instance_variable_set('@max_score_round_' + round.to_s, questionnaire.max_question_score ||= 5)
        total_percentage = response.average_score
        total_percentage += '%' if total_percentage.is_a? Float
        instance_variable_set('@total_percentage_round_' + round.to_s, total_percentage)
        instance_variable_set('@sum_round_' + round.to_s, response.aggregate_questionnaire_score)
        instance_variable_set('@total_possible_round_' + round.to_s, response.maximum_score)
      end
    end

    all_assignments = Assignment.where(instructor_id: session[:user].id)
    @similar_assignments = []
    all_assignments.each do |assignment|
      if string_similarity(@assignment.name, assignment.name) > ASSIGNMENT_NAME_SIMILARITY_THRESHOLD
        @similar_assignments << assignment
      end
    end
    @similar_assignments = @similar_assignments.sort_by { |sim_assignment| -sim_assignment.id }
  end

  # Views tone analysis report and heatmap
  def view_review_scores_popup
    @ip = session[:ip]
    @reviewer_id = params[:reviewer_id]
    @assignment_id = params[:assignment_id]
    @review_final_versions = ReviewResponseMap.final_versions_from_reviewer(@assignment_id, @reviewer_id)
    @reviews = []
    @mcp_service = MCPReviewService.new
    @llm_evaluation_data = prepare_llm_evaluation_data
  end

  private

  # Prepare LLM evaluation display data for all responses
  # Returns hash keyed by response_id with display information
  def prepare_llm_evaluation_data
    llm_data = {}
    return llm_data unless @review_final_versions
    
    @review_final_versions.each do |_key, version_data|
      version_data[:response_ids].each do |response_id|
        next if llm_data[response_id] # Skip if already processed
        
        raw_response = get_raw_mcp_response(response_id)
        mcp_review = extract_mcp_review_from_response(raw_response)
        status_hash = calculate_llm_status(mcp_review)
        status_hash[:raw_response] = raw_response # Include raw response for popup display
        llm_data[response_id] = status_hash
      end
    end
    
    llm_data
  end

  # Get raw MCP response (before processing)
  def get_raw_mcp_response(response_id)
    begin
      @mcp_service.get_llm_generated_score_and_feedback(response_id)
    rescue => e
      # Return error hash for debugging
      { "error" => e.message, "exception_class" => e.class.name }
    end
  end

  # Extract MCP review data from raw response
  # Handles both error responses and success responses (wrapped or unwrapped)
  # Returns nil if no data, or a hash with error info if there's an error
  def extract_mcp_review_from_response(raw_response)
    return nil unless raw_response.is_a?(Hash)
    
    # Handle error response structure: {"error": "...", "exception_class": "..."}
    if raw_response['error'].present?
      return {
        'status' => 'error',
        'error_message' => raw_response['error'],
        'exception_class' => raw_response['exception_class']
      }
    end
    
    # Handle wrapped success structure: {"success": true, "mcp": {...}}
    if raw_response['success'] && raw_response['mcp'].present?
      return raw_response['mcp']
    end
    
    # Handle direct mcp data structure (unwrapped)
    raw_response
  end

  # Calculate LLM evaluation status and return display hash
  # Returns hash with: status_text, badge_class, score, feedback, error_message, show_button, button_text, button_class, mcp_review_id, rubric_breakdown, total_score
  def calculate_llm_status(mcp_review)
    return default_not_sent_status if mcp_review.nil?

    status = mcp_review['status']
    
    # HTTP/API error - this means the request to MCP server failed
    if status == 'error' && mcp_review['error_message'].present?
      return {
        status_text: 'Request failed',
        badge_class: 'badge-danger',
        score: nil,
        feedback: nil,
        error_message: mcp_review['error_message'],
        show_button: false,
        button_text: nil,
        button_class: nil,
        mcp_review_id: nil,
        rubric_breakdown: nil,
        total_score: nil,
        can_finalize: false
      }
    end
    
    # Failed or error status - this means it was sent but processing failed
    if status == 'failed' || status == 'error'
      return {
        status_text: 'Processing failed',
        badge_class: 'badge-dark',
        score: nil,
        feedback: nil,
        error_message: mcp_review['llm_details_reasoning'] || mcp_review['error_message'],
        show_button: false,
        button_text: nil,
        button_class: nil,
        mcp_review_id: mcp_review['id'],
        rubric_breakdown: nil,
        total_score: nil,
        can_finalize: false
      }
    end
    
    # Success but not generated yet
    if mcp_review['llm_generated_feedback'].nil? && mcp_review['llm_generated_score'].nil?
      return {
        status_text: 'Not generated yet',
        badge_class: 'badge-warning',
        score: nil,
        feedback: nil,
        error_message: nil,
        show_button: false,
        button_text: nil,
        button_class: nil,
        mcp_review_id: mcp_review['id'],
        rubric_breakdown: nil,
        total_score: nil,
        can_finalize: false
      }
    end
    
    # Get score (prioritize finalized, fallback to generated)
    raw_score = mcp_review['finalized_score'] || mcp_review['llm_generated_score']
    feedback = mcp_review['finalized_feedback'] || mcp_review['llm_generated_feedback']
    
    # Get explanations from llm_details_reasoning or nested in llm_generated_output
    llm_details_reasoning = mcp_review['llm_details_reasoning']
 
    
    # Parse score JSON and calculate breakdown
    rubric_data = parse_score_json(raw_score)
    # Parse explanations from llm_details_reasoning
    explanations = parse_explanations(llm_details_reasoning)
    # Merge explanations into rubric data
    rubric_data = merge_explanations_into_rubric(rubric_data, explanations) if rubric_data
    total_score = calculate_total_score(rubric_data)
    
    # Generated but not finalized (has generated data but no finalized data)
    if mcp_review['finalized_feedback'].nil? && mcp_review['finalized_score'].nil? && 
       (mcp_review['llm_generated_feedback'].present? || mcp_review['llm_generated_score'].present?)
      return {
        status_text: 'Generated but not finalized',
        badge_class: 'badge-success',
        score: raw_score,
        feedback: feedback,
        error_message: nil,
        show_button: false,
        button_text: nil,
        button_class: nil,
        mcp_review_id: mcp_review['id'],
        rubric_breakdown: rubric_data,
        total_score: total_score,
        can_finalize: true
      }
    end
    
    # Finalized (has finalized data) - can still be edited and re-finalized
    {
      status_text: 'Finalized',
      badge_class: 'badge-success',
      score: raw_score,
      feedback: feedback,
      error_message: nil,
      show_button: false,
      button_text: nil,
      button_class: nil,
      mcp_review_id: mcp_review['id'],
      rubric_breakdown: rubric_data,
      total_score: total_score,
      can_finalize: true
    }
  end

  # Parse score JSON string into structured data
  def parse_score_json(score)
    return nil if score.nil?
    
    parsed_hash = nil
    
    # If score is already a hash, use it directly
    if score.is_a?(Hash)
      parsed_hash = score
    # If score is a string, try to parse it as JSON
    elsif score.is_a?(String)
      begin
        parsed = JSON.parse(score)
        parsed_hash = parsed if parsed.is_a?(Hash)
      rescue JSON::ParserError
        return nil
      end
    else
      return nil
    end
    
    # Normalize keys to strings and ensure nested structure is correct
    return nil unless parsed_hash.is_a?(Hash)
    
    normalized = {}
    parsed_hash.each do |key, value|
      string_key = key.to_s
      # Ensure value is a hash with 'score' and 'justification' keys
      if value.is_a?(Hash)
        normalized[string_key] = {
          'score' => value['score'] || value[:score],
          'justification' => value['justification'] || value[:justification]
        }
      end
    end
    
    normalized
  end

  # Calculate total score from rubric breakdown
  def calculate_total_score(rubric_data)
    return nil unless rubric_data.is_a?(Hash)
    
    total = 0
    rubric_data.each do |_rubric_name, rubric_info|
      next unless rubric_info.is_a?(Hash)
      
      score_value = rubric_info['score']
      # Only add numeric scores, skip "N/A" or other non-numeric values
      if score_value.is_a?(Numeric)
        total += score_value
      end
    end
    
    total > 0 ? total : nil
  end

  # Parse explanations from llm_details_reasoning
  def parse_explanations(llm_details_reasoning)
    return {} if llm_details_reasoning.nil?
    
    parsed_explanations = {}
    
    # If it's already a hash, use it directly
    if llm_details_reasoning.is_a?(Hash)
      parsed_explanations = llm_details_reasoning
    # If it's a string, try to parse it as JSON
    elsif llm_details_reasoning.is_a?(String)
      # First, try direct JSON parsing
      begin
        parsed = JSON.parse(llm_details_reasoning)
        parsed_explanations = parsed if parsed.is_a?(Hash)
      rescue JSON::ParserError
        # Try to handle escaped JSON strings (multiple levels of escaping)
        begin
          # Handle common escape patterns
          unescaped = llm_details_reasoning
          # Remove outer quotes if present
          unescaped = unescaped.gsub(/^["']|["']$/, '')
          # Unescape quotes and backslashes
          unescaped = unescaped.gsub(/\\"/, '"').gsub(/\\\\/, '\\')
          parsed = JSON.parse(unescaped)
          parsed_explanations = parsed if parsed.is_a?(Hash)
        rescue JSON::ParserError
          # Last attempt: try to extract JSON from within the string
          begin
            # Look for JSON-like structure
            if unescaped.match(/\{.*\}/)
              json_match = unescaped.match(/\{.*\}/)
              parsed = JSON.parse(json_match[0])
              parsed_explanations = parsed if parsed.is_a?(Hash)
            else
              return {}
            end
          rescue JSON::ParserError
            return {}
          end
        end
      end
    end
    
    # Normalize keys to strings
    normalized = {}
    parsed_explanations.each do |key, value|
      normalized[key.to_s] = value.to_s if value.present?
    end
    
    normalized
  end

  # Merge explanations into rubric breakdown data
  def merge_explanations_into_rubric(rubric_data, explanations)
    return rubric_data if rubric_data.nil? || explanations.empty?
    
    merged = {}
    rubric_data.each do |rubric_name, rubric_info|
      merged[rubric_name] = rubric_info.dup
      # Add explanation if available
      if explanations[rubric_name].present?
        merged[rubric_name]['explanation'] = explanations[rubric_name]
      end
    end
    
    merged
  end

  # Default status when no data found
  def default_not_sent_status
    {
      status_text: 'Not sent for processing yet',
      badge_class: 'badge-secondary',
      score: nil,
      feedback: nil,
      error_message: 'No LLM evaluation data found',
      show_button: false,
      button_text: nil,
      button_class: nil,
      mcp_review_id: nil,
      rubric_breakdown: nil,
      total_score: nil,
      can_finalize: false
    }
  end

  public

  # Finalize the LLM evaluation score and feedback
  # POST /popup/finalize_llm_evaluation
  def finalize_llm_evaluation
    response_id = params[:response_id]
    mcp_review_id = params[:mcp_review_id]
    rubric_data = params[:rubric_data] || {}
    feedback = params[:feedback] || ''
    
    begin
      # Build finalized_score JSON from rubric data
      finalized_score_hash = {}
      rubric_data.each do |rubric_name, rubric_info|
        finalized_score_hash[rubric_name] = {
          'score' => rubric_info['score'],
          'justification' => rubric_info['justification']
        }
      end
      
      # Convert to JSON string
      finalized_score = finalized_score_hash.to_json
      
      # Call MCP service to finalize
      @mcp_service = MCPReviewService.new
      mcp_client = @mcp_service.instance_variable_get(:@mcp)
      
      payload = {
        finalized_score: finalized_score,
        finalized_feedback: feedback
      }
      
      result = mcp_client.finalize_review(response_id, payload)
      
      render json: { 
        success: true, 
        message: 'Score finalized successfully',
        result: result
      }, status: :ok
    rescue => e
      Rails.logger.error("Error finalizing LLM evaluation: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      render json: { 
        success: false, 
        error: e.message 
      }, status: :unprocessable_entity
    end
  end

  # this can be called from "response_report" by clicking reviewer names from instructor end.
  def reviewer_details_popup
    @userid = Participant.find(params[:id]).user_id
    @user = User.find(@userid)
    @id = params[:assignment_id]
  end

  # this can be called from "response_report" by clicking reviewer names from instructor end.
  def self_review_popup
    @response_id = params[:response_id]
    @user_fullname = params[:user_fullname]
    unless @response_id.nil?
      first_question_in_questionnaire = Answer.where(response_id: @response_id).first.question_id
      questionnaire_id = Question.find(first_question_in_questionnaire).questionnaire_id
      questionnaire = Questionnaire.find(questionnaire_id)
      @maxscore = questionnaire.max_question_score
      @scores = Answer.where(response_id: @response_id)
      @response = Response.find(@response_id)
      @total_percentage = @response.average_score
      @sum = @response.aggregate_questionnaire_score
      @total_possible = @response.maximum_score
    end
    @maxscore = 5 if @maxscore.nil?
  end
end
