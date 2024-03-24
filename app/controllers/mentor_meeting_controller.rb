class MentorMeetingController < ApplicationController
  include MentorMeetingsHelper

  # Method to get meeting dates for a particular assignment
  def get_dates
    @mentor_meetings = MentorMeeting.all
    render json: @mentor_meetings
  end

  # Method to add meetings dates to the mentor_meetings table.
  def add_date
    team_id = params[:team_id]
    meeting_date = params[:meeting_date]
    @mentor_meeting = MentorMeeting.create(team_id: team_id, meeting_date: meeting_date)
    @mentor_meeting.save
    render :json => { :status => 'success', :message => "Ok"}
  end

  def edit_date
    team_id = params[:team_id]
    old_meeting_date = params[:old_date]
    new_meeting_date = params[:new_date]

    @meeting = MentorMeeting.where(team_id: team_id.to_i, meeting_date: old_meeting_date).first
    if @meeting
      @meeting.meeting_date = new_meeting_date
      if @meeting.save
        render :json => { :status => 'success', :message => "Ok"}
      end
    end
  end

  def delete_date
    team_id = params[:team_id]
    meeting_date = params[:meeting_date]
    @meeting = MentorMeeting.where(team_id: team_id.to_i, meeting_date: meeting_date).first
    @meeting.destroy
    render :json => { :status => 'success', :message => "Ok"}
  end

end

