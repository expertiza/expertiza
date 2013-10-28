class Participant < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic, :class_name => 'SignUpTopic'
  belongs_to :assignment, :foreign_key => 'parent_id'
  
  has_many   :comments, :dependent => :destroy
  has_many   :resubmission_times, :dependent => :destroy
  has_many   :reviews, :class_name => 'ResponseMap', :foreign_key => 'reviewer_id'
  has_many   :team_reviews, :class_name => 'TeamReviewResponseMap', :foreign_key => 'reviewer_id'
  has_many :response_maps, :class_name =>'ResponseMap', :foreign_key => 'reviewee_id'

  validates_numericality_of :grade, :allow_nil => true

  def name
    User.find(self.user_id).name
  end
  
  def fullname
    User.find(self.user_id).fullname
  end


  def delete(force = nil)
    #OSS808 Change 26/10/2013
    # Modified deprecated code
    # TODO How do we test this code?  #need a controller test_oss808
    #maps = ResponseMap.find(:all, :conditions => ['reviewee_id = ? or reviewer_id = ?',self.id,self.id])
    ResponseMap.find_all_by_reviewee_id(self.id)  ? maps=ResponseMap.find_all_by_reviewee_id(self.id)  : maps=ResponseMap.find_all_by_reviewer_id(self.id)

    if force or ((maps.nil? or maps.length == 0) and 
                 self.team.nil?)
      force_delete(maps)
    else
      raise "Associations exist for this participant"        
    end
  end


  def force_delete(maps)
    #OSS808 Change 26/10/2013
    # Deprecated Code has been changed
    #times = ResubmissionTime.find(:all, :conditions => ['participant_id = ?',self.id])
    times = ResubmissionTime.find_all_by_participant_id(self.id);

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

  #OSS808 Change 27/10/2013
  #Method renamed to  topic_name from get_topic_string
  def topic_name
    if topic.nil? or topic.topic_name.empty?
      return "<center>&#8212;</center>"
    end
    return topic.topic_name
  end

  #OSS808 Change 26/10/2013
  #Method commented as it is not used anywhere in the project and also it just
  # returns the value of the variable which can be done by attr_accessor

=begin
  def able_to_submit
   if submit_allowed
      return true
    end
    return false
  end
=end

  def able_to_review
    if review_allowed
      return true
    end
    return false
  end

  #OSS808 Change 26/10/2013
  # email does not work. It should be made to work in the future
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

    #ACS Call the select method for all the teams(single or group)
    #removed check to see if it is a team assignment
    team = Team.find_by_sql("SELECT u.team_id as team_id
                                FROM teams as t,teams_users as u
                                WHERE t.parent_id = " + assignment.id.to_s + " and t.id = u.team_id and u.user_id = " + self.user_id.to_s )

    team_id = team[0]["team_id"]
    team_members = TeamsUser.find_all_by_team_id(team_id)

    team_members.each { |team_member|
      participant = Participant.find_by_user_id_and_parent_id(team_member.user_id,assignment.id)
      participant.update_attribute(:topic_id, topic_id)
    }
  end




  # Return scores that this participant for the given questions
  def get_scores(questions)
    scores = Hash.new
    scores[:participant] = self
    self.assignment.questionnaires.each do |questionnaire|
      scores[questionnaire.symbol] = Hash.new
      scores[questionnaire.symbol][:assessments] = questionnaire.get_assessments_for(self)

      scores[questionnaire.symbol][:scores] = Score.compute_scores(scores[questionnaire.symbol][:assessments], questions[questionnaire.symbol])
    end
    scores[:total_score] = assignment.compute_total_score(scores)
    return scores
  end

  #OSS808 Change 27/10/2013
  #moved from assignment_participant.rb

  def get_course_string
    # if no course is associated with this assignment, or if there is a course with an empty title, or a course with a title that has no printing characters ...
    begin
      course = Course.find(self.assignment.course.id)
      if course.name.strip.length == 0
        raise
      end
      return course.name
    rescue
      return "<center>&#8212;</center>"
    end
  end

end