class Participant < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic, :class_name => 'SignUpTopic'
  belongs_to :assignment, :foreign_key => 'parent_id'
  
  has_many   :comments, :dependent => :destroy
  has_many   :resubmission_times, :dependent => :destroy
  has_many   :reviews, :class_name => 'ResponseMap', :foreign_key => 'reviewer_id'
  #has_many :response_maps, :foreign_key => 'reviewee_id'
  has_many :response_maps, :class_name =>'ResponseMap', :foreign_key => 'reviewee_id'
  # TODO A bug in Rails http://dev.rubyonrails.org/ticket/4996 prevents us from using this:
  #has_many :responses, :through => :response_maps
  
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

  # Returns the average score of all reviews for this user on this assignment
  def get_average_score()
    return 0 if self.response_maps.size == 0
    
    sum_of_scores = 0

    self.response_maps.each do |response_map|
      if !response_map.response.nil? then
        sum_of_scores = sum_of_scores + response_map.response.get_average_score
      end
    end

    (sum_of_scores / self.response_maps.size).to_i
  end

  # Returns the average score of one question from all reviews for this user on this assignment as an floating point number
  # Params: question - The Question object to retrieve the scores from
  def get_average_question_score(question)   
    sum_of_scores = 0
    number_of_scores = 0

    self.response_maps.each do |response_map|
      # TODO There must be a more elegant way of doing this...
      unless response_map.response.nil?
        response_map.response.scores.each do |score|
          if score.question == question then
            sum_of_scores = sum_of_scores + score.score
            number_of_scores = number_of_scores + 1
          end
        end
      end
    end

    return 0 if number_of_scores == 0
    (((sum_of_scores.to_f / number_of_scores.to_f) * 100).to_i) / 100.0
  end

  # SNVP - Returns the number of reviewes assigned to a this participant
  def get_total_reviews_assigned_by_type(type)
    count = 0
    self.reviews.each { |x| count = count + 1 if x.type == type}
    count
  end

#  # SNVP - Returns the number of reviews completed by this participant
 # Returns the number of reviews completed for a particular assignment by type of review
  # Param: type - String (ParticipantReviewResponseMap, etc.)
  def get_total_reviews_completed_by_type(type)
    # TODO A bug in Rails http://dev.rubyonrails.org/ticket/4996 prevents us from using the proper syntax :
    # self.responses.size
    response_count = 0
    self.reviews.each do |review|
      response_count = response_count + 1 if !review.response.nil? and review.type == type
    end
    response_count
  end

 # SNVP::: Returns the percentage of reviews completed as an integer (0-100)
  def get_percentage_reviews_completed_by_type(type)
    reviews = get_total_reviews_assigned_by_type(type)
    if reviews == 0 then 0
    else ((get_total_reviews_completed_by_type(type).to_f / reviews.to_f) * 100).to_i
    end
  end

  # SNVP::: Returns the number of reviewers assigned to a particular assignment
  def get_total_reviews_assigned
    self.reviews.size
  end

   def get_total_reviews_completed
    # TODO A bug in Rails http://dev.rubyonrails.org/ticket/4996 prevents us from using the proper syntax :
    # self.responses.size
    response_count = 0
    self.reviews.each do |review|
      response_count = response_count + 1 if !review.response.nil?
    end
    response_count
   end

end
