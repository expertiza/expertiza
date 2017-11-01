module StudentTeamsHelper
  # This method will return true if the assignment have some topic
  def topic?(assignment_id)
    topics = SignUpTopic.where("assignment_id = ?", assignment_id)
    topics.empty?
  end

  def user_has_topic?(user_id, assignment_id)
    # This query takes the user_id and assignment_id as input then does a inner join between the Sign_up_Topics, Signed_up_teams,
    # and teams_users table to find, if the user has selected any topic for that particular assignment or not.
    user_topic = SignUpTopic.joins("INNER JOIN signed_up_teams ON signed_up_teams.topic_id =
                  sign_up_topics.id").joins("INNER JOIN teams_users ON teams_users.team_id =
                  signed_up_teams.team_id").where("sign_up_topics.assignment_id = ? and teams_users.user_id = ?", assignment_id, user_id).uniq
    !user_topic.empty?
  end
end
