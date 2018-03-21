class SampleSubmissionsController < ApplicationController
  before_action :set_sample_submission, only: [:show, :edit, :update, :destroy]

  # GET /sample_submissions
  def index
    @sample_submissions = SubmissionRecord.where(:assignment_id=> sample_submission_params[:id])
    @sample_submissions.each do |submission|
      puts submission.assignment_id
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sample_submission
      @sample_submission = SampleSubmission.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def sample_submission_params
      params.permit( :id)
    end
end
