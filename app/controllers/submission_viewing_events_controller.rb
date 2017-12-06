class SubmissionViewingEventsController < ApplicationController
  def action_allowed?
    true
  end

  # record time when link or file is opened in new window
  def record_start_time
    map_id = params[:submission_viewing_event][:map_id]
    round = params[:submission_viewing_event][:round]
    link = params[:submission_viewing_event][:link]
    start_at = params[:submission_viewing_event][:start_at]
    # check if this link is already opened and timed
    @submission_viewing_event_records = SubmissionViewingEvent.where(map_id: map_id, round: round, link: link)
    # if opened, end these records with current time
    if @submission_viewing_event_records
      @submission_viewing_event_records.each do |time_record|
        if time_record.end_at.nil?
          time_record.update_attribute('end_at', start_at)
        end
      end
    end
    # create new response time record for current link
    @submission_viewing_event = SubmissionViewingEvent.new(submission_viewing_event_params)
    @submission_viewing_event.save
    render :nothing => true
  end

  # record time when link or file window is closed
  def record_end_time
    @data = params.require(:submission_viewing_event)
    @submission_viewing_event_records = SubmissionViewingEvent.where(map_id: @data[:map_id], round: @data[:round], link: @data[:link])
    @submission_viewing_event_records.each do |time_record|
      if time_record.end_at.nil?
        time_record.update_attribute('end_at', @data[:end_at])
        break
      end
    end
    respond_to do |format|
      format.json {head :no_content}
    end
  end

  # mark end_at review time for all uncommited links/files
  def mark_end_time 
    @data= params.require(:submission_viewing_event)
    @linkArray=Array.new
    @submissionviewingevent_matches = SubmissionViewingEvent.where(map_id: @data[:map_id], round: @data[:round])
    @submissionviewingevent_matches.each do |submissionviewingevent_entry|
      if submissionviewingevent_entry.end_at.nil?
        @linkArray.push(submissionviewingevent_entry.link)
        submissionviewingevent_entry.update_attribute('end_at', @data[:end_at])
      end
    end   
    respond_to do|format|
      format.json {render json: @linkArray}
    end
  end

  private
    # Only allow a trusted parameter "white list" through.
    def submission_viewing_event_params
      params.require(:submission_viewing_event).permit(:map_id, :round, :link, :start_at, :end_at)
    end
end
