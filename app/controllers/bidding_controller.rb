# BiddingController handles the bidding process for team assignments within an assignment.
# It allows users with the appropriate privileges to automatically assign teams based on
# bidding data and to calculate summaries of the bidding information.
#
# This controller includes authorization checks to ensure that only users with
# teaching assistant privileges can perform certain actions.
class BiddingController < ApplicationController
  include AuthorizationHelper

  # Give permission to run the bid to appropriate roles
  def action_allowed?
    current_user_has_ta_privileges?
  end

  # This method sends a request to a web service that uses k-means and students' bidding data
  # to build teams automatically.
  # The webservice tries to create teams with sizes close to the max team size
  # allowed by the assignment by potentially combining existing smaller teams
  # that have similar bidding info/priorities associated with the assignment's sign-up topics.
  #
  # rubocop:disable Metrics/AbcSize  
  # GET /bidding/:id/auto_assign_teams
  def auto_assign_teams
    @assignment = Assignment.find(params[:id])
    service = TeamAssignmentService.new(params[:id])

    begin
      service.assign_teams_to_topics
      info_message = "Team assignments for '#{@assignment.name}' were completed successfully."
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, info_message)
      flash[:success] = info_message
    rescue ActiveRecord::RecordNotFound => e
      error_message = "Assignment with ID #{params[:id]} not found: #{e.message}"
      ExpertizaLogger.error.LoggerMessage.new(controller_name, session[:user].name, error_message)
      flash[:error] = error_message
    rescue StandardError => e
      error_message = "Team assignments failed for assignment ID #{@assignment_id}: #{e.message}"
      ExpertizaLogger.error.LoggerMessage.new(controller_name, session[:user].name, error_message)
      flash[:error] = error_message
    end

    redirect_to controller: 'tree_display', action: 'list'
  end

  # GET /bidding/:id/calculate_bidding_summary
  def calculate_bidding_summary
    service = BiddingSummaryService.new
    result = service.bidding_summary(params[:id])

    @assignment = result[:assignment]
    @topic_data = result[:topic_data]

    respond_to do |format|
      format.html
    end
  end
  # rubocop:enable Metrics/AbcSize
end
