class GradingHistoriesController < ApplicationController
  include AuthorizationHelper
  before_action :set_grading_history, only: %i[show]

  # Checks if user is allowed to view a grading history
  def action_allowed?
    # admins and superadmins are always allowed
    return true if current_user_has_admin_privileges?
    
    # populate assignment fields
    assignment_team = AssignmentTeam.find(params[:graded_member_id])
    GradingHistory.assignment_for_history(params[:grade_type], assignment_team, params[:participant_id])
    # if not admin/superadmin, check permissions
    if @assignment.instructor_id == current_user.id
      true
    elsif TaMapping.exists?(ta_id: current_user.id, course_id: @assignment.course_id) &&
      (TaMapping.where(course_id: @assignment.course_id).include? TaMapping.where(ta_id: current_user.id, course_id: @assignment.course_id).first)
      true
    elsif @assignment.course_id && Course.find(@assignment.course_id).instructor_id == current_user.id
      true
    end
  end

  # return all grading history entries for the assignment
  # entries are returned in chronological order
  def index
    @grading_histories = GradingHistory.where(graded_member_id: params[:graded_member_id], graded_item_type: params[:grade_type]).reverse_order
  end
end