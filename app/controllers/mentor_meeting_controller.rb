class MentorMeetingController < ApplicationController
  include AuthorizationHelper

  # Method to get meeting dates for a particular assignment
  def get_mentor_meeting_dates
    @mentor_meetings = MentorMeeting.all
    render json: @mentor_meetings
  end

  # Method to add meetings dates to the mentor_meetings table.
  def add_mentor_meeting_date
    team_id = params[:team_id]
    meeting_date = params[:meeting_date]
    @mentor_meeting = MentorMeeting.create(team_id: team_id, meeting_date: meeting_date)
    @mentor_meeting.save
    render :json => { :status => 'success', :message => "Ok"}
  end
end
