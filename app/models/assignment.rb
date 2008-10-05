class Assignment < ActiveRecord::Base
  require 'ftools'
  
  belongs_to :course 
  belongs_to :wiki_type
  belongs_to :questionnaire, :foreign_key => "review_questionnaire_id"
  belongs_to :author_feedback_questionnaire, 
             :class_name => "Questionnaire", 
             :foreign_key => "author_feedback_questionnaire_id"
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
  has_many :signup_sheets
  has_many :review_of_review_mappings
  has_many :assignments_questionnairess
  
  validates_presence_of :name
  validates_presence_of :directory_path
  validates_presence_of :review_questionnaire_id
  validates_presence_of :review_of_review_questionnaire_id
  validates_numericality_of :review_weight    
    
  def get_max_review_score
    max = 0
    Questionnaire.find(self.review_questionnaire_id).questions.each{
      max += Questionnaire.find(self.review_questionnaire_id).max_question_score
    }    
    return max.to_f
  end
  
  def get_max_feedback_score
    max = 0
    Questionnaire.find(self.author_feedback_questionnaire_id).questions.each{
      max += Questionnaire.find(self.author_feedback_questionnaire_id).max_question_score
    }    
    return max.to_f
  end
  
  def get_max_metareview_score
    max = 0
    Questionnaire.find(self.review_of_review_questionnaire_id).questions.each{
      max += Questionnaire.find(self.review_of_review_questionnaire_id).max_question_score
    }    
    return max.to_f
  end
  
  def get_max_teammate_review_score
    max = 0
    Questionnaire.find(self.teammate_review_questionnaire_id).questions.each{
      max += Questionnaire.find(self.teammate_review_questionnaire_id).max_question_score
    }    
    return max.to_f
  end
    
  def get_path
    if self.course_id == nil and self.instructor_id == nil
      raise "Path can not be created. The assignment must be associated with either a course or an instructor."
    end
    if self.wiki_type_id != 1
      raise PathError, "No path needed"
    end
    if self.course_id > 0
       path = Course.find(self.course_id).get_path
    else
       path = RAILS_ROOT + "/pg_data/" +  FileHelper.clean_path(User.find(self.instructor_id).name) + "/"
    end         
    return path + FileHelper.clean_path(self.directory_path)      
  end
    
  def get_participants
    AssignmentParticipant.find_by_sql("select participants.* from participants, users where participants.user_id = users.id and participants.type = 'AssignmentParticipant' and participants.parent_id = "+self.id.to_s+" order by users.fullname")
  end
    
  def delete_assignment
    begin
      if self.team_assignment
        teams = Team.find(:all,:conditions => ["parent_id = ?",self.id])
        teams.each {|team|
          team.delete
        }
      end  
    rescue
      raise $!
    end
      participants = AssignmentParticipant.find(:all, :conditions => ["parent_id = ?",self.id])
    begin
      participants.each {|participant| participant.delete }
    rescue
      raise $!
    end
      due_dates = DueDate.find(:all, :conditions => ['assignment_id = ?',self.id])
      
    begin
      due_dates.each{ |date| date.destroy }
    rescue
      raise $!
    end
      
    # The size of an empty directory is 2
    # Delete the directory if it is empty
    begin 
      directory = Dir.entries(RAILS_ROOT + "/pg_data/" + self.directory_path)
    rescue
      # directory does not exist
    end
    
    if !(self.wiki_type_id == 2 or self.wiki_type_id == 3) and directory != nil and directory.size == 2 
        Dir.delete(RAILS_ROOT + "/pg_data/" + self.directory_path)          
    elsif !(self.wiki_type_id == 2 or self.wiki_type_id == 3) and directory != nil and directory.size != 2
        raise "Assignment directory is not empty."
    end
    begin
      self.delete_review_mappings
    rescue
      raise $!
    end
    
    self.destroy
  end
    
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
  
  def delete_review_mappings
    review_mappings = ReviewMapping.find(:all, :conditions => ['assignment_id =?',self.id])
    review_mappings.each{
      |mapping| mapping.delete
    }
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
              :location => get_review_number(mapping).to_s,
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
  def get_review_number(mapping)
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
 
 # It appears that this method is not used at present!
 def is_wiki_assignment
   if self.wiki_type_id > 1 
     return true
   else
     return false
   end
 end
 
 def get_teams
   AssignmentTeam.find_all_by_parent_id(self.id)
 end
 
 def add_participant(user_name)
  user = User.find_by_name(user_name)
  if (user == nil) 
    raise "No user account exists with the name "+user_name+". Please <a href='"+url_for(:controller=>'users',:action=>'new')+"'>create</a> the user first."      
  end
  participant = AssignmentParticipant.find_by_parent_id_and_user_id(self.id, user.id)    
  if !participant
    AssignmentParticipant.create(:parent_id => self.id, :user_id => user.id, :permission_granted => user.master_permission_granted)
  else
    raise "The user \""+user.name+"\" is already a participant."
  end
 end 
 
 def create_node()
      parent = CourseNode.find_by_node_object_id(self.course_id)      
      node = AssignmentNode.create(:node_object_id => self.id)
      if parent != nil
        node.parent_id = parent.id       
      end
      node.save   
 end
 
 COMPLETE = "Complete"
 
 def get_current_stage()
    due_date = find_current_stage()
    if due_date == nil or due_date == COMPLETE
      return COMPLETE
    else
      return DeadlineType.find(due_date.deadline_type_id).name
    end
  end 
  
  def get_stage_deadline()
    due_date = find_current_stage()
    if due_date == nil or due_date == COMPLETE
      return due_date
    else
      return due_date.due_at.to_s
    end
  end
  
def find_current_stage()
    due_dates = DueDate.find(:all, 
                 :conditions => ["assignment_id = ?", self.id],
                 :order => "due_at DESC")
                 
    if due_dates != nil and due_dates.size > 0
      if Time.now > due_dates[0].due_at
        return COMPLETE
      else
        i = 0
        for due_date in due_dates
          if Time.now < due_date.due_at and
             (due_dates[i+1] == nil or Time.now > due_dates[i+1].due_at)
            return due_date
          end
          i = i + 1
        end
      end
    end
  end  
end
