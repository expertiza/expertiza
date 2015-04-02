class Course < ActiveRecord::Base
  has_many :ta_mappings,:dependent => :destroy
  has_many :tas, through: :ta_mappings
  validates_presence_of :name
  has_many :assignments, :dependent => :destroy
  belongs_to :instructor, :class_name => 'User', :foreign_key => 'instructor_id'
  has_many :participants, :class_name => 'CourseParticipant', :foreign_key => 'parent_id'
  has_one :course_node,:foreign_key => :node_object_id,:dependent => :destroy
  has_paper_trail

  # Return any predefined teams associated with this course
  # Author: ajbudlon
  # Date: 7/21/2008
  def get_teams
    return CourseTeam.where(parent_id: self.id)
  end

  #Returns this object's submission directory
  def path
    if self.instructor_id == nil
      raise "Path can not be created. The course must be associated with an instructor."
    end
    return Rails.root + "/pg_data/" + FileHelper.clean_path(User.find(self.instructor_id).name)+ "/" + FileHelper.clean_path(self.directory_path) + "/"
  end

  def get_participants
    CourseParticipant.where(parent_id: self.id)
  end

  def get_participant (user_id)
    CourseParticipant.where(parent_id: self.id, user_id: user_id)
  end

  def add_participant(user_name)
    user = User.find_by_name(user_name)
    if (user == nil)
      raise "No user account exists with the name "+user_name+". Please <a href='"+url_for(:controller => 'users', :action => 'new')+"'>create</a> the user first."
    end
    participant = CourseParticipant.where(parent_id: self.id, user_id:  user.id).first
    unless participant # If there is already a participant, it has already been added. done. Otherwise, create it
      CourseParticipant.create(:parent_id => self.id, :user_id => user.id, :permission_granted => user.master_permission_granted)
    end
  end

  def copy_participants(assignment_id)
    participants = AssignmentParticipant.where(parent_id: assignment_id)
    errors = Array.new
    error_msg = String.new
    participants.each {
      |participant|
      user = User.find(participant.user_id)

      begin
        self.add_participant(user.name)
      rescue
        errors << $!
      end
    }
    if errors.length > 0
      errors.each {
        |error|
        if error
          error_msg = error_msg+"<BR/>"+error
        end
      }
      raise error_msg
    end
  end

  require 'analytic/course_analytic'
  include CourseAnalytic
end
