class Instructor < User
  # has_many :questionnaires
  has_many :questionnaires, dependent: :nullify

  QUESTIONNAIRE = [['My questionnaires', 'list_mine'],
                   ['All public questionnaires', 'list_all']].freeze

  SIGNUPSHEET = [['My signups', 'list_mine'],
                 ['All public signups', 'list_all']].freeze

  ASSIGNMENT = [['My assignments', 'list_mine'],
                ['All public assignments', 'list_all']].freeze

  # This method retrieves all instances of a given type (object_type) where the user (specified by user_id)
  # is the instructor or the instance is not private.
  def list_all(object_type, user_id)
    object_type.where('instructor_id = ? OR private = 0', user_id)
  end

  # This method retrieves all instances of a given type (object_type) where the user (specified by user_id) is the instructor.
  def list_mine(object_type, user_id)
    object_type.where('instructor_id = ?', user_id)
  end

  # This method retrieves a specific instance of a given type (object_type) by its ID,
  # where the user (specified by user_id) is the instructor or the instance is not private.
  def get(object_type, id, user_id)
    object_type.find_by('id = ? AND (instructor_id = ? OR private = 0)', id, user_id)
  end

  # This method retrieves a list of teaching assistant (TA) IDs associated with the courses instructed by a given user.
  def my_tas
    # Get all courses where the user is an instructor.
    courses = Course.where(instructor_id: id)
  
    # Initialize an array to store the TA IDs.
    ta_ids = courses.flat_map do |course|
      # For each course, get the TA mappings (i.e., associations between TAs and the course).
      ta_mappings = TaMapping.where(course_id: course.id)
      
      # Use 'map' to transform each TA mapping into its TA ID.
      ta_mappings.map(&:ta_id)
    end
  
    # Return the list of TA IDs.
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
