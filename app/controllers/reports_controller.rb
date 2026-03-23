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

  # Fetches finalized LLM-generated formative/summative evaluation data for peer reviews from the MCP server,
  # and saves them to InstructorReviewScore for each peer review in each round.
  # ReviewGrades then use the summative scores to derive the reviewer grade summary.
  def get_llm_evaluation
    @assignment = Assignment.find(params[:id])
    mcp_client = MCPServerClient.new
    response_ids = Response.latest_submitted_review_response_ids_for_assignment(@assignment.id)
    saved = 0
    errors = []
    # Iterate over each peer review in each round
    # and fetch the LLM-generated evaluation payload from the MCP server.
    # Save the formative/summative scores and feedback to InstructorReviewScore for each peer review.
    Array(response_ids).each do |response_id|
      begin
        data = mcp_client.get_finalized_review(response_id)
        score_for_summative = data['summative_feedback_score'] || data['score_for_summative'] || data['total_finalized_score']
        score_for_formative = data['formative_feedback_score'] || data['score_for_formative']
        feedback_for_summative = data['feedback_of_summative_feedback'] || data['feedback_for_summative']
        feedback_for_formative = data['feedback_of_formative_feedback'] || data['feedback_for_formative'] || data['student_feedback']
        next if score_for_summative.nil? && score_for_formative.nil? &&
                feedback_for_summative.nil? && feedback_for_formative.nil?
        record = InstructorReviewScore.find_or_initialize_by(response_id: response_id)
        record.score_for_summative = score_for_summative
        record.score_for_formative = score_for_formative
        record.feedback_for_summative = feedback_for_summative
        record.feedback_for_formative = feedback_for_formative
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

  # Calculate and save ReviewGrade for each reviewer using both summative and formative InstructorReviewScores.
  # grade_for_reviewer = sum of per-review averages, where each review average is
  # (summative score + formative score) / 2.
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
      next if irs.score_for_summative.nil? || irs.score_for_formative.nil?

      participant_scores[reviewer_id] ||= {
        summative_scores: [],
        formative_scores: [],
        combined_scores: []
      }

      participant_scores[reviewer_id][:summative_scores] << irs.score_for_summative
      participant_scores[reviewer_id][:formative_scores] << irs.score_for_formative
      participant_scores[reviewer_id][:combined_scores] << ((irs.score_for_summative + irs.score_for_formative) / 2.0)
    end

    participant_scores.each do |participant_id, score_data|
      next if score_data[:combined_scores].empty?

      total = score_data[:combined_scores].sum
      count = score_data[:combined_scores].size
      total_summative = score_data[:summative_scores].sum
      total_formative = score_data[:formative_scores].sum
      feedback_text = "#{count} review#{'s' if count != 1} | " \
                      "Summative scores: #{score_data[:summative_scores].join(', ')} | " \
                      "Total summative score: #{total_summative.round(2)} | " \
                      "Formative scores: #{score_data[:formative_scores].join(', ')} | " \
                      "Total formative score: #{total_formative.round(2)} | " \
                      "Combined per-review scores: #{score_data[:combined_scores].map { |score| score.round(2) }.join(', ')}"

      rg = ReviewGrade.find_or_initialize_by(participant_id: participant_id)
      rg.grade_for_reviewer = total
      rg.comment_for_reviewer = feedback_text
      rg.review_graded_at = Time.current
      rg.reviewer_id = session[:user].id
      rg.save!
    end
  end
end
