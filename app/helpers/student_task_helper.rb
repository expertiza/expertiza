module StudentTaskHelper
  def get_review_grade_info(participant)
    info = ''
    if participant.try(:grade_for_reviewer).nil? or participant.try(:comment_for_reviewer).nil?
      result = "N/A"
    else
      info = "Score: " + participant.try(:grade_for_reviewer).to_s + "\n"
      info += "Comment: " + participant.try(:comment_for_reviewer).to_s
      info = truncate(info, length: 1500, omission: '...')
      result = "<img src = '/assets/info.png' title = '" + info + "'>"
    end
    result.html_safe
  end

  def check_reviewable_topics(assignment)
    return true if !assignment.has_topics? and assignment.get_current_stage != "submission"
    sign_up_topics = SignUpTopic.where(assignment_id: assignment.id)
    sign_up_topics.each {|topic| return true if assignment.can_review(topic.id) }
    false
  end
end
