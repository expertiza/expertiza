class SampleSubmissionsController < ApplicationController
  before_action :set_sample_submission, only: [:show, :edit, :update, :destroy]

  # GET /sample_submissions
  def index
    @sample_submissions = SampleSubmission.all
  end

  # GET /sample_submissions/1
  def show
  end

  # GET /sample_submissions/new
  def new
    @sample_submission = SampleSubmission.new
  end

  # GET /sample_submissions/1/edit
  def edit
  end

  # POST /sample_submissions
  def create
    @sample_submission = SampleSubmission.new(sample_submission_params)

    if @sample_submission.save
      redirect_to @sample_submission, notice: 'Sample submission was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /sample_submissions/1
  def update
    if @sample_submission.update(sample_submission_params)
      redirect_to @sample_submission, notice: 'Sample submission was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /sample_submissions/1
  def destroy
    @sample_submission.destroy
    redirect_to sample_submissions_url, notice: 'Sample submission was successfully destroyed.'
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
