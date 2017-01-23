class GithubPullRequestSubmissionHistory < GithubSubmissionHistory
  def self.create(link, team, action)
    history_obj = GithubPullRequestSubmissionHistory.new
    history_obj.submitted_detail = link
    history_obj.team = team
    history_obj.action = action
    return history_obj
  end

  def get_submitted_at_time(link)
    uri = URI(link)
    link_path = uri.path
    git_user_details = link_path.split("/")
    github = Github.new
    a = github.pulls.get git_user_details[1], git_user_details[2], git_user_details[4]
    return a.updated_at
  end
end
