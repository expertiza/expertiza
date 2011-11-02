class Assignment < ActiveRecord::Base

  #changes
  include DynamicReviewMapping
  include ReviewingHelper
  include ScoresHelper
  include AssignmentStageHelper

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

  def has_topics?
    @has_topics ||= !sign_up_topics.empty?
  end


  def contributors
    @contributors ||= team_assignment ? teams : participants
  end


  def is_using_dynamic_reviewer_assignment?
    if self.review_assignment_strategy == RS_AUTO_SELECTED or
       self.review_assignment_strategy == RS_STUDENT_SELECTED
      return true
    else
      return false
    end
  end


  def get_contributor(contrib_id)
    if team_assignment
      return AssignmentTeam.find(contrib_id)
    else
      return AssignmentParticipant.find(contrib_id)
    end
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
    if self.staggered_deadline?
      # next_due_date - the nearest due date that hasn't passed
      if topic_id
        # next for topic
        next_due_date = TopicDeadline.find(:first,
          :conditions => ['topic_id = ? and due_at >= ?', topic_id, Time.now],
          :order => 'due_at')
      else
        # next for assignment
        next_due_date = TopicDeadline.find(:first,
          :conditions => ['assignment_id = ? and due_at >= ?', self.id, Time.now],
          :joins => {:topic => :assignment},
          :order => 'due_at')
      end
    else
      next_due_date = DueDate.find(:first, :conditions => ['assignment_id = ? and due_at >= ?', self.id, Time.now], :order => 'due_at')
    end

    if next_due_date.nil?
      return false
    end

    # command pattern - get the attribute with the name in column
    # Here, column is usually something like 'review_allowed_id'
    right_id = next_due_date.send column

    right = DeadlineRight.find(right_id)
    return (right and (right.name == "OK" or right.name == "Late"))
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

  #has to be here only
 def is_google_doc
   # This is its own method so that it can be refactored later.
   # Google Document code should never directly check the wiki_type_id
   # and should instead always call is_google_doc.
   self.wiki_type_id == 4
 end


  #has to be here only
 def create_node()
      parent = CourseNode.find_by_node_object_id(self.course_id)
      node = AssignmentNode.create(:node_object_id => self.id)
      if parent != nil
        node.parent_id = parent.id
      end
      node.save
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
    contributors_topic = SignedUpUser.find_by_creator_id(contributor.id)
    if !contributors_topic.nil?
      contributors_signup_topic = SignUpTopic.find_by_id(contributors_topic.topic_id)
      #returns the topic
      return contributors_signup_topic
    end
  end

end
