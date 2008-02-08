class Assignment < ActiveRecord::Base
  belongs_to :course 
  belongs_to :wiki_type
  # wiki_type needs to be removed. When an assignment is created, it needs to
  # be created as an instance of a subclass of the Assignment (model) class;
  # then Rails will "automatically" set the type field to the value that
  # designates an assignment of the appropriate type.
  belongs_to :user, :foreign_key => "instructor_id"
  has_one :late_policy
  has_many :participants
  has_many :users, :through => :participants
  has_many :due_dates
  has_many :review_feedbacks
  has_many :review_mappings
  has_many :review_of_review_mappings
  has_many :assignments_questionnairess
  
  validates_presence_of :name
  validates_presence_of :directory_path
  #validates_presence_of :submitter_count
  #validates_presence_of :instructor_id
  #validates_presence_of :mapping_strategy_id
  validates_presence_of :review_questionnaire_id
  validates_presence_of :review_of_review_questionnaire_id
  validates_numericality_of :review_weight
  # The following fields don't need to be set; an unchecked checkbox is interpreted as "false".
  # validates_presence_of :reviews_visible_to_all
  # validates_presence_of :team_assignment
  # validates_presence_of :require_signup
  # If user doesn't specify an id for wiki type, id is 1 by default, which means "not a wiki assgt."
  #   The reason the default is 1, not 0, is because we use a dropdown box to select a wiki type,
  #   and rails _form helpers generates HTML that looks like table1_1_table2.
  # validates_presence_of :wiki_type_id
    
    
  def due_dates_exist?
    return false if due_dates == nil or due_dates.length == 0
    return true
  end
  
  def delete_due_dates
    for due_date in due_dates
      due_date.destroy
    end
  end
  
  def review_feedback_exist?
    return false if review_feedbacks == nil or review_feedbacks.length == 0
    return true
  end
  
  def delete_review_feedbacks
    for review_feedback in review_feedbacks
      review_feedback.destroy
    end
  end
  
  def participants_exist?
    return false if participants == nil or participants.length == 0
    return true
  end
  
  def delete_participants
    for participant in participants
      for resubmission_time in participant.resubmission_times
        resubmission_time.destroy
      end
      participant.destroy
    end
  end
  
  def delete_review_mapping
    for review_mapping in review_mappings
      for review in review_mapping.reviews
        for review_score in review.review_scores
          review_score.destroy
        end
        for review_feedback in review.review_feedbacks
          review_feedback.destroy
        end
        review.destroy
      end
      for review_of_review_mapping in review_mapping.review_of_review_mappings
        review_of_review_mapping.destroy
      end
      review_mapping.destroy
    end
  end

  def delete_review_of_review_mapping
    for review_of_review_mapping in review_of_review_mappings
      for review_of_review in review_of_review_mapping.review_of_reviews
        for review_of_review_score in review_of_review.review_of_review_scores
          review_of_review_score.destroy
        end
        review_of_review.destroy
      end
      for review_of_review_mapping in review_mapping.review_of_review_mappings
        review_of_review_mapping.destroy
      end
      review_of_review_mapping.destroy
    end
  end
  def delete_review_feedback
    for review_feedback in review_feedbacks
      review_feedback.destroy
    end
  end
  
  # Generate emails for reviewers when new content is available for review
  #ajbudlon, sept 07, 2007   
  def email(author_id) 
  
    # Get all review mappings for this assignment & author
    review_mappings = ReviewMapping.find_by_sql(
        "select * from review_mappings where assignment_id = " + self.id.to_s + 
        " and author_id =" + author_id.to_s
        )   
  
    for mapping in review_mappings

       # If the reviewer has requested an e-mail deliver a notification
       # that includes the assignment, and which item has been updated.
       if User.find_by_id(mapping.reviewer_id).email_on_submission
          user = User.find(mapping.reviewer_id)
          Mailer.deliver_message(
            {:recipients => user.email,
             :subject => "An new submission is available for #{self.name}",
             :body => {
              :obj_name => self.name,
              :type => "submission",
              :location => getReviewNumber(mapping).to_s,
              :first_name => ApplicationHelper::get_user_first_name(user),
              :partial_name => "update"
             }
            }
          )
       end
    end
  end
  


  # Get all review mappings for this assignment & reviewer
  # required to give reviewer location of new submission content
  # link can not be provided as it might give user ability to access data not
  # available to them.  
  #ajbudlon, sept 07, 2007      
  def getReviewNumber(mapping)
    reviewer_mappings = ReviewMapping.find_by_sql(
      "select * from review_mappings where assignment_id = " +self.id.to_s +
      " and reviewer_id = " + mapping.reviewer_id.to_s
    )
    review_num = 1
    for rm in reviewer_mappings
      if rm.author_id != mapping.author_id
        review_num += 1
      else
        break
      end
    end  
    return review_num
  end
end
