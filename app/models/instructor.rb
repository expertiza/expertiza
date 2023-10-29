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
    object_type.where('instructor_id = ? OR private = 0', user_id)
  end

  def list_mine(object_type, user_id)
    object_type.where('instructor_id = ?', user_id)
  end

  def get(object_type, id, user_id)
    # object_type.where("id = ? AND (instructor_id = ? OR private = 0)", id, user_id).first
    object_type.find_by('id = ? AND (instructor_id = ? OR private = 0)', id, user_id)
  end

  def my_tas
    courses = Course.where(instructor_id: id)
    ta_ids = []
    courses.each do |course|
      ta_mappings = TaMapping.where(course_id: course.id)
      ta_mappings.each { |mapping| ta_ids << mapping.ta_id } unless ta_mappings.empty?
    end
    ta_ids
  end

# This method retrieves a list of users who are participants in the courses and assignments where the given user is an instructor.
def self.get_user_list(user)
  user_list = []

  # Retrieve participants from courses where the user is an instructor
  user_list.concat(get_participants_from_instructed_entities(Course, user))

  # Retrieve participants from assignments where the user is an instructor
  user_list.concat(get_participants_from_instructed_entities(Assignment.includes(:participants), user))

  # Return the list of users
  user_list
end

# This method retrieves the participants from the entities (either Course or Assignment) where the given user is an instructor.
def self.get_participants_from_instructed_entities(entity, user)
  # Get all entities where the user is an instructor
  entities = entity.where(instructor_id: user.id)

  # For each entity, get its participants and filter them based on the user's privileges
  entities.flat_map do |entity|
    # Check if the entity has a get_participants method (as in Course) or directly has a participants association (as in Assignment)
    participants = entity.respond_to?(:get_participants) ? entity.get_participants : entity.participants

    # Filter the participants based on the user's privileges
    filter_participants(participants, user)
  end
end

# This method filters a list of participants based on whether the given user has all privileges of each participant's role.
def self.filter_participants(participants, user)
  # Select only those participants whose role's privileges are all included in the user's role's privileges
  filtered_participants = participants.select do |participant|
    user.role.has_all_privileges_of?(participant.user.role)
  end

  # Map each participant to its associated user and return this list of users
  filtered_participants.map(&:user)
end

end
