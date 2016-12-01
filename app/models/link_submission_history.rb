class LinkSubmissionHistory < SubmissionHistory

  def self.create(link, team, action)
    # lets assume link of type http://docs.google.com  or   http://wiki.expertiza.ncsu.edu  or http://github.com/goeltanmay/
    if link.include? "docs.google.com"
      history_obj = GoogledocSubmissionHistory.create(link, team, action)
    elsif link.include? "wiki.expertiza.ncsu.edu"
      history_obj = WikipediaSubmissionHistory.create(link, team, action)
    elsif link.include? "github.com"
      history_obj = GithubSubmissionHistory.create(link, team, action)
    else
      # some random link has been given
      history_obj = LinkSubmissionHistory.new
      history_obj.team = team
      history_obj.submitted_detail = link
      history_obj.action = action
    end
    return history_obj
  end
end
