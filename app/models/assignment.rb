class Assignment < ActiveRecord::Base
  belongs_to :course 
  belongs_to :wiki_type
  belongs_to :user, :foreign_key => "instructor_id"
  has_many :participants
  has_many :users, :through => :participants
  has_many :due_dates
  has_many :review_feedbacks
  has_many :review_mappings
  
  validates_presence_of :name
  validates_presence_of :directory_path
  #validates_presence_of :submitter_count
  #validates_presence_of :instructor_id
  #validates_presence_of :mapping_strategy_id
  validates_presence_of :review_rubric_id
  validates_presence_of :review_of_review_rubric_id
  validates_numericality_of :review_weight
  # The following fields don't need to be set; an unchecked checkbox is interpreted as "false".
  # validates_presence_of :reviews_visible_to_all
  # validates_presence_of :team_assignment
  # validates_presence_of :require_signup
  # If user doesn't specify an id for wiki type, id is 0 by default, which means "not a wiki assgt."
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
      participant.destroy
    end
  end
  

end
