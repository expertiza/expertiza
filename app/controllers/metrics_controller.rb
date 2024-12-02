class MetricsController < ApplicationController
  include AuthorizationHelper
  include AssignmentHelper
  include GithubMetricsHelper

  def action_allowed?
    current_user_has_instructor_privileges?
  end

  # This populates the database fields required to display user contributions in the view_team for grades heatgrid. 
  # It executes a query for all link submissions for an entire assignment, and runs the necessary queries to enable the 
  # "Github metrics" link on the list_assignments page.
  # def query_assignment_statistics
  #   @assignment = Assignment.find(params[:id])
  #   teams = @assignment.teams
  #   teams.each do |team|
  #     topic_identifier, topic_name, users_for_curr_team, participants = get_metrics_for_list_submissions(team)
  #     github_metrics_for_submission(participants.first.id) unless participants.first.nil?
  #   end
  #   redirect_to controller: 'assignments', action: 'list_submissions', id: @assignment.id
  # end
end
