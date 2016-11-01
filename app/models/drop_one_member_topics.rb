class DropOneMemberTopics < DeadlineType

def email_list(assignment_id)
  assignment = Assignment.find(assignment_id)
  drop_one_member_topics if (assignment.team_assignment?)
  emails =[]
  emails     
end

def drop_one_member_topics
 teams = TeamsUser.all.group(:team_id).count(:team_id)
    for team_id in teams.keys
      if teams[team_id] == 1
        topic_to_drop = SignedUpTeam.where(team_id: team_id).first
        topic_to_drop.delete if topic_to_drop #check if the one-person-team has signed up a topic
      end
    end
end

end  