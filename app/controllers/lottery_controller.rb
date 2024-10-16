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
  
  def intelligent_assignment
    assignment = Assignment.find(params[:id])
    service = IntelligentAssignmentService.new(params[:id])

    begin
      service.perform_intelligent_assignment
      infoMessage = "Intelligent assignment for '#{assignment.name}' was completed successfully."
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, infoMessage)
      flash[:success] = 
    rescue StandardError => e
      errorMessage = "Intelligent assignment failed for assignment ID #{assignment_id}: #{e.message}"
      ExpertizaLogger.error.LoggerMessage.new(ontroller_name, ession[:user].name, errorMessage)
      flash[:error] = errorMessage
    end

    redirect_to controller: 'tree_display', action: 'list'
  end
  # rubocop:enable Metrics/AbcSize
end