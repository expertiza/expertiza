class GradingHistoriesController < ApplicationController
  before_action :set_grading_history, only: %i[show]

  def action_allowed?
    return true if ['Super-Administrator', 'Administrator'].include? current_role_name
    check_type(params[:grade_type])
    if @assignment.instructor_id == current_user.id
      true
    elsif TaMapping.exists?(ta_id: current_user.id, course_id: @assignment.course_id) &&
        (TaMapping.where(course_id: @assignment.course_id).include? TaMapping.where(ta_id: current_user.id, course_id: @assignment.course_id).first)
      true
    elsif @assignment.course_id && Course.find(@assignment.course_id).instructor_id == current_user.id
      true
    end
  end


  def check_type(type)
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
    @grading_histories = GradingHistory.where(grade_receiver_id: params[:grade_receiver_id], grading_type: params[:grade_type]).reverse_order
  end
end