class SampleSubmissionsController < ApplicationController
  before_action :set_sample_submission, only: [:show, :edit, :update, :destroy]
  def action_allowed?
    ['Instructor', 'Teaching Assistant', 'Administrator', 'Super-Administrator', 'Student'].include? current_role_name
  end

  # GET /sample_submissions
  def index
    @assignment_teams = AssignmentTeam.where(:parent_id=>sample_submission_params[:id])
    @assignment_name=sample_submission_params[:id]
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

