class Participant < ActiveRecord::Base
  has_paper_trail
  belongs_to :user
  belongs_to :topic, :class_name => 'SignUpTopic'
  belongs_to :assignment, :foreign_key => 'parent_id'

  has_many   :comments, :dependent => :destroy
  has_many   :resubmission_times, :dependent => :destroy
  has_many   :reviews, :class_name => 'ResponseMap', :foreign_key => 'reviewer_id', dependent: :destroy
  has_many   :team_reviews, :class_name => 'TeamReviewResponseMap', :foreign_key => 'reviewer_id', dependent: :destroy
  has_many :response_maps, :class_name =>'ResponseMap', :foreign_key => 'reviewee_id', dependent: :destroy

  validates_numericality_of :grade, :allow_nil => true

  delegate :course, to: :assignment

  has_paper_trail

  def get_current_stage
    assignment.try :get_current_stage, topic_id
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

    # TODO How do we test this code?  #need a controller test_oss808
    maps = ResponseMap.where(['reviewee_id = ? or reviewer_id = ?',self.id,self.id])

    if force or ((maps.nil? or maps.length == 0) and
                 self.team.nil?)
      force_delete(maps)
    else
      raise "Associations exist for this participant"
    end
    end


    def force_delete(maps)
      times = ResubmissionTime.where(participant_id: self.id);

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

    def topic_name
      if topic.nil? or topic.topic_name.empty?
        return "<center>&#8212;</center>"
      end
      return topic.topic_name
    end

    def able_to_review
      if review_allowed
        return true
      end
      return false
    end

    # email does not work. It should be made to work in the future
    def email(pw, home_page)
      user = User.find(self.user_id)
      assignment = Assignment.find(self.assignment_id)

      Mailer.sync_message(
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
      ).deliver
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
      team_members = TeamsUser.where(team_id: team_id)

      team_members.each { |team_member|
        participant = Participant.where(user_id: team_member.user_id, parent_id: assignment.id).first
        participant.update_attribute(:topic_id, topic_id)
      }
    end

    # Return scores that this participant for the given questions
    def get_scores(questions)
      scores = {}
      scores[:participant] = self
      self.assignment.questionnaires.each do |questionnaire|
        scores[questionnaire.symbol] = {}
        scores[questionnaire.symbol][:assessments] = questionnaire.get_assessments_for(self)
        scores[questionnaire.symbol][:scores] = Score.compute_scores(scores[questionnaire.symbol][:assessments], questions[questionnaire.symbol])
      end
      scores[:total_score] = assignment.compute_total_score(scores)

      scores
    end
  end
