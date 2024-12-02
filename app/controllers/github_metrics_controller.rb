# Controller for handling GitHub metrics collection and display
# Manages OAuth authentication with GitHub and processes repository metrics for assignments
class GithubMetricsController < ApplicationController
  include AuthorizationHelper
  include AssignmentHelper
  include GithubMetricsHelper

  # Catch all StandardErrors and handle them with custom error handler
  rescue_from StandardError, with: :handle_error

  # Authorization check for controller actions
  # @return [Boolean] true if user has instructor privileges
  def action_allowed?
    current_user_has_instructor_privileges?
  end

  # Processes GitHub metrics for all teams in an assignment
  # Called when instructor wants to refresh GitHub data for entire assignment
  # @param id [Integer] Assignment ID from params
  def query_assignment_statistics
    @assignment = Assignment.find(params[:id])
    teams = @assignment.teams
    teams.each do |team|
      topic_identifier, topic_name, users_for_curr_team, participants = get_metrics_for_list_submissions(team)
      process_team_metrics(participants.first) unless participants.first.nil?
    end
    redirect_to controller: 'assignments', action: 'list_submissions', id: @assignment.id
  end

  # OAuth callback handler for GitHub authentication
  # Stores access token in session and processes metrics for specific team
  # @note Redirects to show action after processing
  def callback
    auth = request.env['omniauth.auth']
    session["github_access_token"] = auth.credentials.token
    process_team_metrics(session["participant_id"], session["assignment_id"])
    redirect_to action: :show, id: session["participant_id"], assignment_id: session["assignment_id"]
  end

  # Displays GitHub metrics for a specific assignment participant
  # @param id [Integer] Participant ID
  # @param assignment_id [Integer] Assignment ID
  # @raise [StandardError] if GitHub token is missing or other errors occur
  def show
    @assignment = Assignment.find(params[:assignment_id])
    @metrics = GithubMetrics.new(params[:id], params[:assignment_id], session["github_access_token"])
    @metrics.process_metrics
  rescue StandardError => e
    handle_missing_token if e.message == "GitHub access token is required"
    raise
  end

  private

  def process_team_metrics(participant_id, assignment_id = nil)
    GithubMetrics.new(participant_id, assignment_id, session["github_access_token"]).process_metrics
  end

  def handle_missing_token
    session["participant_id"] = params[:id]
    session["assignment_id"] = params[:assignment_id]
    session["github_view_type"] = "view_submissions"
    redirect_to "https://github.com/login/oauth/authorize?client_id=#{GITHUB_CONFIG['client_key']}"
  end

  def handle_error(error)
    flash[:error] = error.message
    redirect_to controller: 'assignments', action: 'list_submissions', id: @assignment.id
  end
end
