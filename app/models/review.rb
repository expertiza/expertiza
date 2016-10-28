class review < DeadlineType
  def email_list(assignment_id)
    emails = []
    reviewer_tuples = ResponseMap.where(['reviewed_object_id = ? AND type = "ReviewResponseMap"', assignment_id])
    for reviewer in reviewer_tuples
      participant = Participant.where(['parent_id = ? AND id = ?', assignment_id, reviewer.reviewer_id])
      uid  = participant.first.user_id
      user = User.find(uid)
      emails << user.email
    end
    emails
  end
end