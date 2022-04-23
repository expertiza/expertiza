class SubmissionViewingEventsController < ApplicationController
  def action_allowed?
    true
  end

  # record time when link or file is opened in new window
  def record_start_time
    puts "record start time called"
    param_args = params[:submission_viewing_event]
    # check if this link is already opened and timed
    submission_viewing_event_record = SubmissionViewingEvent.where(map_id: param_args[:map_id], round: param_args[:round], link: param_args[:link])
    # if opened, end these records with current time
    if submission_viewing_event_record
      submission_viewing_event_record.update_attribute('start_at', params[:start_at])
    else
      submission_viewing_event = SubmissionViewingEvent.new(submission_viewing_event_params)
      submission_viewing_event.save
    end
    # create new response time record for current link
    render nothing: true
  end

  # record time when link or file window is closed
  def record_end_time
    puts "record end time called"
    data = params.require(:submission_viewing_event)
    submission_viewing_event_record = SubmissionViewingEvent.where(map_id: data[:map_id], round: data[:round], link: data[:link])
    if submission_viewing_event_record.end_at.nil?
      submission_viewing_event_record.update_attribute('end_at', data[:end_at])
      acc_time = (submission_viewing_event_record.start_at.to_i - submission_viewing_event_record.end_at.to_i)/60
      if acc_time > 90 
        break
      end
      # update total time spent 
      acc_time += submission_viewing_event_record.accumulated_time
      submission_viewing_event_record.update_attribute('accumulated_time')
    else
      # No record found
    end

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # mark end_at review time for all uncommited links/files
  def mark_end_time
    puts "Mark end time called"
    data = params.require(:submission_viewing_event)
    @link_array = []
    submission_viewing_event_records = SubmissionViewingEvent.where(map_id: data[:map_id], round: data[:round])
    submission_viewing_event_records.each do |submissionviewingevent_entry|
      if submissionviewingevent_entry.end_at.nil?
        @link_array.push(submissionviewingevent_entry.link)
        submissionviewingevent_entry.update_attribute('end_at', data[:end_at])
        start_time = submissionviewingevent_entry.start_at
        acc_time = (data[:end_at].to_i  - start_time.to_i)/60
        acc_time += submission_viewing_event_entry.accumulated_time
        submissionviewingevent_entry.update_attribute('accumulated_time', acc_time)
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