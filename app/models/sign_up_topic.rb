class SignUpTopic < ActiveRecord::Base
  has_many :signed_up_users, :foreign_key => 'topic_id', :dependent => :destroy
  has_many :topic_dependencies, :foreign_key => 'topic_id', :dependent => :destroy
  has_many :topic_deadlines, :foreign_key => 'topic_id', :dependent => :destroy 
  has_many :assignment_participants, :foreign_key => 'topic_id'

  belongs_to :assignment

  def get_team_id_from_topic_id(user_id)
    return find_by_sql("select t.id from teams t,teams_participants u where t.id=u.team_id and u.user_id = 5");
  end

  def self.import(row,session,id = nil)

      if row.length != 4
          raise ArgumentError, "CSV File expects the format: Topic identifier, Topic name, Max choosers, Topic Category"
      end      

      topic = SignUpTopic.find_by_topic_name_and_assignment_id(row[1],session[:assignment_id])
      
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
    SignUpTopic.find_by_sql("SELECT topic_id as topic_id, COUNT(t.max_choosers) as count FROM sign_up_topics t JOIN signed_up_users u ON t.id = u.topic_id WHERE t.assignment_id =" + assignment_id+  " and u.is_waitlisted = false GROUP BY t.id")    
  end

  def self.find_slots_waitlisted(assignment_id)
    SignUpTopic.find_by_sql("SELECT topic_id as topic_id, COUNT(t.max_choosers) as count FROM sign_up_topics t JOIN signed_up_users u ON t.id = u.topic_id WHERE t.assignment_id =" + assignment_id +  " and u.is_waitlisted = true GROUP BY t.id")
  end

  def self.find_waitlisted_topics(assignment_id,creator_id)
    SignedUpUser.find_by_sql("SELECT u.id FROM sign_up_topics t, signed_up_users u WHERE t.id = u.topic_id and u.is_waitlisted = true and t.assignment_id = " + assignment_id.to_s + " and u.creator_id = " + creator_id.to_s)
  end

  def self.slotAvailable?(topic_id)
    topic = SignUpTopic.find(topic_id)
    no_of_students_who_selected_the_topic = SignedUpUser.find_all_by_topic_id_and_is_waitlisted(topic_id, false)

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


  def self.cancel_all_waitlists(creator_id, assignment_id)
    waitlisted_topics = SignUpTopic.find_waitlisted_topics(assignment_id,creator_id)
    if !waitlisted_topics.nil?
      for waitlisted_topic in waitlisted_topics
        entry = SignedUpUser.find(waitlisted_topic.id)
        entry.destroy
      end
    end

  end

  def update_waitlisted_users(max_choosers)
    num_of_users_promotable = max_choosers.to_i - self.max_choosers.to_i

    num_of_users_promotable.times {
      next_wait_listed_user = SignedUpUser.find(:first, :conditions => {:topic_id => self.id, :is_waitlisted => true})
      if !next_wait_listed_user.nil?
        next_wait_listed_user.is_waitlisted = false
        next_wait_listed_user.save

        #update participants
        assignment = Assignment.find(self.assignment_id)

        if assignment.team_assignment?
          user_id = TeamsParticipant.find(:first, :conditions => {:team_id => next_wait_listed_user.creator_id}).user_id
          participant = Participant.find_by_user_id_and_parent_id(user_id,assignment.id)
        else
          participant = Participant.find_by_user_id_and_parent_id(next_wait_listed_user.creator_id,assignment.id)
        end
        participant.update_topic_id(self.id)
      end
    }
  end
end
