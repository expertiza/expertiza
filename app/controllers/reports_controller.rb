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
  # ReviewGrades are then recalculated from formative scores only for the reviewer-facing summary.
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

  SINGLE_ROUND_NORMALIZATION_FACTOR = 2.0

  # Calculate and save ReviewGrade for each reviewer using formative InstructorReviewScores only.
  # Summative scores remain stored on InstructorReviewScore for backend/staff use, but they are not
  # included in the assigned reviewer grade/comment shown on the response report page.
  # Aggregates across ALL response_maps for each reviewer (not per-map).
  def save_review_grades_from_instructor_scores(assignment)
    all_response_ids = Response.latest_submitted_review_response_ids_for_assignment(assignment.id)
    return if all_response_ids.empty?

    # Build response_id -> reviewer_id map (batch)
    response_rows = Response.where(id: all_response_ids).pluck(:id, :map_id, :round)
    response_to_map = {}
    response_to_round = {}
    response_rows.each do |response_id, map_id, round|
      response_to_map[response_id] = map_id
      response_to_round[response_id] = round.presence || 1
    end
    map_to_reviewer = ResponseMap.where(id: response_to_map.values.uniq).pluck(:id, :reviewer_id).to_h
    round_count = [assignment.num_review_rounds, response_to_round.values.compact.max || 1].max
    round_count = 1 if round_count.zero?

    # Group InstructorReviewScores by participant
    participant_scores = {}
    InstructorReviewScore.where(response_id: all_response_ids).each do |irs|
      reviewer_id = map_to_reviewer[response_to_map[irs.response_id]]
      round = response_to_round[irs.response_id] || 1
      next if reviewer_id.nil?
      next if irs.score_for_formative.nil?

      participant_scores[reviewer_id] ||= {
        reviews: Hash.new { |review_scores, map_id| review_scores[map_id] = {} }
      }

      participant_scores[reviewer_id][:reviews][response_to_map[irs.response_id]][round] = irs.score_for_formative
    end

    participant_scores.each do |participant_id, score_data|
      next if score_data[:reviews].empty?

      total = 0.0
      feedback_text = if round_count == 1
                        normalized_scores = score_data[:reviews].sort.map do |_map_id, round_scores|
                          score = round_scores[1] || round_scores.values.first
                          next if score.nil?

                          normalized_score = score.to_f * SINGLE_ROUND_NORMALIZATION_FACTOR
                          total += normalized_score
                          format_llm_score(normalized_score)
                        end.compact
                        next if normalized_scores.empty?

                        "Your scores are #{normalized_scores.join(', ')}"
                      else
                        review_totals = []
                        review_comments = score_data[:reviews].sort.each_with_index.map do |(_map_id, round_scores), index|
                          next if round_scores.empty?

                          review_total = round_scores.values.sum(&:to_f)
                          total += review_total
                          review_totals << format_llm_score(review_total)
                          format_review_breakdown(index, round_scores, review_total)
                        end.compact
                        next if review_comments.empty?

                        "Your scores are #{review_totals.join(', ')}\n\n#{review_comments.join("\n\n")}"
                      end

      rg = ReviewGrade.find_or_initialize_by(participant_id: participant_id)
      rg.grade_for_reviewer = total.round(2)
      rg.comment_for_reviewer = feedback_text
      rg.review_graded_at = Time.current
      rg.reviewer_id = session[:user].id
      rg.save!
    end
  end

  def format_llm_score(score)
    rounded_score = score.to_f.round(2)
    rounded_score == rounded_score.to_i ? rounded_score.to_i.to_s : rounded_score.to_s
  end

  def format_review_breakdown(index, round_scores, review_total)
    breakdown_lines = ["Review #{index + 1}"]
    round_scores.sort.each do |round, score|
      breakdown_lines << "Round #{round}: #{format_llm_score(score)}"
    end
    breakdown_lines << "Total: #{format_llm_score(review_total)}"
    breakdown_lines.join("\n")
  end
end
