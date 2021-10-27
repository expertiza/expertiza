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

  def self.get_submission_grade_info(participant)
    # Gets the submission grade for a participant from the grade column of the participant table
    # If no grade is assigned to the participant, it returns "N/A"
    # All returns are in string to keep them HTML safe 
    info = ''
    if participant.try(:grade).nil?
      info = "N/A"
    else
      info = participant.try(:grade).to_s
    end
  info
  end

  def check_reviewable_topics(assignment)
    return true if !assignment.topics? and assignment.current_stage != "submission"
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
      # In the student task homepage, list only those badges that are approved
      if awarded_badge.approved?
        info += '<img width="30px" src="/assets/badges/' + badge.image_name + '" title="' + badge.name + '" />'
      end
    end
    info.html_safe
  end

  def review_deadline?(assignment)
    assignment.find_due_dates('review').present?
  end

  def student_has_any_awarded_badges?(student_tasks)
    # We maintain an initial count as zero
    # and if we find any non empty string in the badges column, we update the count
    # in the end if the count is zero, it means the column didn't have any content
    # we return the boolean value back which can be used to display or drop a column
    count = 0
    student_tasks.each do |student_task| 
      participant = student_task.participant
      unless get_awarded_badges(participant).to_s.strip.empty?
        count = count + 1
      end
    end

    if count == 0
      return false
    end
    return true
  end

  def student_has_any_courses?(student_tasks)
    count = 0
    student_tasks.each do |student_task| 
      course_name = student_task.course.try :name
      # check if course name exists for a row, and if it exists, increase the count
      unless course_name.blank?
        count = count + 1
      end
    end
    # if no topic exists in the column, we should not display the column
    if count == 0
      return false
    end
    return true
  end

  def student_has_any_topics?(student_tasks)
    count = 0
    student_tasks.each do |student_task| 
      participant = student_task.participant
      topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
      # check if student topic exists for a row, and if it exists, increase the count
      if SignUpTopic.exists?(topic_id)
        count = count + 1
      end
    end
    # if no topic exists in the column, we should not display the column
    if count == 0
      return false
    end
    return true
  end

  def student_has_any_current_stages?(student_tasks)
    count = 0
    student_tasks.each do |student_task| 
      participant = student_task.participant
      # check if student's current stages exists for a row, and if it exists, increase the count
      topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
      current_stage_name = participant.assignment.current_stage_name(topic_id)
      unless current_stage_name.blank?
        count = count + 1
      end
    end
    # if no current stage exists in the column, we should not display the column
    if count == 0
      return false
    end
    return true
  end

  def student_has_any_stage_deadlines?(student_tasks)
    count = 0
    student_tasks.each do |student_task| 
      stage_deadline = student_task.stage_deadline.in_time_zone(session[:user].timezonepref)
      # check if student's stage deadline exists for a row, and if it exists, increase the count
      unless stage_deadline.blank?
        count = count + 1
      end
    end
    # if no stage deadlines exists in the column, we should not display the column
    if count == 0
      return false
    end
    return true
  end


end
