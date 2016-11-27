class WikipediaSubmissionHistory < LinkSubmissionHistory
  def self.create(link, team, action)
    history_obj = WikipediaSubmissionHistory.new
    history_obj.submission_detail = link
    history_obj.team = team
    history_obj.action = action
    return history_obj
  end
end
