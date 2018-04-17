class SampleSubmissionsController < ApplicationController
  before_action :set_sample_submission, only: %i[show]
  before_action :authorize

  # Allow student enrolled in that assignment to view sample submissions
  # Allow everyone else to view it
  def action_allowed?
    return true if ['Instructor', 'Teaching Assistant', 'Administrator', 'Super-Administrator'].include? current_role_name
    @teams = TeamsUser.where(user_id: current_user.try(:id))
    @teams.each do |team|
      return true if Team.where(id: team.team_id).first.parent_id == sample_submission_params[:id].to_i
    end
    false
  end

  def show; end

  def init_sample_submissions
    # Retrieve links submitted by students in sample submission assignments
    @assignment_teams = AssignmentTeam.where(parent_id: sample_submission_params[:id], make_public: true)
    @assignment = Assignment.where(id: sample_submission_params[:id]).first
    @assignment_teams_professor = AssignmentTeam.where(parent_id: @assignment.sample_assignment_id, make_public: true)
    @assignment_due_date = DueDate.where(parent_id: @assignment.id).last
    @assignment_due_date = @assignment_due_date.due_at unless @assignment_due_date.nil?
  end

  def init_assignment_paths
    # For retrieving paths of files uploaded for the assignment submission
    @assignment_path = get_assignment_directory(@assignment)
    @instructor_chosen_assignment = Assignment.find(@assignment.sample_assignment_id) unless @assignment.sample_assignment_id.nil?
    @instructor_chosen_assignment_path = get_assignment_directory(@instructor_chosen_assignment) unless @instructor_chosen_assignment.nil?
  end

  # GET /sample_submissions
  def index
    # Initialize variables required in view.
    init_sample_submissions
    init_assignment_paths
  end

  def get_assignment_directory(assignment)
    instructor_name = User.find(assignment.instructor_id).name
    course_directory_path = Course.find(assignment.course_id).directory_path
    assignment_directory_path = assignment.directory_path
    Rails.root.join('pg_data', instructor_name, course_directory_path, assignment_directory_path)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_sample_submission
    @sample_submission = SampleSubmission.find(params[:id])
  end

  # Only allow a trusted parameter "white index" through.
  def sample_submission_params
    params.permit(:id)
  end
end
