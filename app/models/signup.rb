class signup  < DeadlineType

  def email_list(assignment_id)
    emails =[]
    sign_up_topics = SignUpTopic.where(['assignment_id = ?', assignment_id])
    if (!sign_up_topics.nil? && sign_up_topics.count != 0)
      emails= mail_assignment_participants(assignment_id) # reminder to all participants
    end
    emails
  end

  def mail_assignment_participants(assignment_id)
    emails = []
    assignment = Assignment.find(assignment_id)
    for participant in assignment.participants
      uid = participant.user_id
      user = User.find(uid)
      emails << user.email
    end
    #email_reminder(emails, self.deadline_type)
    emails
  end

end