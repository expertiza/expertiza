class SignedUpUser < ActiveRecord::Base
  belongs_to :topic, :class_name => 'SignUpTopic'

  def cancel_waitlists_of_users(creator_id, assignment_id)
    waitlisted_topics = SignedUpUser.find_by_sql("SELECT u.id FROM sign_up_topics t, signed_up_users u WHERE t.id = u.topic_id and u.is_waitlisted = true and t.assignment_id = " + assignment_id.to_s + " and u.creator_id = " + creator_id.to_s)
     SignedUpUser
    if !waitlisted_topics.nil?
      for waitlisted_topic in waitlisted_topics
        entry = SignedUpUser.find(waitlisted_topic.id)
        entry.destroy
      end
    end

  end

  def self.find_team_participants(assignment_id)
    @participants = SignedUpUser.find_by_sql("SELECT s.id as id, t.id as topic_id, t.topic_name as name , s.is_waitlisted as is_waitlisted, s.creator_id, s.creator_id as team_id FROM signed_up_users s, sign_up_topics t where s.topic_id = t.id and t.assignment_id = " + assignment_id)
      i=0
      for participant in @participants
        participant_names = SignedUpUser.find_by_sql("SELECT s.name as u_name, t.name as team_name FROM users s, teams t, teams_participants u WHERE t.id = u.team_id and u.user_id = s.id and t.id = " + participant.team_id)
        team_name_added = false
        names = '(missing team)'
        for participant_name in participant_names
          if team_name_added == false
            names = "<br/> <b>" + participant_name.team_name + "</b>" + "<br/>" + participant_name.u_name + " "
            team_name_added = true
          else
            names = names + participant_name.u_name + " "
          end
        end
        @participants[i].name = names
        i = i + 1
      end
    @participants
  end

  def self.find_participants(assignment_id)
    SignedUpUser.find_by_sql("SELECT t.id as topic_id,u.name as name, s.is_waitlisted as is_waitlisted FROM signed_up_users s, users u, sign_up_topics t where s.creator_id = u.id and s.topic_id = t.id and t.assignment_id = " + assignment_id)
  end

  def self.find_team_participants(assignment_id,user_id)
    TeamsParticipant.find_by_sql("SELECT t.id as t_id FROM teams_participants u, teams t WHERE u.team_id = t.id and t.parent_id =" + assignment_id.to_s + " and user_id =" + user_id.to_s)
  end

  def self.find_user_signup_topics(assignment_id,creator_id)
    SignedUpUser.find_by_sql("SELECT t.id as topic_id, t.topic_name as topic_name, u.is_waitlisted as is_waitlisted FROM sign_up_topics t, signed_up_users u WHERE t.id = u.topic_id and t.assignment_id = " + assignment_id.to_s + " and u.creator_id =" + creator_id.to_s)
  end

  def self.find_team_members_fullname(team_id)
    TeamsParticipant.find_by_sql("SELECT s.fullname as fullname, u.team_id as t_id FROM teams_participants u, users s WHERE u.team_id = " + team_id + " and s.id = u.user_id")
  end

  def self.find_team_members_name(team_id)
    TeamsParticipant.find_by_sql("SELECT s.name as u_name FROM teams_participants u, users s WHERE u.team_id = " + team_id + " and s.id = u.user_id")
  end

  def self.find_invitation_senders_team(assignment_id,user_id)
    TeamsParticipant.find_by_sql("SELECT t.id as t_id FROM teams_participants u, teams t WHERE u.team_id = t.id and t.parent_id =" + assignment_id.to_s + " and user_id =" + user_id.to_s)
  end

  
end
