class metareview  < DeadlineType

  def email_list(assignment_id)
    emails =[]
    mail_metareviewers
    if assignment.team_assignment?
      emails = getTeamMembersMail
    end
    emails
  end

  def mail_metareviewers(assignment_id)
    emails = []
    # find reviewers for the assignment
    reviewer_tuples = ResponseMap.where(['reviewed_object_id = ? AND type = "ReviewResponseMap"', assignment_id])
    for reviewer in reviewer_tuples
      # find metareviewers - people who will review the reviewers
      meta_reviewer_tuples = ResponseMap.where(['reviewed_object_id = ? AND type = "MetareviewResponseMap"', reviewer.id])
      for metareviewer in meta_reviewer_tuples
        participant = Participant.where(['parent_id = ? AND id = ?', assignment_id, metareviewer.reviewer_id]).first
        uid  = participant.user_id
        user = User.find(uid)
        emails << user.email
      end
    end
    emails
    #email_reminder(emails, self.deadline_type) if emails.size > 0
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

  end