class GradingHistoriesController < ApplicationController
  include AuthorizationHelper
  before_action :set_grading_history, only: %i[show]

  def show
    @grading_histories = GradingHistory.includes(:grade_receiver, :assignment, :instructor).where(id: params[:id]).order(created_at: :desc)
    set_receiver_and_assignment
  end

  private

  def set_receiver_and_assignment
    record = @grading_histories.first
    if record.nil?
      @receiver = ""
      @assignment = ""
    else
      if record.grading_type == "Submission"
        @receiver = "of #{record.grade_receiver.name}"
        @assignment = "for the submission #{record.assignment.name}"
      else
        @receiver = "of #{record.grade_receiver.fullname}"
        @assignment = "for review in #{record.assignment.name}"
      end
    end
  end
end

  # Checks if user is allowed to view a grading history
  def action_allowed?
  # Admins and superadmins are always allowed
  return true if current_user_has_admin_privileges?

  # Populate assignment fields
  assignment_for_history(params[:grade_type])

  # Check permissions
  if @assignment.instructor_id == current_user.id # If the current user is the instructor of the assignment
    true # Return true
  elsif TaMapping.exists?(ta_id: current_user.id, course_id: @assignment.course_id) && 
        TaMapping.where(course_id: @assignment.course_id).include?(TaMapping.where(ta_id: current_user.id, course_id: @assignment.course_id).first)
    true # Return true if the current user is a TA for the course that the assignment belongs to
  elsif @assignment.course_id && Course.find(@assignment.course_id).instructor_id == current_user.id # If the current user is the instructor of the course that the assignment belongs to
    true # Return true
  end

  # Return false if none of the above conditions are met
  false
end


  # populate the assignment fields according to type
  def assignment_for_history(type)
    # for a submission, the receiver is an AssignmentTeam
    # use this AssignmentTeam to find the assignment
    if type.eql? "Submission"
      assignment_team = AssignmentTeam.find(params[:grade_receiver_id])
      @assignment = Assignment.find(assignment_team.parent_id)
    end
    # for a review, the receiver is an AssignmentParticipant
    # use this AssignmentParticipant to find the assignment
    if type.eql? "Review"
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
