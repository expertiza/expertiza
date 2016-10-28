class submission < DeadlineType
def email_list(assignment_id)
  emails = []
  assignment = Assignment.find(self.assignment_id)
  sign_up_topics = SignUpTopic.where(['assignment_id = ?', self.assignment_id])

  # If there are sign_up topics for an assignement then send a mail toonly signed_up_teams else send a mail to all participants
  if (sign_up_topics.nil? || sign_up_topics.count == 0)
    emails = mail_non_sign_up_topic_users
  else
    emails = mail_sign_up_topic_users
  end
  emails
end
def mail_sign_up_topic_users
  sign_up_topics = SignUpTopic.where(['assignment_id = ?', self.assignment_id])
  assignment = Assignment.find(self.assignment_id)
  emails =[]
  for topic in sign_up_topics
    signedUpTeams = SignedUpTeam.where(['topic_id = ?', topic.id])
    unless assignment.team_assignment?
      for signedUser in signedUpTeams
        uid  = signedUser.team_id
        user = User.find(uid)
        emails << user.email
      end
    else
      for signedUser in signedUpTeams
        teamid = signedUser.team_id
        team_members = TeamsUser.where(team_id: teamid)
        for team_member in team_members
          user = User.find(team_member.user_id)
          emails << user.email
        end
      end
    end
  end
  emails
end

def mail_non_sign_up_topic_users
  emails = []
  assignment = Assignment.find(self.assignment_id)

  if assignment.team_assignment?
    emails = getTeamMembersMail
  else
    emails = mail_assignment_participants
  end
  emails
end
end