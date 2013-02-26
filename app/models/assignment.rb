class Assignment < ActiveRecord::Base
  include DynamicReviewMapping

  belongs_to :course
  belongs_to :wiki_type
  # wiki_type needs to be removed. When an assignment is created, it needs to
  # be created as an instance of a subclass of the Assignment (model) class;
  # then Rails will "automatically" set the type field to the value that
  # designates an assignment of the appropriate type.
  has_many :participants, :class_name => 'AssignmentParticipant', :foreign_key => 'parent_id'
  has_many :participant_review_mappings, :class_name => 'ParticipantReviewResponseMap', :through => :participants, :source => :review_mappings
  has_many :users, :through => :participants
  has_many :due_dates
  has_many :teams, :class_name => 'AssignmentTeam', :foreign_key => 'parent_id'
  has_many :team_review_mappings, :class_name => 'TeamReviewResponseMap', :through => :teams, :source => :review_mappings
  has_many :invitations, :class_name => 'Invitation', :foreign_key => 'assignment_id'
  has_many :assignment_questionnaires
  has_many :questionnaires, :through => :assignment_questionnaires
  belongs_to  :instructor, :class_name => 'User', :foreign_key => 'instructor_id'    
  has_many :sign_up_topics, :foreign_key => 'assignment_id', :dependent => :destroy  
  has_many :response_maps, :foreign_key => 'reviewed_object_id', :class_name => 'ResponseMap'
  # TODO A bug in Rails http://dev.rubyonrails.org/ticket/4996 prevents us from using this:
  # has_many :responses, :through => :response_maps, :source => 'response'

  validates_presence_of :name
  validates_uniqueness_of :scope => [:directory_path, :instructor_id]

  COMPLETE = "Complete"

  #  Review Strategy information.
  RS_INSTRUCTOR_SELECTED = 'Instructor-Selected'
  RS_STUDENT_SELECTED    = 'Student-Selected'
  RS_AUTO_SELECTED       = 'Auto-Selected'
  REVIEW_STRATEGIES = [RS_INSTRUCTOR_SELECTED, RS_STUDENT_SELECTED, RS_AUTO_SELECTED]

  DEFAULT_MAX_REVIEWERS = 3

  # Returns a set of topics that can be reviewed.
  # We choose the topics if one of its submissions has received the fewest reviews so far
  def candidate_topics_to_review
    return nil if sign_up_topics.empty?   # This is not a topic assignment
    
    contributor_set = Array.new(contributors)
    
    # Reject contributors that have not selected a topic, or have no submissions
    contributor_set.reject! { |contributor| signed_up_topic(contributor).nil? or !contributor.has_submissions? }
    
    # Reject contributions of topics whose deadline has passed
    contributor_set.reject! { |contributor| contributor.assignment.get_current_stage(signed_up_topic(contributor).id) == "Complete" or
                                            contributor.assignment.get_current_stage(signed_up_topic(contributor).id) == "submission" }
    # Filter the contributors with the least number of reviews
    # (using the fact that each contributor is associated with a topic)
    contributor = contributor_set.min_by { |contributor| contributor.review_mappings.count }

    min_reviews = contributor.review_mappings.count rescue 0
    contributor_set.reject! { |contributor| contributor.review_mappings.count > min_reviews + review_topic_threshold }
    
    candidate_topics = Set.new
    contributor_set.each { |contributor| candidate_topics.add(signed_up_topic(contributor)) }
    candidate_topics
  end

  def has_topics?
    @has_topics ||= !sign_up_topics.empty?
  end

  def assign_reviewer_dynamically(reviewer, topic)
    # The following method raises an exception if not successful which 
    # has to be captured by the caller (in review_mapping_controller)
    contributor = contributor_to_review(reviewer, topic)
    
    contributor.assign_reviewer(reviewer)
  end
  
  # Returns a contributor to review if available, otherwise will raise an error
  def contributor_to_review(reviewer, topic)
    raise "Please select a topic" if has_topics? and topic.nil?
    raise "This assignment does not have topics" if !has_topics? and topic
    
    # This condition might happen if the reviewer waited too much time in the
    # select topic page and other students have already selected this topic.
    # Another scenario is someone that deliberately modifies the view.
    if topic
      raise "This topic has too many reviews; please select another one." unless candidate_topics_to_review.include?(topic)
    end
    
    contributor_set = Array.new(contributors)
    work = (topic.nil?) ? 'assignment' : 'topic'

    # 1) Only consider contributors that worked on this topic; 2) remove reviewer as contributor
    # 3) remove contributors that have not submitted work yet
    contributor_set.reject! do |contributor| 
      signed_up_topic(contributor) != topic or # both will be nil for assignments with no signup sheet
        contributor.includes?(reviewer) or
        !contributor.has_submissions?
    end
    raise "There are no more submissions to review on this #{work}." if contributor_set.empty?

    # Reviewer can review each contributor only once 
    contributor_set.reject! { |contributor| contributor.reviewed_by?(reviewer) }
    raise "You have already reviewed all submissions for this #{work}." if contributor_set.empty?

    # Reduce to the contributors with the least number of reviews ("responses") received
    min_contributor = contributor_set.min_by { |a| a.responses.count }
    min_reviews = min_contributor.responses.count
    contributor_set.reject! { |contributor| contributor.responses.count > min_reviews }

    # Pick the contributor whose most recent reviewer was assigned longest ago
    if min_reviews > 0
      # Sort by last review mapping id, since it reflects the order in which reviews were assigned
      # This has a round-robin effect
      # Sorting on id assumes that ids are assigned sequentially in the db.
      # .last assumes the database returns rows in the order they were created.
      # Added unit tests to ensure these conditions are both true with the current database.
      contributor_set.sort! { |a, b| a.review_mappings.last.id <=> b.review_mappings.last.id }
  end

    # Choose a contributor at random (.sample) from the remaining contributors.
    # Actually, we SHOULD pick the contributor who was least recently picked.  But sample
    # is much simpler, and probably almost as good, given that even if the contributors are
    # picked in round-robin fashion, the reviews will not be submitted in the same order that
    # they were picked.
    return contributor_set.sample
  end

  def contributors
    @contributors ||= team_assignment ? teams : participants
  end

  def review_mappings
    @review_mappings ||= team_assignment ? team_review_mappings : participant_review_mappings
  end

  def assign_metareviewer_dynamically(metareviewer)
    # The following method raises an exception if not successful which 
    # has to be captured by the caller (in review_mapping_controller)
    response_map = response_map_to_metareview(metareviewer)
    
    response_map.assign_metareviewer(metareviewer)
  end

  # Returns a review (response) to metareview if available, otherwise will raise an error
  def response_map_to_metareview(metareviewer)
    response_map_set = Array.new(review_mappings)

    # Reject response maps without responses
    response_map_set.reject! { |response_map| !response_map.response }
    raise "There are no reviews to metareview at this time for this assignment." if response_map_set.empty?

    # Reject reviews where the metareviewer was the reviewer or the contributor
    response_map_set.reject! do |response_map| 
      (response_map.reviewee == metareviewer) or (response_map.reviewer.includes?(metareviewer))
    end
    raise "There are no more reviews to metareview for this assignment." if response_map_set.empty?

    # Metareviewer can only metareview each review once
    response_map_set.reject! { |response_map| response_map.metareviewed_by?(metareviewer) }
    raise "You have already metareviewed all reviews for this assignment." if response_map_set.empty?

    # Reduce to the response maps with the least number of metareviews received
    response_map_set.sort! { |a, b| a.metareview_response_maps.count <=> b.metareview_response_maps.count }
    min_metareviews = response_map_set.first.metareview_response_maps.count
    response_map_set.reject! { |response_map| response_map.metareview_response_maps.count > min_metareviews }

    # Reduce the response maps to the reviewers with the least number of metareviews received
    reviewers = Hash.new    # <reviewer, number of metareviews>
    response_map_set.each do |response_map|
      reviewer = response_map.reviewer
      reviewers.member?(reviewer) ? reviewers[reviewer] += 1 : reviewers[reviewer] = 1
    end
    reviewers = reviewers.sort { |a, b| a[1] <=> b[1] }
    min_metareviews = reviewers.first[1]
    reviewers.reject! { |reviewer| reviewer[1] == min_metareviews }
    response_map_set.reject! { |response_map| reviewers.member?(response_map.reviewer) }

    # Pick the response map whose most recent metareviewer was assigned longest ago
    response_map_set.sort! { |a, b| a.metareview_response_maps.count <=> b.metareview_response_maps.count }
    min_metareviews = response_map_set.first.metareview_response_maps.count
    if min_metareviews > 0
      # Sort by last metareview mapping id, since it reflects the order in which reviews were assigned
      # This has a round-robin effect
      response_map_set.sort! { |a, b| a.metareview_response_maps.last.id <=> b.metareview_response_maps.last.id }
    end

    # The first review_map is the best candidate to metareview
    return response_map_set.first
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
      scores[:participants][participant.id.to_s.to_sym][:total_score] = compute_total_score(scores[:participants][participant.id.to_s.to_sym])
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
        #... = ScoreCache.get_participant_score(team, id, questionnaire.display_type)
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
    
  # Check whether review, metareview, etc.. is allowed
  # If topic_id is set, check for that topic only. Otherwise, check to see if there is any topic which can be reviewed(etc) now
  def check_condition(column,topic_id=nil)
    # the drop topic deadline should not play any role in picking the next due date
    # get the drop_topic_deadline_id to exclude it 
    drop_topic_deadline_id = DeadlineType.find_by_name("drop_topic").id
    if self.staggered_deadline?
      # next_due_date - the nearest due date that hasn't passed
      if topic_id
        # next for topic
        next_due_date = TopicDeadline.find(:first, :conditions => ['topic_id = ? and due_at >= ? and deadline_type_id <> ?', topic_id, Time.now, drop_topic_deadline_id], :order => 'due_at')
      else
        # next for assignment
        next_due_date = TopicDeadline.find(:first, :conditions => ['assignment_id = ? and due_at >= ? and deadline_type_id <> ?', self.id, Time.now, drop_topic_deadline_id], :joins => {:topic => :assignment}, :order => 'due_at')
      end
    else
      next_due_date = DueDate.find(:first, :conditions => ['assignment_id = ? and due_at >= ? and deadline_type_id <> ?', self.id, Time.now, drop_topic_deadline_id], :order => 'due_at')
    end

    if next_due_date.nil?
      return false
    end

    # command pattern - get the attribute with the name in column
    # Here, column is usually something like 'review_allowed_id'

    right_id = next_due_date.send column

    right = DeadlineRight.find(right_id)
    #puts "DEBUG RIGHT_ID = " + right_id.to_s
    #puts "DEBUG RIGHT = " + right.name
    return (right and (right.name == "OK" or right.name == "Late"))    
  end
    
  # Determine if the next due date from now allows for submissions
  def submission_allowed(topic_id=nil)
    return (check_condition("submission_allowed_id",topic_id) or check_condition("resubmission_allowed_id",topic_id))
  end
  
  # Determine if the next due date from now allows for reviews
  def review_allowed(topic_id=nil)
    return (check_condition("review_allowed_id",topic_id) or check_condition("rereview_allowed_id",topic_id))
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
       
    if !is_wiki_assignment and !self.directory_path.empty? and !directory.nil?
      if directory.size == 2
        Dir.delete(RAILS_ROOT + "/pg_data/" + self.directory_path)
      else
        raise "Assignment directory is not empty"
      end
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
   return (self.wiki_type_id > 1)
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
    rounds = 0
    for i in (0 .. due_dates.length-1)
      deadline_type = DeadlineType.find(due_dates[i].deadline_type_id)
      if deadline_type.name == "review" || deadline_type.name == "rereview"
        rounds = rounds + 1
      end
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
    due_date = self.find_current_stage()
    if due_date == nil or due_date == COMPLETE
      return COMPLETE
    else
      return due_date
    end
    
  end


  # Returns hash review_scores[reviewer_id][reviewee_id] = score
  def compute_reviews_hash
    review_questionnaire_id = get_review_questionnaire_id()
    @questions = Question.find(:all, :conditions =>["questionnaire_id = ?", review_questionnaire_id])
    @review_scores = Hash.new
    if (self.team_assignment)
      @response_type = "TeamReviewResponseMap"
    else
      @response_type = "ParticipantReviewResponseMap"
    end


    @myreviewers = ResponseMap.find(:all,:select => "DISTINCT reviewer_id", :conditions => ["reviewed_object_id = ? and type = ? ", self.id, @type] )

    @response_maps=ResponseMap.find(:all, :conditions =>["reviewed_object_id = ? and type = ?", self.id, @response_type])
    for response_map in @response_maps
      # Check if response is there
      @corresponding_response = Response.find(:first, :conditions =>["map_id = ?", response_map.id])
      @respective_scores = Hash.new
      if (@review_scores[response_map.reviewer_id] != nil)
        @respective_scores = @review_scores[response_map.reviewer_id]
      end
      if (@corresponding_response != nil)
        @this_review_score_raw = Score.get_total_score(:response => @corresponding_response, :questions => @questions, :q_types => Array.new)
        if(@this_review_score_raw >= 0.0)
          @this_review_score = ((@this_review_score_raw*100).round/100.0)
        end
      else
        @this_review_score = 0.0
      end
      @respective_scores[response_map.reviewee_id] = @this_review_score
      @review_scores[response_map.reviewer_id] = @respective_scores
    end
    return @review_scores
  end

  
  def get_review_questionnaire_id()
    @revqids = []

    @revqids = AssignmentQuestionnaire.find(:all, :conditions => ["assignment_id = ?",self.id])
    @revqids.each do |rqid|
      rtype = Questionnaire.find(rqid.questionnaire_id).type
      if( rtype == "ReviewQuestionnaire")
        @review_questionnaire_id = rqid.questionnaire_id
      end

    end
    return @review_questionnaire_id
  end

  def get_next_due_date()
    due_date = self.find_next_stage()
    
    if due_date == nil or due_date == COMPLETE
      return nil
    else
      return due_date
    end
    
  end
  
  def find_next_stage()
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
          
  # Returns the number of reviewers assigned to a particular assignment
  def get_total_reviews_assigned
    self.response_maps.size
  end

  # get_total_reviews_assigned_by_type()
  # Returns the number of reviewers assigned to a particular assignment by the type of review
  # Param: type - String (ParticipantReviewResponseMap, etc.)
  def get_total_reviews_assigned_by_type(type)
    count = 0
    self.response_maps.each { |x| count = count + 1 if x.type == type}
    count
  end

  # Returns the number of reviews completed for a particular assignment
  def get_total_reviews_completed
    # TODO A bug in Rails http://dev.rubyonrails.org/ticket/4996 prevents us from using the proper syntax :
    # self.responses.size

    response_count = 0
    self.response_maps.each do |response_map|
      response_count = response_count + 1 unless response_map.response.nil?
    end

    response_count
  end

  # Returns the number of reviews completed for a particular assignment by type of review
  # Param: type - String (ParticipantReviewResponseMap, etc.)
  def get_total_reviews_completed_by_type(type)
    # TODO A bug in Rails http://dev.rubyonrails.org/ticket/4996 prevents us from using the proper syntax :
    # self.responses.size

    response_count = 0
    self.response_maps.each do |response_map|
      response_count = response_count + 1 if !response_map.response.nil? and response_map.type == type
    end

    response_count
  end

  # Returns the number of reviews completed for a particular assignment by type of review
  # Param: type - String (ParticipantReviewResponseMap, etc.)
  # Param: date - Filter reviews that were not created on this date
  def get_total_reviews_completed_by_type_and_date(type, date)
    # TODO A bug in Rails http://dev.rubyonrails.org/ticket/4996 prevents us from using the proper syntax :
    # self.responses.size

    response_count = 0
    self.response_maps.each do |response_map|
      if !response_map.response.nil? and response_map.type == type
        if (response_map.response.created_at.to_datetime.to_date <=> date) == 0 then
          response_count = response_count + 1
        end
      end
    end

    response_count
  end

  # Returns the percentage of reviews completed as an integer (0-100)
  def get_percentage_reviews_completed
    if get_total_reviews_assigned == 0 then 0
    else ((get_total_reviews_completed().to_f / get_total_reviews_assigned.to_f) * 100).to_i
    end
  end

  # Returns the average of all responses for this assignment as an integer (0-100)
  def get_average_score
    return 0 if get_total_reviews_assigned == 0
    
    sum_of_scores = 0

    self.response_maps.each do |response_map|
      if !response_map.response.nil? then
        sum_of_scores = sum_of_scores + response_map.response.get_average_score
      end
    end

    (sum_of_scores / get_total_reviews_completed).to_i
  end

  def get_score_distribution
    distribution = Array.new(101, 0)
    
    self.response_maps.each do |response_map|
      if !response_map.response.nil? then
        score = response_map.response.get_average_score.to_i
        distribution[score] += 1 if score >= 0 and score <= 100
      end
    end
      
    distribution
  end

  # Compute total score for this assignment by summing the scores given on all questionnaires.
  # Only scores passed in are included in this sum.
  def compute_total_score(scores)
    total = 0
    self.questionnaires.each do |questionnaire|
      total += questionnaire.get_weighted_score(self, scores)
    end
    return total
  end
  
  # Checks whether there are duplicate assignments of the same name by the same instructor.
  # If the assignments are assigned to courses, it's OK to have duplicate names in different
  # courses.
  def duplicate_name?
    if course
      Assignment.find(:all, :conditions => ['course_id = ? and instructor_id = ? and name = ?', 
        course_id, instructor_id, name]).count > 1
    else
      Assignment.find(:all, :conditions => ['instructor_id = ? and name = ?', 
        instructor_id, name]).count > 1
    end
  end
  
  def signed_up_topic(contributor)
    # The purpose is to return the topic that the contributor has signed up to do for this assignment.
    # Returns a record from the sign_up_topic table that gives the topic_id for which the contributor has signed up
    # Look for the topic_id where the creator_id equals the contributor id (contributor is a team or a participant)
    if !Team.find_by_name_and_id(contributor.name, contributor.id).nil?
      contributors_topic = SignedUpUser.find_by_creator_id(contributor.id)
    else
      contributors_topic = SignedUpUser.find_by_creator_id(contributor.user_id)
    end
    if !contributors_topic.nil?
      contributors_signup_topic = SignUpTopic.find_by_id(contributors_topic.topic_id)
      #returns the topic
      return contributors_signup_topic
    end
  end
  def self.export(csv, parent_id, options)
    @assignment = Assignment.find(parent_id)
    @questions = Hash.new
    questionnaires = @assignment.questionnaires
    questionnaires.each {
        |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    }
    @scores = @assignment.get_scores(@questions)

    if(@scores[:teams].nil?)
      return csv
    end

    for index in 0 .. @scores[:teams].length - 1
      team = @scores[:teams][index.to_s.to_sym]
      for participant in team[:team].get_participants
        pscore = @scores[:participants][participant.id.to_s.to_sym]
        tcsv = Array.new
        tcsv << 'team'+index.to_s

        if (options["team_score"] == "true")
          if (team[:scores])
            tcsv.push(team[:scores][:max], team[:scores][:avg], team[:scores][:min], participant.fullname)
          else
            tcsv.push('---', '---', '---')
          end
        end

        if (options["submitted_score"])
          if (pscore[:review])
            tcsv.push(pscore[:review][:scores][:max], pscore[:review][:scores][:min], pscore[:review][:scores][:avg])
          else
            tcsv.push('---', '---', '---')
          end
        end

        if (options["metareview_score"])
          if (pscore[:metareview])
            tcsv.push(pscore[:metareview][:scores][:max], pscore[:metareview][:scores][:min], pscore[:metareview][:scores][:avg])
          else
            tcsv.push('---', '---', '---')
          end
        end

        if (options["author_feedback_score"])
          if (pscore[:feedback])
            tcsv.push(pscore[:feedback][:scores][:max], pscore[:feedback][:scores][:min], pscore[:feedback][:scores][:avg])
          else
            tcsv.push('---', '---', '---')
          end
        end

        if (options["teammate_review_score"])
          if (pscore[:teammate])
            tcsv.push(pscore[:teammate][:scores][:max], pscore[:teammate][:scores][:min], pscore[:teammate][:scores][:avg])
          else
            tcsv.push('---', '---', '---')
          end
        end

        tcsv.push(pscore[:total_score])
        csv << tcsv
      end
    end
  end

  def self.get_export_fields(options)
    fields = Array.new
    fields << "Team Name"

        if (options["team_score"] == "true")
            fields.push("Team Max", "Team Avg", "Team Min")
        end

        if (options["submitted_score"])
            fields.push("Submitted Max", "Submitted Avg", "Submitted Min")
        end

        if (options["metareview_score"])
            fields.push("Metareview Max", "Metareview Avg", "Metareview Min")
        end

        if (options["author_feedback_score"])
            fields.push("Author Feedback Max", "Author Feedback Avg", "Author Feedback Min")
        end

        if (options["teammate_review_score"])
            fields.push("Teammate Review Max", "Teammate Review Avg", "Teammate Review Min")
        end

        fields.push("Final Score")

    return fields
  end
end
