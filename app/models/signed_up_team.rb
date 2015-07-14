class SignedUpTeam < ActiveRecord::Base
  belongs_to :topic, :class_name => 'SignUpTopic'

  #the below has been added to make is consistent with the database schema
  validates_presence_of :topic_id, :team_id

  scope :by_team_id, ->(team_id) { where("team_id = ?", team_id) }

  #This method is not used anywhere
  #def cancel_waitlists_of_users(team_id, assignment_id)
  #  waitlisted_topics = SignedUpTeam.find_by_sql("SELECT u.id FROM sign_up_topics t, signed_up_teams u WHERE t.id = u.topic_id and u.is_waitlisted = true and t.assignment_id = " + assignment_id.to_s + " and u.team_id = " + team_id.to_s)
  #   SignedUpTeam
  #  if !waitlisted_topics.nil?
  #    for waitlisted_topic in waitlisted_topics
  #      entry = SignedUpTeam.find(waitlisted_topic.id)
  #      entry.destroy
  #    end
  #  end

  #end

  def self.find_team_participants(assignment_id)
    #@participants = SignedUpTeam.find_by_sql("SELECT s.id as id, t.id as topic_id, t.topic_name as name , s.is_waitlisted as is_waitlisted, s.team_id, s.team_id as team_id FROM signed_up_teams s, sign_up_topics t where s.topic_id = t.id and t.assignment_id = " + assignment_id)
    @participants = SignedUpTeam.find_by_sql(["SELECT s.id as id, t.id as topic_id, t.topic_name as name, t.topic_name as team_name_placeholder, t.topic_name as user_name_placeholder, s.is_waitlisted as is_waitlisted, s.team_id as team_id FROM signed_up_teams s, sign_up_topics t where s.topic_id = t.id and t.assignment_id = ? ",assignment_id])
    i=0
    for participant in @participants
      #participant_names = SignedUpTeam.find_by_sql("SELECT s.name as u_name, t.name as team_name FROM users s, teams t, teams_users u WHERE t.id = u.team_id and u.user_id = s.id and t.id = " + participant.team_id)
      participant_names = SignedUpTeam.find_by_sql(["SELECT s.name as u_name, t.name as team_name FROM users s, teams t, teams_users u WHERE t.id = u.team_id and u.user_id = s.id and t.id = ?", participant.team_id])
      team_name_added = false
      names = '(missing team)'

      for participant_name in participant_names
        if team_name_added == false
          names = "["+participant_name.team_name+"] "+ participant_name.u_name + " "
          participant.team_name_placeholder = participant_name.team_name
          participant.user_name_placeholder = participant_name.u_name + " "
          team_name_added = true
        else
          names = names + participant_name.u_name + " "
          participant.user_name_placeholder += participant_name.u_name + " "
        end
      end
      @participants[i].name = names
      i = i + 1
    end

    @participants
  end

  #This method name does not make any sense, and it is implemented in the find_by_sql style instead of using Rails.
  #This method returns a list of tpic id, user id and if the user is waitlisted, given a assignment_id. I comment out it for now, and will remove this method later.
  # def self.find_participants(assignment_id)
  #   #SignedUpTeam.find_by_sql("SELECT t.id as topic_id,u.name as name, s.is_waitlisted as is_waitlisted FROM signed_up_teams s, users u, sign_up_topics t where s.team_id = u.id and s.topic_id = t.id and t.assignment_id = " + assignment_id)
  #   SignedUpTeam.find_by_sql(["SELECT t.id as topic_id,u.name as name, s.is_waitlisted as is_waitlisted FROM signed_up_teams s, users u, sign_up_topics t where s.team_id = u.id and s.topic_id = t.id and t.assignment_id = ?", assignment_id])
  # end

  #this method is used to find team_id, according to assignment_id and user_id
  def self.find_team_users(assignment_id,user_id)
    #TeamsUser.find_by_sql("SELECT t.id as t_id FROM teams_users u, teams t WHERE u.team_id = t.id and t.parent_id =" + assignment_id.to_s + " and user_id =" + user_id.to_s)
    TeamsUser.find_by_sql(["SELECT t.id as t_id FROM teams_users u, teams t WHERE u.team_id = t.id and t.parent_id = ? and user_id = ?", assignment_id, user_id])
  end

  def self.find_user_signup_topics(assignment_id,team_id)
    #SignedUpTeam.find_by_sql("SELECT t.id as topic_id, t.topic_name as topic_name, u.is_waitlisted as is_waitlisted FROM sign_up_topics t, signed_up_teams u WHERE t.id = u.topic_id and t.assignment_id = " + assignment_id.to_s + " and u.team_id =" + team_id.to_s)
    SignedUpTeam.find_by_sql(["SELECT t.id as topic_id, t.topic_name as topic_name, u.is_waitlisted as is_waitlisted, u.preference_priority_number as preference_priority_number FROM sign_up_topics t, signed_up_teams u WHERE t.id = u.topic_id and t.assignment_id = ? and u.team_id = ?", assignment_id.to_s, team_id.to_s])
  end

  #If a signup sheet exists then release topics that the given team has selected for the given assignment.
  def self.release_topics_selected_by_team_for_assignment(team_id, assignment_id)
    #Get all the signups for the team
    old_teams_signups = SignedUpTeam.where(team_id: team_id)

    #If the team has signed up for the topic and they are on the waitlist then remove that team from the waitlist.
    if !old_teams_signups.nil?
      for old_teams_signup in old_teams_signups
        if old_teams_signup.is_waitlisted == false # i.e., if the old team was occupying a slot, & thus is releasing a slot ...
          first_waitlisted_signup = SignedUpTeam.where(topic_id: old_teams_signup.topic_id, is_waitlisted:  true).first
          if !first_waitlisted_signup.nil?
            Invitation.remove_waitlists_for_team(old_teams_signup.topic_id, assignment_id)
          end
        end
        old_teams_signup.destroy
        end
      end
    end

    #This method is used to returns topic_id from [signed_up_teams] table and the inputs are assignment_id and user_id.
    def self.topic_id(assignment_id, user_id)
      #team_id variable represents the team_id for this user in this assignment
      team_id = TeamsUser.team_id(assignment_id, user_id)
      if team_id
        topic_id_by_team_id(team_id)
      else
         nil
      end
    end

  def self.topic_id_by_team_id(team_id)
    signed_up_teams = SignedUpTeam.where(team_id:team_id ,is_waitlisted:0)
    if signed_up_teams.blank?
      nil
    else
      signed_up_teams.first.topic_id
    end
  end
    
  end
