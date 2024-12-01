class GithubMetricsController < ApplicationController
  include AuthorizationHelper
  include AssignmentHelper
  include GithubMetricsHelper

  rescue_from StandardError, with: :handle_error

  def action_allowed?
    current_user_has_instructor_privileges?
  end

  def query_assignment_statistics
    @assignment = Assignment.find(params[:id])
    teams = @assignment.teams
    teams.each do |team|
      topic_identifier, topic_name, users_for_curr_team, participants = get_data_for_list_submissions(team)
      process_team_metrics(participants.first) unless participants.first.nil?
    end
    redirect_to controller: 'assignments', action: 'list_submissions', id: @assignment.id
  end

  def callback
    auth = request.env['omniauth.auth']
    session["github_access_token"] = auth.credentials.token
    process_team_metrics(session["participant_id"], session["assignment_id"])
    redirect_to action: :show, id: session["participant_id"], assignment_id: session["assignment_id"]
  end

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
