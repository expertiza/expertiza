module MessagesHelper

def is_reviewer(message)
 team = AssignmentTeam.find(message.chat.assignment_team_id)
  for user in team.users
    if message.user==user
      return "Author"
    end
  end
 return "Reviewer"
end
end
