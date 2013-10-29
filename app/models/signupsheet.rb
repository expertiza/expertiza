class SignupSheet < ActiveRecord::Base


  def signup_team ( assignment_id, user_id, topic_id )
    users_team = SignedUpUser.find_team_users(assignment_id, user_id)
    if users_team.size == 0
      #if team is not yet created, create new team.
      team = AssignmentTeam.create_team_and_node(assignment_id)
      user = User.find(user_id)
      teamuser = create_team_users(user, team.id)
      confirmationStatus = confirmTopic(team.id, topic_id, assignment_id)
    else
      confirmationStatus = confirmTopic(users_team[0].t_id, topic_id, assignment_id)
    end
  end
end

