class SubmissionHistoriesController < ApplicationController
  before_action :set_submission_history, only: [:show, :edit, :update, :destroy]

  # GET /submission_histories
  def index
    @submission_histories = SubmissionHistory.all
  end

  # GET /submission_histories/1
  def show
  end

  # GET /submission_histories/new
  def new
    @submission_history = SubmissionHistory.new
  end

  # GET /submission_histories/1/edit
  def edit
  end

  # POST /submission_histories
  def create
    @submission_history = SubmissionHistory.new(submission_history_params)

    if @submission_history.save
      redirect_to @submission_history, notice: 'Submission history was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /submission_histories/1
  def update
    if @submission_history.update(submission_history_params)
      redirect_to @submission_history, notice: 'Submission history was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /submission_histories/1
  def destroy
    @submission_history.destroy
    redirect_to submission_histories_url, notice: 'Submission history was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submission_history
      @submission_history = SubmissionHistory.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def submission_history_params
      params[:submission_history]
    end
end
