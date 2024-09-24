class MentorMeetingController < ApplicationController
  include MentorMeetingsHelper

  # Fetches all meeting dates from the MentorMeeting model
  def get_dates
    @mentor_meetings = MentorMeeting.all  # Find all mentor meetings
    render json: @mentor_meetings         # Return all meetings as JSON response
  end

  # Creates a new meeting date for a specific team
  def add_date
    team_id = params[:team_id]             # Get team ID from request parameters
    meeting_date = params[:meeting_date]   # Get meeting date from request parameters

    @mentor_meeting = MentorMeeting.create(team_id: team_id, meeting_date: meeting_date)
    # Create a new MentorMeeting record
    @mentor_meeting.save                  # Save the newly created meeting

    render json: { status: 'success', message: "Ok" }  # Respond with success message
  end

  # Updates the meeting date for a specific team
  def edit_date
    team_id = params[:team_id].to_i          # Get team ID from request parameters (convert to integer)
    old_meeting_date = params[:old_date]    # Get existing meeting date from request parameters
    new_meeting_date = params[:new_date]    # Get new meeting date from request parameters

    @meeting = MentorMeeting.where(team_id: team_id, meeting_date: old_meeting_date).first
    # Find the first meeting matching team and date

    if @meeting  # Check if a meeting was found
      @meeting.meeting_date = new_meeting_date  # Update the meeting date
      if @meeting.save                        # Save the updated meeting
        render json: { status: 'success', message: "Ok" }  # Respond with success message
      end
    end
  end

  # Deletes a meeting date for a specific team
  def delete_date
    team_id = params[:team_id].to_i          # Get team ID from request parameters (convert to integer)
    meeting_date = params[:meeting_date]   # Get meeting date from request parameters

    @meeting = MentorMeeting.where(team_id: team_id, meeting_date: meeting_date).first
    # Find the first meeting matching team and date
    @meeting.destroy if @meeting            # Destroy the meeting if it exists

    render json: { status: 'success', message: "Ok" }  # Respond with success message
  end
end
