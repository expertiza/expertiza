class GithubPullRequestSubmissionHistory < GithubSubmissionHistory
  def self.create(link, team, action)
    history_obj = GithubPullRequestSubmissionHistory.new
    history_obj.submitted_detail = link
    history_obj.team = team
    history_obj.action = action
  end
end
