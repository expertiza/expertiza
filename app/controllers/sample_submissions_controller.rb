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

  # GET /sample_submissions
  def index
    @assignment_teams = AssignmentTeam.where(parent_id: sample_submission_params[:id], make_public: true)
    @assignment = Assignment.where(id: sample_submission_params[:id]).first
    @assignment_teams_professor = AssignmentTeam.where(parent_id: @assignment.sample_assignment_id, make_public: true)
    @assignment_due_date = DueDate.where(parent_id: @assignment.id).last
    @assignment_due_date = @assignment_due_date.due_at unless @assignment_due_date.nil?
    @assignment_path = "#{Rails.root}/pg_data/#{User.find(@assignment.instructor_id).name}/#{Course.find(@assignment.course_id).directory_path}/#{@assignment.directory_path}/"
    @instructor_chosen_assignment = Assignment.find(@assignment.sample_assignment_id) unless @assignment.sample_assignment_id.nil?
    @instructor_chosen_assignment_path = "#{Rails.root}/pg_data/#{User.find(@instructor_chosen_assignment.instructor_id).name}/#{Course.find(@instructor_chosen_assignment.course_id).directory_path}/#{@instructor_chosen_assignment.directory_path}/" unless @instructor_chosen_assignment.nil?
    #Get List of files submitted in the assignments

    # @assignment_teams.each do |assignment_team|
    #   path = "#{Rails.root}/pg_data/#{User.find(@assignment.instructor_id).name}/#{Course.find(@assignment.course_id).directory_path}/#{@assignment.directory_path}/#{assignment_team.directory_num.to_s}"
    #   puts path
    #   @assignment_team.submitted_files = Dir.entries(path)
    # end
    #
    # professor_chosen_assignment = Assignment.where(id: @assignment.sample_assignment_id).first
    # @assignment_teams_professor.each do |assignment_team|
    #   path = "#{Rails.root}/pg_data/#{User.find(@assignment.instructor_id).name}/#{Course.find(professor_chosen_assignment.course_id).directory_path}/#{professor_chosen_assignment.directory_path}/#{assignment_team.directory_num.to_s}"
    #
    #   #path = "#{Rails.root}/pg_data/#{@assignment.instructor_id}/#{professor_chosen_assignment.directory_path}/#{assignment_team.directory_num.to_s}"
    #   puts path
    #   @assignment_team.submitted_files = Dir.entries(path)
    #   #assignment_team.submitted_files = Dir.entries(Rails.root + "/pg_data/"+ professor_chosen_assignment.directory_path + "/" + (assignment_team.directory_num).to_s)
    # end
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
