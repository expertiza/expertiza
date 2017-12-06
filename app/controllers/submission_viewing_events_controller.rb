class SubmissionViewingEventsController < ApplicationController
  before_action :set_submission_viewing_event, only: [:show, :edit, :update, :destroy]

  # GET /submission_viewing_events
  def index
    @submission_viewing_events = SubmissionViewingEvent.all
  end

  # GET /submission_viewing_events/1
  def show
  end

  # GET /submission_viewing_events/new
  def new
    @submission_viewing_event = SubmissionViewingEvent.new
  end

  # GET /submission_viewing_events/1/edit
  def edit
  end

  # POST /submission_viewing_events
  def create
    @submission_viewing_event = SubmissionViewingEvent.new(submission_viewing_event_params)

    if @submission_viewing_event.save
      redirect_to @submission_viewing_event, notice: 'Submission viewing event was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /submission_viewing_events/1
  def update
    if @submission_viewing_event.update(submission_viewing_event_params)
      redirect_to @submission_viewing_event, notice: 'Submission viewing event was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /submission_viewing_events/1
  def destroy
    @submission_viewing_event.destroy
    redirect_to submission_viewing_events_url, notice: 'Submission viewing event was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submission_viewing_event
      @submission_viewing_event = SubmissionViewingEvent.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def submission_viewing_event_params
      params.require(:submission_viewing_event).permit(:map_id, :round, :link, :start_at, :end_at)
    end
end
