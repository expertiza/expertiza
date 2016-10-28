class drop_one_member_topics < DeadlineType

email_list(assignment_id)
email=[]	
assignment = Assignment.find(self.assignment_id)
       
if (assignment.team_assignment?)
teams = TeamsUser.all.group(:team_id).count(:team_id)
    for team_id in teams.keys
      if teams[team_id] == 1
        topic_to_drop = SignedUpTeam.where(team_id: team_id).first
        topic_to_drop.delete if topic_to_drop #check if the one-person-team has signed up a topic
       end
     end
   end
  end
email[]
end
end