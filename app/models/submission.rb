class Submission < DeadlineType

def email_list(assignment_id)
  assignment = Assignment.find(assignment_id)
  sign_up_topics = SignUpTopic.where(['assignment_id = ?', assignment_id])

  # If there are sign_up topics for an assignement then send a mail toonly signed_up_teams else send a mail to all participants
  if (sign_up_topics.nil? || sign_up_topics.count == 0)
    emails = mail_non_sign_up_topic_users(assignment_id)
  else
    emails = mail_sign_up_topic_users(assignment_id)
  end
  emails
end
def mail_sign_up_topic_users(assignment_id)
  sign_up_topics = SignUpTopic.where(['assignment_id = ?', assignment_id])
  assignment = Assignment.find(assignment_id)
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

def mail_non_sign_up_topic_users(assignment_id)
  assignment = Assignment.find(assignment_id)

  if assignment.team_assignment?
    emails = getTeamMembersMail(assignment_id)
  else
    emails = mail_assignment_participants(assignment_id)
  end
  emails
end

def getTeamMembersMail(assignment_id)
  teamMembersMailList = []
  assignment = Assignment.find(assignment_id)
  teams = Team.where(['parent_id = ?', assignment_id])
  for team in teams
    team_participants = TeamsUser.where(['team_id = ?', team.id])
    for team_participant in team_participants
      user = User.find(team_participant.user_id)
      teamMembersMailList << user.email
    end
  end
  teamMembersMailList
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
