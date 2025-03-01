class MeetingsController < ApplicationController
  before_action :set_meeting, only: [:show, :edit, :update, :destroy]

  # GET /meetings
  def index
    @meetings = Meeting.all
  end

  # GET /meetings/1
  def show
  end

  # GET /meetings/new
  def new
    @meeting = Meeting.new
  end

  # GET /meetings/1/edit
  def edit
  end

  # POST /meetings
  def create
    @meeting = Meeting.new(meeting_params)

    if @meeting.save
      redirect_to @meeting, notice: 'Meeting was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /meetings/1
  def update
    if @meeting.update(meeting_params)
      redirect_to @meeting, notice: 'Meeting was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /meetings/1
  def destroy
    @meeting.destroy
    redirect_to meetings_url, notice: 'Meeting was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_meeting
      @meeting = Meeting.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def meeting_params
      params.require(:meeting).permit(:Date, :TeamID)
    end
end
