class MentorMeetingsController < ApplicationController
  before_action :set_mentor_meeting, only: [:show, :edit, :update, :destroy]

  # GET /mentor_meetings
  def index
    @mentor_meetings = MentorMeeting.all
  end

  # GET /mentor_meetings/1
  def show
  end

  # GET /mentor_meetings/new
  def new
    @mentor_meeting = MentorMeeting.new
  end

  # GET /mentor_meetings/1/edit
  def edit
  end

  # POST /mentor_meetings
  def create
    @mentor_meeting = MentorMeeting.new(mentor_meeting_params)

    if @mentor_meeting.save
      redirect_to @mentor_meeting, notice: 'Mentor meeting was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /mentor_meetings/1
  def update
    if @mentor_meeting.update(mentor_meeting_params)
      redirect_to @mentor_meeting, notice: 'Mentor meeting was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /mentor_meetings/1
  def destroy
    @mentor_meeting.destroy
    redirect_to mentor_meetings_url, notice: 'Mentor meeting was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mentor_meeting
      @mentor_meeting = MentorMeeting.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def mentor_meeting_params
      params.require(:mentor_meeting).permit(:team_id, :meeting_date)
    end
end
