class GithubMetricsController < ApplicationController
    include AuthorizationHelper
    include AssignmentHelper
    include GithubMetricsHelper
  
    def action_allowed?
      current_user_has_instructor_privileges?
    end
  
    def query_assignment_statistics
      @assignment = Assignment.find(params[:id])
      teams = @assignment.teams
      teams.each do |team|
        topic_identifier, topic_name, users_for_curr_team, participants = get_data_for_list_submissions(team)
        GithubMetrics.new(participants.first.id).process_metrics unless participants.first.nil?
      end
      redirect_to controller: 'assignments', action: 'list_submissions', id: @assignment.id
    end
  
    def callback
      auth = request.env['omniauth.auth']
      session["github_access_token"] = auth.credentials.token
      GithubMetrics.new(session["participant_id"], session["assignment_id"]).process_metrics
    end
  
    def show
      @metrics = GithubMetrics.new(params[:id], params[:assignment_id])
      @metrics.process_metrics
    end
  end