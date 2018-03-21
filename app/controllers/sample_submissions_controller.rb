class SampleSubmissionsController < ApplicationController
  before_action :set_sample_submission, only: [:show, :edit, :update, :destroy]

  # GET /sample_submissions
  def index
    assignment_id = params[:id]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sample_submission
      @sample_submission = SampleSubmission.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def sample_submission_params
      params[:sample_submission]
    end
end
