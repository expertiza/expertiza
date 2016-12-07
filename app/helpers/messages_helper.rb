module MessagesHelper

def reviewee_or_reviewer(message)
	team = AssignmentTeam.find(message.chat.assignment_team_id)
  for user in team.users
    if message.user==user
      return "Reviewee"
    end
      end
	return "Reviewer"
end
end