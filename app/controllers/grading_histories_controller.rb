class GradingHistoriesController < ApplicationController
  include AuthorizationHelper

  # Checks if user is allowed to view a grading history
  def action_allowed?
    # admins and superadmins are always allowed
    return true if current_user_has_admin_privileges?
    
    # populate assignment fields
    @assignment = GradingHistory.assignment_for_history(params[:grade_type], params[:graded_member_id], params[:participant_id])
    # if not admin/superadmin, check permissions
    if @assignment.instructor_id == current_user.id
      true
    elsif TaMapping.exists?(ta_id: current_user.id, course_id: @assignment.course_id) &&
      (TaMapping.where(course_id: @assignment.course_id).include? TaMapping.where(ta_id: current_user.id, course_id: @assignment.course_id).first)
      true
    elsif @assignment.course_id && Course.find(@assignment.course_id).instructor_id == current_user.id
      true
    else
      false
    end
  end

  # return all grading history entries for the assignment
  # entries are returned in chronological order
  def index
    @grading_histories = GradingHistory.where(graded_member_id: params[:graded_member_id], graded_item_type: params[:grade_type]).reverse_order
    record = @grading_histories[0]
    if record == nil
      @receiver = ""
      @assignment = ""
    else
      if record.graded_item_type == "Submission"
        @receiver = "Graded Team: " + Team.where(id: record.graded_member_id).pluck(:name).first
        @assignment = Assignment.where(id: record.assignment_id).pluck(:name).first
      else
        @receiver = "Graded User: " + User.where(id: record.graded_member_id).pluck(:fullname).first
        @assignment = "review for " + Assignment.where(id: record.assignment_id).pluck(:name).first
      end
    end
  end
end