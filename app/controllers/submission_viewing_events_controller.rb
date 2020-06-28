class SubmissionViewingEventsController < ApplicationController
  def action_allowed?
    true
  end

  # record time when link or file is opened in new window
  def record_start_time
    param_args = params[:submission_viewing_event]
    # check if this link is already opened and timed
    submission_viewing_event_records = SubmissionViewingEvent.where(map_id: param_args[:map_id], round: param_args[:round], link: param_args[:link])
    # if opened, end these records with current time
    if submission_viewing_event_records
      submission_viewing_event_records.each do |time_record|
        if time_record.end_at.nil?
          # time_record.update_attribute('end_at', start_at)
          time_record.destroy
        end
      end
    end
    # create new response time record for current link
    submission_viewing_event = SubmissionViewingEvent.new(submission_viewing_event_params)
    submission_viewing_event.save

    #if creating start time for expertiza update end times for all other links.
    if param_args[:link]=='Expertiza Review'
      params[:submission_viewing_event][:link] = nil
      params[:submission_viewing_event][:end_at] = params[:submission_viewing_event][:start_at]
      record_end_time()
    end
    render nothing: true
  end

  # record time when link or file window is closed
  def record_end_time
    data = params.require(:submission_viewing_event)
    if data[:link].nil?
      submission_viewing_event_records = SubmissionViewingEvent.where(map_id: data[:map_id], round: data[:round], end_at: nil).where.not(link: "Expertiza Review")
    else
      submission_viewing_event_records = SubmissionViewingEvent.where(map_id: data[:map_id], round: data[:round], link: data[:link])
    end
    submission_viewing_event_records.each do |time_record|
      if time_record.end_at.nil?
        time_record.update_attribute('end_at', data[:end_at])
        # break
      end
    end
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # mark end_at review time for all uncommited links/files
  def mark_end_time
    data = params.require(:submission_viewing_event)
    @link_array = []
    submission_viewing_event_records = SubmissionViewingEvent.where(map_id: data[:map_id], round: data[:round])
    submission_viewing_event_records.each do |submissionviewingevent_entry|
      if submissionviewingevent_entry.end_at.nil?
        @link_array.push(submissionviewingevent_entry.link)
        submissionviewingevent_entry.update_attribute('end_at', data[:end_at])
      end
    end
    respond_to do |format|
      format.json { render json: @link_array }
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def submission_viewing_event_params
    params.require(:submission_viewing_event).permit(:map_id, :round, :link, :start_at, :end_at)
  end
  
end
