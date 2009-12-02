class Assignment < ActiveRecord::Base
  require 'ftools'
  belongs_to :course
  belongs_to :wiki_type
   # wiki_type needs to be removed. When an assignment is created, it needs to
  # be created as an instance of a subclass of the Assignment (model) class;
  # then Rails will "automatically" set the type field to the value that
  # designates an assignment of the appropriate type.
  has_many :participants  
  has_many :users, :through => :participants
  has_many :due_dates
  
  has_many :assignment_questionnaires, :class_name => 'AssignmentQuestionnaires', :foreign_key => 'assignment_id'
  has_many :questionnaires, :through => :assignment_questionnaires
    
  validates_presence_of :name
  validates_uniqueness_of :scope => [:directory_path, :instructor_id]
    
  COMPLETE = "Complete"
  
  def get_scores(questions)
    scores = Hash.new
   
    scores[:participants] = Hash.new    
    self.get_participants.each{
      | participant |
      scores[:participants][participant.id.to_s.to_sym] = Hash.new
      scores[:participants][participant.id.to_s.to_sym][:participant] = participant
      questionnaires.each{
        | questionnaire |
        scores[:participants][participant.id.to_s.to_sym][questionnaire.symbol] = Hash.new
        scores[:participants][participant.id.to_s.to_sym][questionnaire.symbol][:assessments] = questionnaire.get_assessments_for(participant)
        scores[:participants][participant.id.to_s.to_sym][questionnaire.symbol][:scores] = Score.compute_scores(scores[:participants][participant.id.to_s.to_sym][questionnaire.symbol][:assessments], questions[questionnaire.symbol])        
      } 
      scores[:participants][participant.id.to_s.to_sym][:total_score] = participant.compute_total_score(scores[:participants][participant.id.to_s.to_sym])
    }        
    
    if self.team_assignment
      scores[:teams] = Hash.new
      index = 0
      self.get_teams.each{
        | team |
        scores[:teams][index.to_s.to_sym] = Hash.new
        scores[:teams][index.to_s.to_sym][:team] = team
        assessments = Review.get_assessments_for(team)
        scores[:teams][index.to_s.to_sym][:scores] = Score.compute_scores(assessments, questions[:review])
        index += 1
      }
    end
    return scores
  end
   
  def after_initialize
    self.review_strategy_id = nil 
    self.mapping_strategy_id = nil
  end
  
  def compute_scores
    scores = Hash.new
    questionnaires = self.questionnaires
    
    self.participants.each{
      | participant |
      pScore = Hash.new
      pScore[:id] = participant.id
      
      
      scores << pScore
    }
  end
  
  
  def get_contributor(contrib_id)
    if team_assignment
      return AssignmentTeam.find(contrib_id)
    else
      return AssignmentParticipant.find(contrib_id)
    end
  end
   
  # parameterized by questionnaire
  def get_max_score_possible(questionnaire)
    max = 0
    sum_of_weights = 0
    num_questions = 0
    questionnaire.questions.each { |question| #type identifies the type of questionnaire  
      sum_of_weights += question.weight
      num_questions+=1
    }
    max = num_questions * questionnaire.max_question_score * sum_of_weights
    return max, sum_of_weights
  end
    
  def get_path
    if self.course_id == nil and self.instructor_id == nil
      raise "Path can not be created. The assignment must be associated with either a course or an instructor."
    end
    if self.wiki_type_id != 1
      raise PathError, "No path needed"
    end
    if self.course_id != nil && self.course_id > 0
       path = Course.find(self.course_id).get_path
    else
       path = RAILS_ROOT + "/pg_data/" +  FileHelper.clean_path(User.find(self.instructor_id).name) + "/"
    end         
    return path + FileHelper.clean_path(self.directory_path)      
  end
  
  def get_next_due_date(allowance_type)
    query = 'assignment_id = ? and due_at > ? and ('+allowance_type+' IN (SELECT id FROM deadline_rights WHERE name in ("Late","OK")))'
    DueDate.find(:first, :conditions => [query,self.id,Time.now])    
  end
    
  # Determine if the next due date from now allows for submissions
  def submission_allowed    
    due_date1 = get_next_due_date("submission_allowed_id")
    due_date2 = get_next_due_date("resubmission_allowed_id")    
    
    return (due_date1 != nil or due_date2 != nil)
  end
  
  # Determine if the next due date from now allows for reviews or metareviews
  def review_allowed
    due_date1 = get_next_due_date("review_allowed_id")
    due_date2 = get_next_due_date("rereview_allowed_id")
    
    return (due_date1 != nil or due_date2 != nil or self.metareview_allowed)     
  end  
  
  # Determine if the next due date from now allows for metareviews
  def metareview_allowed    
    due_date = get_next_due_date("review_of_review_allowed_id")
    
    return (due_date != nil)      
  end
    
  def get_participants
    AssignmentParticipant.find(:all, :include => :user, :conditions => ['participants.parent_id = ?',self.id], :order => 'users.fullname')
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
    
    #delete notifcation limits
    limits = NotificationLimit.find_all_by_assignment_id(self.id)
    begin
      limits.each {|limit| limit.destroy}
    rescue 
      rase $!
    end
    
    #delete weights limits
    weights = QuestionnaireWeight.find_all_by_assignment_id(self.id)
    begin
      weights.each {|limit| limit.destroy}
    rescue 
      rase $!
    end    
    
    due_dates = DueDate.find(:all, :conditions => ['assignment_id = ?',self.id])
    
    begin
      due_dates.each{ |date| date.destroy }
    rescue
      raise $!
    end
  
      review_feedbacks = ReviewFeedback.find(:all, :conditions => ['assignment_id = ?',self.id])
      begin
      review_feedbacks.each{ |review| review.destroy }
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
    review_mappings = ReviewMapping.find_all_by_reviewee_id_and_reviewed_object_id(author_id, self.id)    
    for mapping in review_mappings

       # If the reviewer has requested an e-mail deliver a notification
       # that includes the assignment, and which item has been updated.
       if mapping.reviewer.user.email_on_submission
          user = mapping.reviwer.user
          Mailer.deliver_message(
            {:recipients => user.email,
             :subject => "A new submission is available for #{self.name}",
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
 
 #
 def self.is_submission_possible (assignment)
    # Is it possible to upload a file?
    # Check whether the directory text box is nil
    if assignment.directory_path != nil && assignment.wiki_type == 1      
      return true   
      # Is it possible to submit a URL (or a wiki page)
    elsif assignment.directory_path != nil && /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix.match(assignment.directory_path)
        # In this case we have to check if the directory_path starts with http / https.
        return true
    # Is it possible to submit a Google Doc?
#    removed because google doc not implemented
#    elsif assignment.wiki_type == 4 #GOOGLE_DOC
#      return true
    else
      return false
    end
 end
 
 def is_google_doc
   # This is its own method so that it can be refactored later.
   # Google Document code should never directly check the wiki_type_id
   # and should instead always call is_google_doc.
   self.wiki_type_id == 4
 end

 
 def get_teams
   AssignmentTeam.find(:all, :conditions => ['parent_id = ?',self.id], :order => 'name')
 end
 
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
 
 def create_node()
      parent = CourseNode.find_by_node_object_id(self.course_id)      
      node = AssignmentNode.create(:node_object_id => self.id)
      if parent != nil
        node.parent_id = parent.id       
      end
      node.save   
 end
 
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
