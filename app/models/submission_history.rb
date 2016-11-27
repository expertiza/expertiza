class SubmissionHistory < ActiveRecord::Base
  belongs_to :team

  def self.create(team, link, action)
    # for file, the link will be? - put this as default condition
    # determine whether this is a file or a link
    if link.start_with?("http")
      history_obj = LinkSubmissionHistory.create(team, link, action)
    else
      history_obj = FileSubmissionHistory.create(team, link, action)
    end
    return history_obj
  end
end
