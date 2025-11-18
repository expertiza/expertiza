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
  
  def llm_evaluation_report(params, session)
    assignment_id = params[:id]
    @assignment = Assignment.find(assignment_id)
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

end



