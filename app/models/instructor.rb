class Instructor < User
  # has_many :questionnaires
  has_many :questionnaires, dependent: :nullify

  QUESTIONNAIRE = [['My questionnaires', 'list_mine'],
                   ['All public questionnaires', 'list_all']].freeze

  SIGNUPSHEET = [['My signups', 'list_mine'],
                 ['All public signups', 'list_all']].freeze

  ASSIGNMENT = [['My assignments', 'list_mine'],
                ['All public assignments', 'list_all']].freeze

  def list_all(object_type, user_id)
    # This function takes an object_type (e.g. Assignment, Course) and a user_id as inputs,
    # and returns all objects of that type where the instructor_id matches the user_id or
    # the "private" attribute is false.
    object_type.where('instructor_id = ? OR private = 0', user_id)
  end

  def list_mine(object_type, user_id)
    # This function takes an object_type and a user_id as inputs,
    # and returns all objects of that type where the instructor_id matches the user_id.
    object_type.where('instructor_id = ?', user_id)
  end

  def get(object_type, id, user_id)
    # This function takes an object_type, an id, and a user_id as inputs,
    # and returns the object of that type with the matching id where the
    # instructor_id matches the user_id or the "private" attribute is false.
    # object_type.where("id = ? AND (instructor_id = ? OR private = 0)", id, user_id).first
    object_type.find_by('id = ? AND (instructor_id = ? OR private = 0)', id, user_id)
  end

  def my_tas
    # This function returns an array of TA ids associated with courses
    # taught by the current user (who is assumed to be an instructor).
    courses = Course.where(instructor_id: id)
    ta_ids = []
    courses.each do |course|
      ta_mappings = TaMapping.where(course_id: course.id)
      ta_mappings.each { |mapping| ta_ids << mapping.ta_id } unless ta_mappings.empty?
    end
    ta_ids
  end

  def self.get_user_list(user)
    # This function takes a user object as an input, and returns
    # a list of users who have the same role as the input user and are
    # associated with courses or assignments taught by the input user.
    # The function first gets all participants associated with courses
    # taught by the user, then gets all participants associated with
    # assignments taught by the user, and then filters the participants
    # to only include those with the same role as the input user.

      participants = get_participants(user)
    user_list = filter_participants_by_role(participants, user.role)
    user_list
  end

  def self.get_participants(user)
    # get all participants
    participants = []
    courses = get_courses_for_user(user)
    assignments = get_assignments_for_user(user)
    courses.each { |course| participants << course.get_participants }
    assignments.each { |assignment| participants << assignment.participants }
    participants
  end

  def self.filter_participants_by_role(participants, role)
    # return participants filtered by role
    participants
      .reject(&:empty?)
      .flatten
      .map(&:user)
      .select { |u| role.has_all_privileges_of?(u.role) }
  end

  def self.get_courses_for_user(user)
    # Get courses for user
    Course.where(instructor_id: user.id)
  end

  def self.get_assignments_for_user(user)
    # get the assignment for the user with user.id
    Assignment.includes(:participants).where(instructor_id: user.id)
  end
end
