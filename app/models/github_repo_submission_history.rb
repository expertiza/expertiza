class GithubRepoSubmissionHistory < GithubSubmissionHistory
  def self.create(link, team, action)
    history_obj = GithubRepoSubmissionHistory.new
    history_obj.submitted_detail = link
    history_obj.team = team
    history_obj.action = action
  end
end
