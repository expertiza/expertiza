class Participant < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic, :class_name => 'SignUpTopic'

  has_many   :comments, :dependent => :destroy
  has_many   :resubmission_times, :dependent => :destroy
  has_many   :reviews, :class_name => 'ResponseMap', :foreign_key => 'reviewer_id'

  validates_numericality_of :grade, :allow_nil => true

  def name
    User.find(self.user_id).name
  end

  def fullname
    User.find(self.user_id).fullname
  end

  def delete(force = nil)
    maps = ResponseMap.find(:all, :conditions => ['reviewee_id = ? or reviewer_id = ?',self.id,self.id])

    if force or ((maps.nil? or maps.length == 0) and
                 self.team.nil?)
      force_delete(maps)
    else
      raise "Associations exist for this participant"
    end
  end

  def force_delete(maps)
    times = ResubmissionTime.find(:all, :conditions => ['participant_id = ?',self.id])

    if times
      times.each { |time| time.destroy }
    end

    if maps
      maps.each { |map| map.delete(true) }
    end

    if self.team
      if self.team.teams_users.length == 1
        self.team.delete
      else
        self.team.teams_users.each{ |tuser|
          if tuser.user_id == self.id
            tuser.delete
          end
        }
      end
     end
     self.destroy
  end

  def get_topic_string
    if topic.nil? or topic.topic_name.empty?
      return "<center>&#8212;</center>"
    end
    return topic.topic_name
  end

  def able_to_submit
    if submit_allowed
      return true
    end
    return false
  end

  def able_to_review
    if review_allowed
      return true
    end
    return false
  end

  def email(pw, home_page)
    user = User.find_by_id(self.user_id)
    assignment = Assignment.find_by_id(self.assignment_id)

    Mailer.deliver_message(
            {:recipients => user.email,
             :subject => "You have been registered as a participant in Assignment #{assignment.name}",
             :body => {
              :home_page => home_page,
              :first_name => ApplicationHelper::get_user_first_name(user),
              :name =>user.name,
              :password =>pw,
              :partial_name => "register"
             }
            }
    )
  end

  #This function updates the topic_id for a participant in assignments where a signup sheet exists
  #If the assignment is not a team assignment then this method should be called on the object of the participant
  #If the assignment is a team assignment then this method should be called on the participant object of one of the team members.
  #Other team members records will be updated automatically.
  def update_topic_id(topic_id)
    assignment = Assignment.find(self.parent_id)

    if assignment.team_assignment?
      team = Team.find_by_sql("SELECT u.team_id as team_id
                                  FROM teams as t,teams_users as u
                                  WHERE t.parent_id = " + assignment.id.to_s + " and t.id = u.team_id and u.user_id = " + self.user_id.to_s )

      team_id = team[0]["team_id"]
      team_members = TeamsUser.find_all_by_team_id(team_id)

      team_members.each { |team_member|
        participant = Participant.find_by_user_id_and_parent_id(team_member.user_id,assignment.id)
        participant.update_attribute(:topic_id, topic_id)
      }
    else
      self.update_attribute(:topic_id, topic_id)
    end
  end

#was initially in assignment.rb. Moved here.
#add a new participant to this assignment
#manual addition
# user_name - the user account name of the participant to add
  def add_participant(user_name)
    user = User.find_by_name(user_name)
    if (user == nil)
      raise "No user account exists with the name "+user_name+". Please <a href='"+url_for(:controller=>'users',:action=>'new')+"'>create</a> the user first."
    end
    participant = AssignmentParticipant.find_by_parent_id_and_user_id(self.id, user.id)
    if !participant
      newpart = AssignmentParticipant.create(:parent_id => self.id, :user_id => user.id, :permission_granted => user.master_permission_granted)
      newpart.set_handle()
    else
      raise "The user \""+user.name+"\" is already a participant."
    end
  end


end
