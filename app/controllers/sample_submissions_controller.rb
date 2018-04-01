class SampleSubmissionsController < ApplicationController
  before_action :set_sample_submission, only: [:show, :edit, :update, :destroy]

  def action_allowed?
    ['Instructor', 'Teaching Assistant', 'Administrator', 'Super-Administrator', 'Student'].include? current_role_name
  end

  # GET /sample_submissions
  def index
    @assignment_teams = AssignmentTeam.where(:parent_id => sample_submission_params[:id], :make_public=>true)
    @assignment = Assignment.where(:id => sample_submission_params[:id]).first
    @assignment_teams_professor = AssignmentTeam.where(:parent_id => @assignment.sample_assignment_id, :make_public=>true)
    @assignment_due_date = DueDate.where(:parent_id => @assignment.id).last
    if @assignment_due_date != nil
      @assignment_due_date = @assignment_due_date.due_at
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_sample_submission
    @sample_submission = SampleSubmission.find(params[:id])
  end

  # Only allow a trusted parameter "white index" through.
  def sample_submission_params
    params.permit( :id)
  end
end

