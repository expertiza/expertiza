class ReportsController < ApplicationController
  include AuthorizationHelper

  autocomplete :user, :name
  helper :submitted_content
  include ReportFormatterHelper

  # reports are allowed to be viewed by  only by TA, instructor and administrator
  def action_allowed?
    current_user_has_ta_privileges?
  end

  def response_report
    # ACS Removed the if condition(and corresponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    @type = params.key?(:report) ? params[:report][:type] : 'basic'
    # From the ReportFormatterHelper module
    send(@type.underscore, params, session)
    @user_pastebins = UserPastebin.get_current_user_pastebin current_user
  end

  # function to export specific headers to the csv
  def self.export_details_fields(detail_options)
    fields = []
    fields << 'Name' if detail_options['name'] == 'true'
    fields << 'UnityID' if detail_options['unity_id'] == 'true'
    fields << 'EmailID' if detail_options['email'] == 'true'
    fields << 'Grade' if detail_options['grade'] == 'true'
    fields << 'Comment' if detail_options['comment'] == 'true'
    fields
  end

  # function to check for detail_options and return the correct csv
  def self.export_details(csv, _parent_id, detail_options)
    return csv unless detail_options
  end
  
  # Renders LLM evaluation report view for an assignment (Send to LLM / Get LLM Evaluation UI).
  def llm_evaluation_report(params, session)
    @id = params[:id]
    @assignment = Assignment.find(@id)
  end

  def send_to_llm
    @assignment = Assignment.find(params[:id])
    
    begin
      service = MCPReviewService.new
      service.send_peer_review(assignment_id: @assignment.id)
      
      # Update the flag to indicate assignment has been sent to LLM
      @assignment.update(is_sent_to_llm_for_processing: true)
      
      flash[:success] = "Assignment successfully sent to LLM for processing."
    rescue => e
      Rails.logger.error "Error sending assignment to LLM: #{e.message}"
      flash[:error] = "Error sending assignment to LLM: #{e.message}"
    end
    
    redirect_to action: 'response_report', id: @assignment.id, report: { type: 'LLMEvaluationReport' }
  end

  # Fetches finalized LLM-generated evaluation scores and feedback for peer reviews from the MCP server,
  # and saves them to InstructorReviewScore for each peer review in each round.
  # ReviewGrades then use InstructorReviewScore to derive the "Score and Feedback" for each reviewer.
  def get_llm_evaluation
    @assignment = Assignment.find(params[:id])
    mcp_client = MCPServerClient.new
    response_ids = Response.latest_submitted_review_response_ids_for_assignment(@assignment.id)
    saved = 0
    errors = []
    # Iterate over each peer review in each round
    # and fetch the LLM-generated evaluation scores and feedback from the MCP server.
    # Save the scores and feedback to InstructorReviewScore for each peer review.
    Array(response_ids).each do |response_id|
      begin
        data = mcp_client.get_finalized_review(response_id)
        score = data['total_finalized_score']
        feedback = data['student_feedback']
        next if score.nil?
        record = InstructorReviewScore.find_or_initialize_by(response_id: response_id)
        record.score = score
        record.feedback = feedback
        record.save!
        saved += 1
      rescue => e
        errors << "Response #{response_id}: #{e.message}"
      end
    end
    if saved > 0
      save_review_grades_from_instructor_scores(@assignment)
      flash[:success] = "Saved LLM evaluation for #{saved} peer review(s) and calculated reviewer grades."
    end
    if errors.any?
      flash[:error] = "Some fetches failed: #{errors.first(3).join('; ')}#{errors.size > 3 ? '...' : ''}"
    end
    if saved.zero? && errors.empty?
      flash[:info] = 'No finalized LLM evaluations are available yet for this assignment.'
    end
    redirect_to action: 'response_report', id: @assignment.id, report: { type: 'LLMEvaluationReport' }
  end

  private

  # Calculate and save ReviewGrade for each reviewer based on their InstructorReviewScores.
  # grade_for_reviewer = total (sum) of all scores; comment = "N reviews | Scores: x, y, z"
  # Aggregates across ALL response_maps for each reviewer (not per-map).
  def save_review_grades_from_instructor_scores(assignment)
    all_response_ids = Response.latest_submitted_review_response_ids_for_assignment(assignment.id)
    return if all_response_ids.empty?

    # Build response_id -> reviewer_id map (batch)
    response_to_map = Response.where(id: all_response_ids).pluck(:id, :map_id).to_h
    map_to_reviewer = ResponseMap.where(id: response_to_map.values.uniq).pluck(:id, :reviewer_id).to_h

    # Group InstructorReviewScores by participant
    participant_scores = {}
    InstructorReviewScore.where(response_id: all_response_ids).each do |irs|
      reviewer_id = map_to_reviewer[response_to_map[irs.response_id]]
      next if reviewer_id.nil?
      participant_scores[reviewer_id] ||= []
      participant_scores[reviewer_id] << irs.score
    end

    participant_scores.each do |participant_id, score_values|
      next if score_values.empty?

      total = score_values.sum
      count = score_values.size
      feedback_text = "#{count} review#{'s' if count != 1} | Scores: #{score_values.join(', ')}"

      rg = ReviewGrade.find_or_initialize_by(participant_id: participant_id)
      rg.grade_for_reviewer = total
      rg.comment_for_reviewer = feedback_text
      rg.review_graded_at = Time.current
      rg.reviewer_id = session[:user].id
      rg.save!
    end
  end
end
