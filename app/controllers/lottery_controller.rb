class LotteryController < ApplicationController
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
  # TODO: Add route
  def auto_assign_teams
    assignment = Assignment.find(params[:id]) 
    service = TeamAssignmentService.new(params[:id])

    begin
      service.assign_teams_to_topics
      infoMessage = "Team assignments for '#{assignment.name}' was completed successfully."
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, infoMessage)
      flash[:success] = infoMessage
    rescue StandardError => e #TODO: Additional catches to catch specific errors such as Assignment not being found with param ID.
      errorMessage = "Team assignments failed for assignment ID #{assignment_id}: #{e.message}"
      ExpertizaLogger.error.LoggerMessage.new(controller_name, session[:user].name, errorMessage)
      flash[:error] = errorMessage 
    end

    redirect_to controller: 'tree_display', action: 'list'
  end
  # rubocop:enable Metrics/AbcSize
end