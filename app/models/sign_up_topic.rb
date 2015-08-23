class SignUpTopic < ActiveRecord::Base
  has_many :signed_up_teams, :foreign_key => 'topic_id', :dependent => :destroy
  has_many :topic_dependencies, :foreign_key => 'topic_id', :dependent => :destroy
  has_many :topic_deadlines, :foreign_key => 'topic_id', :dependent => :destroy
  alias_method :deadlines, :topic_deadlines
  has_many :bids, :foreign_key => 'topic_id', :dependent => :destroy
  belongs_to :assignment

  has_paper_trail

  #the below relations have been added to make it consistent with the database schema
  validates_presence_of :topic_name, :assignment_id, :max_choosers
  validates_length_of :topic_identifier, :maximum => 10

  #This method is not used anywhere
  #def get_team_id_from_topic_id(user_id)
  #  return find_by_sql("select t.id from teams t,teams_users u where t.id=u.team_id and u.user_id = 5");
  #end

  def self.import(row,session,id = nil)

    if row.length != 4
      raise ArgumentError, "CSV File expects the format: Topic identifier, Topic name, Max choosers, Topic Category"
    end

    topic = SignUpTopic.where(topic_name: row[1], assignment_id: session[:assignment_id]).first

    if topic == nil
      attributes = ImportTopicsHelper::define_attributes(row)
      ImportTopicsHelper::create_new_sign_up_topic(attributes,session)
    else
      topic.max_choosers = row[2]
      topic.topic_identifier = row[0]
      #topic.assignment_id = session[:assignment_id]
      topic.save
    end
  end

  def self.find_slots_filled(assignment_id)
    #SignUpTopic.find_by_sql("SELECT topic_id as topic_id, COUNT(t.max_choosers) as count FROM sign_up_topics t JOIN signed_up_teams u ON t.id = u.topic_id WHERE t.assignment_id =" + assignment_id+  " and u.is_waitlisted = false GROUP BY t.id")
    SignUpTopic.find_by_sql(["SELECT topic_id as topic_id, COUNT(t.max_choosers) as count FROM sign_up_topics t JOIN signed_up_teams u ON t.id = u.topic_id WHERE t.assignment_id = ? and u.is_waitlisted = false GROUP BY t.id", assignment_id])
  end

  def self.find_slots_waitlisted(assignment_id)
    #SignUpTopic.find_by_sql("SELECT topic_id as topic_id, COUNT(t.max_choosers) as count FROM sign_up_topics t JOIN signed_up_teams u ON t.id = u.topic_id WHERE t.assignment_id =" + assignment_id +  " and u.is_waitlisted = true GROUP BY t.id")
    SignUpTopic.find_by_sql(["SELECT topic_id as topic_id, COUNT(t.max_choosers) as count FROM sign_up_topics t JOIN signed_up_teams u ON t.id = u.topic_id WHERE t.assignment_id = ? and u.is_waitlisted = true GROUP BY t.id", assignment_id])
  end

  def self.find_waitlisted_topics(assignment_id,team_id)
    #SignedUpTeam.find_by_sql("SELECT u.id FROM sign_up_topics t, signed_up_teams u WHERE t.id = u.topic_id and u.is_waitlisted = true and t.assignment_id = " + assignment_id.to_s + " and u.team_id = " + team_id.to_s)
    SignedUpTeam.find_by_sql(["SELECT u.id FROM sign_up_topics t, signed_up_teams u WHERE t.id = u.topic_id and u.is_waitlisted = true and t.assignment_id = ? and u.team_id = ?", assignment_id.to_s, team_id.to_s])
  end

  def self.slotAvailable?(topic_id)
    topic = SignUpTopic.find(topic_id)
    no_of_students_who_selected_the_topic = SignedUpTeam.where(topic_id: topic_id, is_waitlisted: false)

    if !no_of_students_who_selected_the_topic.nil?
      if topic.max_choosers > no_of_students_who_selected_the_topic.size
        return true
      else
        return false
      end
    else
      return true
    end
  end

  def self.reassign_topic(session_user_id, assignment_id, topic_id)

    #find whether assignment is team assignment
    assignment = Assignment.find(assignment_id)

    #making sure that the drop date deadline hasn't passed
    dropDate = DueDate.where(:assignment_id => assignment.id, :deadline_type_id => '6').first
    if (!dropDate.nil? && dropDate.due_at < Time.now)
      #flash[:error] = "You cannot drop this topic because the drop deadline has passed."
    else
      #if team assignment find the creator id from teamusers table and teams
      #ACS Removed the if condition (and corresponding else) which differentiate assignments as team and individual assignments
      # to treat all assignments as team assignments
      #users_team will contain the team id of the team to which the user belongs
      users_team = SignedUpTeam.find_team_users(assignment_id, session_user_id)
      signup_record = SignedUpTeam.where(topic_id: topic_id, team_id:  users_team[0].t_id).first
      assignment = Assignment.find(assignment_id)
      #if a confirmed slot is deleted then push the first waiting list member to confirmed slot if someone is on the waitlist
      if(!assignment.is_intelligent?)
        if signup_record.is_waitlisted == false
          #find the first wait listed user if exists
          first_waitlisted_user = SignedUpTeam.where(topic_id: topic_id, is_waitlisted:  true).first

          if !first_waitlisted_user.nil?
            # As this user is going to be allocated a confirmed topic, all of his waitlisted topic signups should be purged
            ### Bad policy!  Should be changed! (once users are allowed to specify waitlist priorities) -efg
            first_waitlisted_user.is_waitlisted = false
            first_waitlisted_user.save

            #ACS Removed the if condition (and corresponding else) which differentiate assignments as team and individual assignments
            # to treat all assignments as team assignments
            Waitlist.cancel_all_waitlists(first_waitlisted_user.team_id, assignment_id)
            end
        end
      end
      if !signup_record.nil?
        signup_record.destroy
      end
      end #end condition for 'drop deadline' check
  end

  def update_waitlisted_users(max_choosers)
    num_of_users_promotable = max_choosers.to_i - self.max_choosers.to_i

    num_of_users_promotable.times {
      next_wait_listed_team = SignedUpTeam.where({:topic_id => self.id, :is_waitlisted => true}).first
      #if slot exist, then confirm the topic for this team and delete all waitlists for this team
      if next_wait_listed_team
        team_id = next_wait_listed_team.team_id
        team = Team.find(team_id)
        assignment_id = team.parent_id
        next_wait_listed_team.is_waitlisted = false
        next_wait_listed_team.save
        Waitlist.cancel_all_waitlists(team_id, assignment_id)
      end
    }
  end

  def self.remove_team(users_team, assignment_id)
    if users_team.size == 0
      @selected_topics = nil
    else
      #TODO: fix this; cant use 0
      @selected_topics = SignUpSheetController.other_confirmed_topic_for_user(assignment_id, users_team[0].t_id)
    end
  end

  def self.has_suggested_topic?(assignment_id)
    sign_up_topics = SignUpTopic.where(assignment_id: assignment_id, private_to: nil)
    all_topics = SignUpTopic.where(assignment_id: assignment_id)
    return false if sign_up_topics.size == all_topics.size
    return true
  end
end
