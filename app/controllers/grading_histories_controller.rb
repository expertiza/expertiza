class GradingHistoriesController < ApplicationController
  include AuthorizationHelper
  before_action :set_grading_history, only: %i[show]

  def action_allowed?
    # Check if the current user has admin privileges, they are always allowed
    return true if current_user_has_admin_privileges?
  
    # Populate assignment fields based on the grade type parameter
    populate_assignment_fields(params[:grade_type])
  
    # Check if the current user is the instructor or a teaching assistant (TA) for the assignment,
    # or if they are the instructor for the course associated with the assignment
    instructor_or_ta? || course_instructor?
  end
  
  private
  
  # Method to populate assignment fields based on the grade type parameter
  def populate_assignment_fields(grade_type)
    assignment_for_history(grade_type)
  end
  
  # Method to check if the current user is the instructor or a TA for the assignment
  def instructor_or_ta?
    # Check if the current user is the instructor of the assignment
    @assignment.instructor_id == current_user.id ||
      # Check if the current user is a TA for the course associated with the assignment
      TaMapping.exists?(ta_id: current_user.id, course_id: @assignment.course_id)
  end
  
  # Method to check if the current user is the instructor for the course associated with the assignment
  def course_instructor?
    # Check if the assignment has a course associated with it and if the current user is the instructor of that course
    @assignment.course_id && Course.find(@assignment.course_id).instructor_id == current_user.id
  end
  

  # populate the assignment fields according to type
  def assignment_for_history(type)
    return unless ['Submission', 'Review'].include?(type)

    # for a submission, the receiver is an AssignmentTeam
    # use this AssignmentTeam to find the assignment
    if type.eql? 'Submission'
      assignment_team = AssignmentTeam.find(params[:grade_receiver_id])
      @assignment = Assignment.find(assignment_team.parent_id)
    end
    # for a review, the receiver is an AssignmentParticipant
    # use this AssignmentParticipant to find the assignment
    elsif type.eql? 'Review'
      participant_id = params[:participant_id]
      grade_receiver = AssignmentParticipant.find(participant_id)
      @assignment = Assignment.find(grade_receiver.parent_id)
    end
  end

  # return all grading history entries for the assignment
  # entries are returned in chronological order
  def index
    @grading_histories = GradingHistory.where(grade_receiver_id: params[:grade_receiver_id], grading_type: params[:grade_type]).reverse_order
  end
end
