class Course < ApplicationRecord
  # Defines the Course model which represents a course in the application.
  enum locale: Locale.code_name_to_db_encoding
  has_many :ta_mappings, dependent: :destroy
  has_many :tas, through: :ta_mappings  # Establishes associations with other models.
  has_many :assignments, dependent: :destroy
  belongs_to :instructor, class_name: 'User', foreign_key: 'instructor_id'
  belongs_to :institution, foreign_key: 'institutions_id'
  has_many :participants, class_name: 'CourseParticipant', foreign_key: 'parent_id', dependent: :destroy
  has_many :course_teams, foreign_key: 'parent_id', dependent: :destroy
  has_one :course_node, foreign_key: 'node_object_id', dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_paper_trail
  # Validates presence of name and directory_path.
  validates :name, presence: true
  validates :directory_path, presence: true
  # Return any predefined teams associated with this course
  # Author: ajbudlon
  # Date: 7/21/2008

  # Returns any predefined teams associated with this course.
  def get_teams
    CourseTeam.where(parent_id: id)
  end

  # Returns this object's submission directory
  def path
    raise 'Path can not be created. The course must be associated with an instructor.' if instructor_id.nil?

    Rails.root + '/pg_data/' + FileHelper.clean_path(User.find(instructor_id).name) + '/' + FileHelper.clean_path(directory_path) + '/'
  end
# Returns associated participants with the course.
  def get_participants
    CourseParticipant.where(parent_id: id)
  end
# Adds a participant to the course.
  def add_participant(user_name)
    user = User.find_by(name: user_name)
    if user.nil?
      raise 'No user account exists with the name ' + user_name + ". Please <a href='" + url_for(controller: 'users', action: 'new') + "'>create</a> the user first."
    end

    participant = CourseParticipant.find_by(parent_id: id, user_id: user.id)
    if participant # If there is already a participant, raise an error. Otherwise, create it
      raise "The user #{user.name} is already a participant."
    else
      CourseParticipant.create(parent_id: id, user_id: user.id, permission_granted: user.master_permission_granted)
    end
  end
# Copies assignment participants to the course.
  def copy_assignment_participants(assignment_id)
    participants = AssignmentParticipant.where(parent_id: assignment_id)
    errors = []
    error_msg = ''
    participants.each do |participant|
      user = User.find(participant.user_id)

      begin
        add_participant(user.name)
      rescue StandardError
        errors << $ERROR_INFO
      end
    end
    if errors.any?
      errors.each do |error|
        error_msg = error_msg + '<BR/>' + error if error
      end
      raise error_msg
    end
  end
# Checks if the user is on a team associated with the assignment.
  def user_on_team?(user)
    teams = get_teams
    users = []
    teams.each do |team|
      users << team.users
    end
    users.flatten.include? user
  end

  require 'analytic/course_analytic'
  include CourseAnalytic
end
