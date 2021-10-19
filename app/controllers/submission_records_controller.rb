class SubmissionRecordsController < ApplicationController
  before_action :set_submission_record, only: %i[show edit update destroy]

  def action_allowed?
    # currently we only have a index method which shows all the submission records given a team_id
    assignment_team = AssignmentTeam.find(params[:team_id])
    assignment = Assignment.find(assignment_team.parent_id)
    return true if ['Super-Administrator', 'Administrator'].include? current_role_name
    return true if assignment.instructor_id == current_user.id
    return true if TaMapping.exists?(ta_id: current_user.id, course_id: assignment.course_id) && (TaMapping.where(course_id: assignment.course_id).include? TaMapping.where(ta_id: current_user.id, course_id: assignment.course_id).first)
    return true if assignment.course_id && Course.find(assignment.course_id).instructor_id == current_user.id
    false
  end

  # Show submission records.
  # expects to get team_id from params
  def index
    @submission_records = SubmissionRecord.where(team_id: params[:team_id])
  end
end
