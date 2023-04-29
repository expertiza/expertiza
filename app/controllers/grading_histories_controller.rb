class GradingHistoriesController < ApplicationController
  before_action :set_grading_history, only: %i[show] # sets the grading history for the show action

  def action_allowed?
    return true if ['Super-Administrator', 'Administrator'].include? current_role_name # checks if the current user is a super-administrator or an administrator
    check_type(params[:grade_type]) # calls the check_type method to determine the type of grading history
    # checks the permissions of the current user for the current grading history
    assignment_instructor = @assignment.instructor_id
    assignment_course_id = @assignment.course_id
    current_user_is_instructor = assignment_instructor == current_user.id
    current_user_is_ta_for_course = TaMapping.exists?(ta_id: current_user.id, course_id: assignment_course_id)
    current_user_is_ta_for_assignment = current_user_is_ta_for_course && TaMapping.where(course_id: assignment_course_id).include?(TaMapping.where(ta_id: current_user.id, course_id: assignment_course_id).first)
    current_user_is_instructor_of_course = assignment_course_id && Course.find(assignment_course_id).instructor_id == current_user.id

    current_user_is_instructor || current_user_is_ta_for_assignment || current_user_is_instructor_of_course # returns true if the current user has the required permissions
  end

  def check_type(type) # determines the type of grading history
    if type.eql? "Submission"
      assignment_team = AssignmentTeam.find(params[:grade_receiver_id])
      @assignment = Assignment.find(assignment_team.parent_id)
    end
    if type.eql? "Review"
      participant_id = params[:participant_id]
      grade_receiver = AssignmentParticipant.find(participant_id)
      @assignment = Assignment.find(grade_receiver.parent_id)
    end
  end

  def index
    @grading_histories = GradingHistory.where(grade_receiver_id: params[:grade_receiver_id], grading_type: params[:grade_type]).reverse_order # gets the grading histories for the given receiver and grading type, and orders them in reverse chronological order
    record = @grading_histories.first # gets the most recent grading history record
    if record.nil?
      @receiver = ""
      @assignment = ""
    else
      if record.grading_type == "Submission" # if the grading history is for a submission, get name of the team and name of the assignment
        @receiver = "of " + Team.where(id: record.grade_receiver_id).pluck(:name).first 
        @assignment = "for the submission " + Assignment.where(id: record.assignment_id).pluck(:name).first
      else # if the grading history is for a review, get name of the user and name of the assignment
        @receiver = "of " + User.where(id: record.grade_receiver_id).pluck(:fullname).first 
        @assignment = "for review in " + Assignment.where(id: record.assignment_id).pluck(:name).first
      end
    end
  end
end
