class SubmissionRecordsController < ApplicationController
  include AuthorizationHelper

  before_action :set_submission_record, only: %i[show edit update destroy]

  def action_allowed?
    # currently we only have a index method which shows all the submission records given a team_id
    assignment_team = AssignmentTeam.find(params[:team_id])
    assignment = Assignment.find(assignment_team.parent_id)
    return true if current_user_has_admin_privileges?
    return true if current_user_has_instructor_privileges? && current_user_instructs_assignment?(assignment)
    return true if current_user_has_ta_privileges? && current_user_has_ta_mapping_for_assignment?(assignment)

    false
  end

  # Show submission records.
  # expects to get team_id from params
  def index
    @submission_records = SubmissionRecord.where(team_id: params[:team_id])
  end
end
