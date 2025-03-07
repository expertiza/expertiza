class MeetingsController < ApplicationController

  before_action :set_meeting, only: [:update, :destroy]

  # GET /meetings
  def index
    @meetings = Meeting.all
    @teams = Team.paginate(page: params[:page], per_page: 50)
    @mentored_teams = current_user.teams #any team that a mentor belongs to is a team they mentor
  end

  # GET /meetings/:id
  def show
    @meetings = Meeting.all
    @mentored_teams = current_user.teams #any team that a mentor belongs to is a team they mentor
  end

  # POST /meetings
  def create
    @meeting = Meeting.new(meeting_params)

    if @meeting.save
      # TODO: Re-implement email notification for meeting creation
      # MentorMeetingNotifications.send_notification(@meeting.team_id, @meeting.meeting_date)
      render json: { status: 'success', message: 'Meeting date added' }, status: :created
    else
      render json: { status: 'error', message: 'Unable to add meeting date', errors: @meeting.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT/PATCH /meetings/:id
  def update
    if @meeting.update(meeting_params)
      # TODO: Re-implement email notification for meeting updates
      # ActiveSupport::Notifications.instrument('mentor_meeting.updated', team_id: @meeting.team_id, old_meeting_date: params[:old_date], new_meeting_date: @meeting.meeting_date)
      render json: { status: 'success', message: 'Meeting updated successfully' }
    else
      render json: { status: 'error', message: 'Failed to update meeting', errors: @meeting.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /meetings/:id
  def destroy
    team_id = @meeting.team_id
    meeting_date = @meeting.meeting_date

    if @meeting.destroy
      # TODO: Re-implement email notification for meeting deletion
      # ActiveSupport::Notifications.instrument('mentor_meeting.deleted', team_id: team_id, meeting_date: meeting_date)
      render json: { status: 'success', message: 'Meeting deleted successfully' }
    else
      render json: { status: 'error', message: 'Failed to delete meeting', errors: @meeting.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
    def meeting_params
      params.permit(:team_id, :meeting_date)
    end

    def set_meeting
      @meeting = Meeting.find_by(team_id: params[:team_id], meeting_date: params[:old_date] || params[:meeting_date])
      unless @meeting
      render json: { status: 'error', message: 'Meeting not found' }, status: :not_found
    end
  end
end