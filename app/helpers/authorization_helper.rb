module AuthorizationHelper

  # E1915 TODO populate with helper methods using session[:user] to make decisions
  # E1915 TODO each and every method defined here should be thoroughly tested in spec/helpers/authorization_helper_spec.rb
  # E1915 TODO search the code for "E1915 TODO" for some areas that need support from this module

  # Notes:
  # We use session directly instead of current_role_name and the like
  # Because helpers do not seem to have access to the methods defined in app/controllers/application_controller.rb

  # PUBLIC METHODS

  # Determine if the currently logged-in user has the privileges of a Super-Admin
  def current_user_has_super_admin_privileges?
    current_user_has_privileges_of?('Super-Administrator')
  end

  # Determine if the currently logged-in user has the privileges of an Admin (or higher)
  def current_user_has_admin_privileges?
    current_user_has_privileges_of?('Administrator')
  end

  # Determine if the currently logged-in user has the privileges of an Instructor (or higher)
  def current_user_has_instructor_privileges?
    current_user_has_privileges_of?('Instructor')
  end

  # Determine if the currently logged-in user has the privileges of a TA (or higher)
  def current_user_has_ta_privileges?
    current_user_has_privileges_of?('Teaching Assistant')
  end

  # Determine if the currently logged-in user has the privileges of a Student (or higher)
  def current_user_has_student_privileges?
    current_user_has_privileges_of?('Student')
  end

  # Determine if the currently logged-in user is participating in an Assignment. This method takes 1 argument, either
  # an AssignmentTeam ID or an AssignmentParticipant ID. The default value for both arguments is false
  # Usage: current_user_is_assignment_participant?(assignment_team_id: <id>) or
  # current_user_is_assignment_participant?(assignment_participant_id: <id>)
  def current_user_is_assignment_participant?(assignment_team_id: false, assignment_participant_id: false)
    if assignment_team_id
      team = AssignmentTeam.find_by(id: assignment_team_id)
      if team && session[:user]
        participant = AssignmentParticipant.find_by(parent_id: team.assignment.id, user_id: current_user_id)
      end
      participant ? (return true) : (return false)
    end

    if assignment_participant_id
      participant = AssignmentParticipant.find_by(id: assignment_participant_id)
      if participant
        current_user_has_id?(participant.user_id) ? (return true) : (return false)
      end
    end
    false
  end

  def current_user_teaching_staff_of_assignment?(assignment_id)
    assignment = Assignment.find(assignment_id)
    session[:user] &&
        (
          assignment.course_id && Course.find(assignment.course_id).instructor_id == current_user_id ||
          assignment.instructor_id == current_user_id ||
          TaMapping.exists?(ta_id: current_user_id, course_id: assignment.course_id)
        )
  end

  # Determine if the currently logged-in user IS of the given role name
  # If there is no currently logged-in user simply return false
  # parameter role_name should be one of: 'Student', 'Teaching Assistant', 'Instructor', 'Administrator', 'Super-Administrator'
  def current_user_is_a?(role_name)
    session[:user] && session[:user].role ? session[:user].role.name == role_name : false
  end

  # Determine if the current user has the passed in id value
  # parameter id can be integer or string
  def current_user_has_id?(id)
    session[:user] ? session[:user].id.eql?(id.to_i) : false
  end

  # Determine if the currently logged-in user created the bookmark with the given ID
  # If there is no currently logged-in user (or that user has no ID) simply return false
  # Bookmark ID can be passed as string or number
  # If the bookmark is not found, simply return false
  def current_user_created_bookmark_id?(bookmark_id)
    return false unless current_user_id
    return false unless bookmark_id
    Bookmark.find(bookmark_id.to_i).user_id == current_user_id
  rescue ActiveRecord::RecordNotFound
    return false
  end

  # Determine if the given user can submit work
  def given_user_can_submit?(user_id)
    given_user_can?(user_id, 'submit')
  end

  # Determine if the given user can review work
  def given_user_can_review?(user_id)
    given_user_can?(user_id, 'review')
  end

  # Determine if the given user can take quizzes
  def given_user_can_take_quiz?(user_id)
    given_user_can?(user_id, 'take_quiz')
  end

  # Determine if the given user can read work
  def given_user_can_read?(user_id)
    # Note that the ability to read is in the model as can_take_quiz
    # Per Dr. Gehringer, "I believe that 'can_take_quiz' means that the participant is a reader,
    # but please check the code to verify".
    # This was verified in the Participant model
    given_user_can_take_quiz?(user_id)
  end

  # PRIVATE METHODS
  private

  # Determine if the currently logged-in user has the privileges of the given role name (or higher privileges)
  # Let the Role model define this logic for the sake of DRY
  # If there is no currently logged-in user simply return false
  def current_user_has_privileges_of?(role_name)
    session[:user] && session[:user].role ? session[:user].role.hasAllPrivilegesOf(Role.find_by(name: role_name)) : false
  end

  # Get the ID of the currently logged-in user
  # Return -1 if there is no currently logged-in user
  # Return -1 if the currently logged-in user has no id
  # This is done instead of returning nil to be very explicit and avoid matching to records which have nil user ID
  def current_user_id
    (session[:user] && session[:user].id) ? session[:user].id : -1
  end

  # Determine if the given user is a participant of some kind
  # who is allowed to perform the given action ("submit", "review", "take_quiz")
  def given_user_can?(user_id, action)
    participant = Participant.find_by(id: user_id)
    return false if participant.nil?
    case action
    when 'submit'
      participant.can_submit
    when 'review'
      participant.can_review
    when 'take_quiz'
      participant.can_take_quiz
    else
      raise "Did not recognize user action '" + action + "'"
    end
  end

end
