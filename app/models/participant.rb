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

  def review_response_maps
    ParticipantReviewResponseMap.find_all_by_reviewee_id_and_reviewed_object_id(id, assignment.id)
  end

  def get_current_stage
    assignment.get_current_stage topic_id
  end
  alias_method :current_stage, :get_current_stage

  def get_stage_deadline
    assignment.get_stage_deadline topic_id
  end
  alias_method :stage_deadline, :get_stage_deadline

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

  # Returns the average score of all reviews for this user on this assignment (Which assignment ??? )
  def get_average_score()
    return 0 if self.response_maps.size == 0
    
    sum_of_scores = 0

    self.response_maps.each do |response_map|
      if !response_map.response.nil?  then
        sum_of_scores = sum_of_scores + response_map.response.get_average_score
      end
    end

    (sum_of_scores / self.response_maps.size).to_i
  end

    def get_average_score_per_assignment(assignment_id)
    return 0 if self.response_maps.size == 0

    sum_of_scores = 0

    self.response_maps.metareview_response_maps.each do |metaresponse_map|
      if !metaresponse_map.response.nil? && response_map == assignment_id then
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

  # Return scores that this participant for the given questions
  def get_scores(questions)
    scores = Hash.new
    scores[:participant] = self

    if self.assignment.varying_rubrics_by_round?  # for "vary rubric by rounds" feature -Yang
      self.assignment.questionnaires.each do |questionnaire|
        round = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(self.assignment.id, questionnaire.id).used_in_round
        if(round!=nil)
          questionnaire_symbol = (questionnaire.symbol.to_s+round.to_s).to_sym
        else
          questionnaire_symbol = questionnaire.symbol
        end
        scores[questionnaire_symbol] = Hash.new
        scores[questionnaire_symbol][:assessments] = questionnaire.get_assessments_for(self)
        scores[questionnaire_symbol][:scores] = Score.compute_scores(scores[questionnaire_symbol][:assessments], questions[questionnaire_symbol])
      end

    else   #not using "vary rubric by rounds" feature
      self.assignment.questionnaires.each do |questionnaire|
        scores[questionnaire.symbol] = Hash.new
        scores[questionnaire.symbol][:assessments] = questionnaire.get_assessments_for(self)

        scores[questionnaire.symbol][:scores] = Score.compute_scores(scores[questionnaire.symbol][:assessments], questions[questionnaire.symbol])
      end
    end




    scores[:total_score] = assignment.compute_total_score(scores)
    return scores
  end
end
