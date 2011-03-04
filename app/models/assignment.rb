class Assignment < ActiveRecord::Base
  require 'ftools'
  include DynamicReviewMapping

  belongs_to :course, :class_name => 'Course', :foreign_key => 'course_id'
  belongs_to :wiki_type
  # wiki_type needs to be removed. When an assignment is created, it needs to
  # be created as an instance of a subclass of the Assignment (model) class;
  # then Rails will "automatically" set the type field to the value that
  # designates an assignment of the appropriate type.
  has_many :participants, :class_name => 'AssignmentParticipant', :foreign_key => 'parent_id'
  has_many :users, :through => :participants
  has_many :due_dates
  has_many :teams, :class_name => 'AssignmentTeam', :foreign_key => 'parent_id'
  has_many :invitations, :class_name => 'Invitation', :foreign_key => 'assignment_id'
  has_many :assignment_questionnaires, :class_name => 'AssignmentQuestionnaires', :foreign_key => 'assignment_id'
  has_many :questionnaires, :through => :assignment_questionnaires
  belongs_to  :instructor, :class_name => 'User', :foreign_key => 'instructor_id'    
  has_many :sign_up_topics, :foreign_key => 'assignment_id', :dependent => :destroy  

  validates_presence_of :name
  validates_uniqueness_of :scope => [:directory_path, :instructor_id]

  COMPLETE = "Complete"

  #  Review Strategy information.
  RS_INSTRUCTOR_SELECTED = 'Instructor-Selected'
  RS_STUDENT_SELECTED    = 'Student-Selected'
  RS_AUTO_SELECTED       = 'Auto-Selected'
  REVIEW_STRATEGIES = [RS_INSTRUCTOR_SELECTED, RS_STUDENT_SELECTED, RS_AUTO_SELECTED]

  DEFAULT_MAX_REVIEWERS = 3

  # Here we set up the @contributors to use participants/teams polymorphically
  def after_initialize
    self.review_strategy_id = nil 
    self.mapping_strategy_id = nil
    @contributors = (team_assignment) ? teams : participants
  end
  
  def assign_reviewer_dynamically(reviewer, topic)
    candidate_contributors = find_candidate_contributors_to_review(reviewer, topic)
    raise 'There are no more available reviews at this time' if candidate_contributors.empty?
    
    
  end
  
  # Returns the array of candidate contributors to be reviewed by this reviewer
  # on this topic
  def find_candidate_contributors_to_review(reviewer, topic)
    candidate_contributors = Array.new(@contributors)
    candidate_contributors.reject! { |contributor| contributor.topic != topic }
    candidate_contributors.reject! { |contributor| contributor.includes?(reviewer) }
    return candidate_contributors
  end

  def contributors
    @contributors
  end

  def is_using_dynamic_reviewer_assignment?
    if self.review_assignment_strategy == RS_AUTO_SELECTED or
       self.review_assignment_strategy == RS_STUDENT_SELECTED
      return true
    else
      return false
    end
  end

  def review_mappings
    if team_assignment
      TeamReviewResponseMap.find_all_by_reviewed_object_id(self.id)
    else
      ParticipantReviewResponseMap.find_all_by_reviewed_object_id(self.id)
    end
  end
  
  def metareview_mappings
     mappings = Array.new
     self.review_mappings.each{
       | map |
       mmap = MetareviewResponseMap.find_by_reviewed_object_id(map.id)
       if mmap != nil
         mappings << mmap
       end
     }
     return mappings     
  end
  
  def get_scores(questions)
    scores = Hash.new
   
    scores[:participants] = Hash.new    
    self.participants.each{
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
      self.teams.each{
        | team |
        scores[:teams][index.to_s.to_sym] = Hash.new
        scores[:teams][index.to_s.to_sym][:team] = team
        assessments = TeamReviewResponseMap.get_assessments_for(team)
        scores[:teams][index.to_s.to_sym][:scores] = Score.compute_scores(assessments, questions[:review])
        index += 1
      }
    end
    return scores
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
    
  def check_condition(column,topic_id=nil)
    if !self.staggered_deadline?
      next_due_date = DueDate.find(:first, :conditions => ['assignment_id = ? and due_at >= ?',self.id,Time.now], :order => 'due_at')
    else
      next_due_date = TopicDeadline.find(:first, :conditions => ['topic_id = ? and due_at >= ?',topic_id,Time.now], :order => 'due_at')
    end

    if next_due_date.nil?
      return false
    end
    condition = 0
    next_due_date.attributes.each{
      | key, value |
      if key == column
        condition = value
      end
    }   
    
    right = DeadlineRight.find(condition)
    return (right!= nil and (right.name == "OK" or right.name == "Late"))    
  end
    
  # Determine if the next due date from now allows for submissions
  def submission_allowed(topic_id=nil)
    return (check_condition("submission_allowed_id",topic_id) or check_condition("resubmission_allowed_id",topic_id))
  end
  
  # Determine if the next due date from now allows for reviews or metareviews
  def review_allowed(topic_id=nil)
    return (check_condition("review_allowed_id",topic_id) or check_condition("rereview_allowed_id",topic_id) or self.metareview_allowed)
  end  
  
  # Determine if the next due date from now allows for metareviews
  def metareview_allowed(topic_id=nil)
    return check_condition("review_of_review_allowed_id",topic_id)
  end
    
  def delete(force = nil)
    begin
      maps = ParticipantReviewResponseMap.find_all_by_reviewed_object_id(self.id)
      maps.each{|map| map.delete(force)}
    rescue
      raise "At least one review response exists for #{self.name}."
    end
    
    begin
      maps = TeamReviewResponseMap.find_all_by_reviewed_object_id(self.id)
      maps.each{|map| map.delete(force)}
    rescue
      raise "At least one review response exists for #{self.name}."
    end
    
    begin
      maps = TeammateReviewResponseMap.find_all_by_reviewed_object_id(self.id)
      maps.each{|map| map.delete(force)}
    rescue
      raise "At least one teammate review response exists for #{self.name}."
    end
    
    self.invitations.each{|invite| invite.destroy}
    self.teams.each{| team | team.delete}
    self.participants.each {|participant| participant.delete}
    self.due_dates.each{ |date| date.destroy}   
           
    # The size of an empty directory is 2
    # Delete the directory if it is empty
    begin
      directory = Dir.entries(RAILS_ROOT + "/pg_data/" + self.directory_path)
    rescue
      # directory is empty
    end
        
    if !(self.wiki_type_id == 2 or self.wiki_type_id == 3) and directory != nil and directory.size == 2
        Dir.delete(RAILS_ROOT + "/pg_data/" + self.directory_path)          
    elsif !(self.wiki_type_id == 2 or self.wiki_type_id == 3) and directory != nil and directory.size != 2
        raise "Assignment directory is not empty."
    end 
    
    self.assignment_questionnaires.each{|aq| aq.destroy}
    
    self.destroy
  end      
  
  # Generate emails for reviewers when new content is available for review
  #ajbudlon, sept 07, 2007   
  def email(author_id) 
  
    # Get all review mappings for this assignment & author
    participant = AssignmentParticipant.find(author_id)
    if team_assignment
      author = participant.team
    else
      author = participant
    end
    
    for mapping in author.review_mappings

       # If the reviewer has requested an e-mail deliver a notification
       # that includes the assignment, and which item has been updated.
       if mapping.reviewer.user.email_on_submission
          user = mapping.reviewer.user
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
    reviewer_mappings = ResponseMap.find_all_by_reviewer_id(mapping.reviewer.id)
    review_num = 1
    for rm in reviewer_mappings
      if rm.reviewee.id != mapping.reviewee.id
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


  def get_current_stage(topic_id=nil)
    if self.staggered_deadline?
      if topic_id.nil?
        return "Unknown"
      end
    end
    due_date = find_current_stage(topic_id)
    if due_date == nil or due_date == COMPLETE
      return COMPLETE
    else
      return DeadlineType.find(due_date.deadline_type_id).name
    end
  end


  def get_stage_deadline(topic_id=nil)
     if self.staggered_deadline?
        if topic_id.nil?
          return "Unknown"
        end
     end

    due_date = find_current_stage(topic_id)
    if due_date == nil or due_date == COMPLETE
      return due_date
    else
      return due_date.due_at.to_s
    end
  end

   def get_review_rounds
    due_dates = DueDate.find_all_by_assignment_id(self.id)
    rounds = (due_dates.size - 2)/2 + 1
    if rounds < 0
       return 0
    end
    rounds
  end

  
 def find_current_stage(topic_id=nil)
    if self.staggered_deadline?
      due_dates = TopicDeadline.find(:all,
                   :conditions => ["topic_id = ?", topic_id],
                   :order => "due_at DESC")
    else
      due_dates = DueDate.find(:all,
                   :conditions => ["assignment_id = ?", self.id],
                   :order => "due_at DESC")
    end


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
  
 def assign_reviewers(mapping_strategy)  
      if (team_assignment)      
          #defined in DynamicReviewMapping module
          assign_reviewers_for_team(mapping_strategy)
      else          
          #defined in DynamicReviewMapping module
          assign_individual_reviewer(mapping_strategy) 
      end  
  end  

#this is for staggered deadline assignments or assignments with signup sheet
def assign_reviewers_staggered(num_reviews,num_review_of_reviews)
    #defined in DynamicReviewMapping module
    message = assign_reviewers_automatically(num_reviews,num_review_of_reviews)
    return message
end

  def get_current_due_date()
    #puts "~~~~~~~~~~Enter get_current_due_date()\n"
    due_date = self.find_current_stage()
    if due_date == nil or due_date == COMPLETE
      return COMPLETE
    else
      return due_date
    end
    
  end
  
  def get_next_due_date()
    #puts "~~~~~~~~~~Enter get_next_due_date()\n"
    due_date = self.find_next_stage()
    
    if due_date == nil or due_date == COMPLETE
      return nil
    else
      return due_date
    end
    
  end
  
  def find_next_stage()
    #puts "~~~~~~~~~~Enter find_next_stage()\n"
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
             if (i > 0)
               return due_dates[i-1]
             else
               return nil  
             end
          end
          i = i + 1
        end
        
        return nil
      end
    end
    end
end
  