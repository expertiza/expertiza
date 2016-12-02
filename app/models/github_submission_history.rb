class GithubSubmissionHistory < LinkSubmissionHistory
  def self.create(link, team, action)
    if link.include? "pull"
      history_obj = GithubPullRequestSubmissionHistory.create(link, team, action)
    else
      history_obj = GithubRepoSubmissionHistory.create(link, team, action)
    return history_obj
  end
  end
end
