module StudentTaskHelper
  def get_review_grade_info(participant)
    info = ''
    if participant.try(:review_grade).try(:grade_for_reviewer).nil? ||
       participant.try(:review_grade).try(:comment_for_reviewer).nil?
      result = "N/A"
    else
      info = "Score: " + participant.try(:review_grade).try(:grade_for_reviewer).to_s + "/100\n"
      info += "Comment: " + participant.try(:review_grade).try(:comment_for_reviewer).to_s
      info = truncate(info, length: 1500, omission: '...')
      result = "<img src = '/assets/info.png' title = '" + info + "'>"
    end
    result.html_safe
  end

  def check_reviewable_topics(assignment)
    return true if !assignment.topics? and assignment.get_current_stage != "submission"
    sign_up_topics = SignUpTopic.where(assignment_id: assignment.id)
    sign_up_topics.each {|topic| return true if assignment.can_review(topic.id) }
    false
  end

  def unsubmitted_self_review?(participant_id)
    self_review = SelfReviewResponseMap.where(reviewer_id: participant_id).first.try(:response).try(:last)
    return !self_review.try(:is_submitted) if self_review
    true
  end

  def get_awarded_badges(participant)
    info = ''
    participant.awarded_badges.each do |awarded_badge|
      badge = awarded_badge.badge
      info += '<img width="30px" src="/assets/badges/' + badge.image_name + '" title="' + badge.name + '" />'
    end
    info.html_safe
  end

  # This function is used to break up a string to multiple lines if there is a single word that is longer than the
  # specified column width. This allows there to be a line break in the middle of a word that is really long.
  def breaking_wrap_wrap(txt, col = 80)
    txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/,
             "\\1\\3\n")
  end

  # Determine a background color based on how many days out the due date is.
  def due_date_color(due_date)
    time_remaining = (DateTime.now - due_date.to_date).to_i
    rtn = "white"
    # More than 2 weeks away
    if time_remaining < -14
      rtn = "white"
      #Between 2 weeks and 10 days
    elsif time_remaining < -10
      rtn = "lightgreen"
      #Between 10 days and a week
    elsif time_remaining < -7
      rtn = "lightyellow"
      #Between a week and 4 days
    elsif time_remaining < -4
      rtn = "lightsalmon"
      #Between 4 days and the due date
    elsif time_remaining <= 0
      rtn = "lightcoral"
    else
      rtn = "white"
    end
    # Return the appropriate color
    rtn

  end
end
