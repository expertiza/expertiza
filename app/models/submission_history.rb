class SubmissionHistory < ActiveRecord::Base
  belongs_to :team

  def self.create(team, link)
    # for file, the link will be? - put this as default condition
    # determine whether this is a file or a link
    existing_submission = SubmissionHistory.where(["team = ? and submitted_detail = ?", team, link])
    if existing_submission
      action = "edit"
    else
      action = "add"
    end
    if link.start_with?("http")
      history_obj = LinkSubmissionHistory.create(link, team, action)
    else
      history_obj = FileSubmissionHistory.create(link, team, action)
    end
    return history_obj
  end

  def self.delete_submission(team, link)
    # just add a delete record
    if link.start_with?("http")
      history_obj = LinkSubmissionHistory.create(link, team, "delete")
    else
      history_obj = FileSubmissionHistory.create(link, team, "delete")
    end
  end

  def get_submitted_at_time
    return Time.current
  end

  def updated?
    return false
  end

end
