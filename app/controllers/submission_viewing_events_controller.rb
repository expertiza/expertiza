class SubmissionViewingEventsController < ApplicationController
  include SubmittedContentHelper
  include SubmissionViewingEventHelper
  def action_allowed?
    true
  end

  # record time when link or file is opened in new window
  def record_start_time
    param_args = params[:submission_viewing_event] # get args from triggering event
    store = LocalStorage.new() # access local pstore file

    # check if this link is already opened and timed
    submission_viewing_event_records = store.where(map_id: param_args[:map_id], round: param_args[:round], link: param_args[:link])

    # if opened, end these records with current time
    if submission_viewing_event_records
      submission_viewing_event_records.each do |time_record|
        if time_record.end_at.nil?
          store.remove(time_record)
        end
      end
    end

    # create new response time record for current link
    submission_viewing_event = LocalSubmittedContent.new(submission_viewing_event_params)
    store.save(submission_viewing_event)

    #if creating start time for expertiza update end times for all other links.
    if param_args[:link]=='Expertiza Review'
      params[:submission_viewing_event][:link] = nil
      params[:submission_viewing_event][:end_at] = params[:submission_viewing_event][:start_at]
      record_end_time()
    end

    head :ok
  end

  # record time when link or file window is closed
  def record_end_time
    data = params.require(:submission_viewing_event) # get args from triggering event
    store = LocalStorage.new() # access local pstore file

    # if link is nil that means this is not an expertiza review
    if data[:link].nil?
      submission_viewing_event_records = store.where(map_id: data[:map_id], round: data[:round], end_at: nil).select { |item| item.link != "Expertiza Review"}
    else
      submission_viewing_event_records = store.where(map_id: data[:map_id], round: data[:round], link: data[:link])
    end

    # if end_at is nil, record end time
    submission_viewing_event_records.each do |time_record|
      if time_record.end_at.nil?
        time_record.end_at = data[:end_at]
      end
    end

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # mark end_at review time for all uncommited links/files
  def mark_end_time
    data = params.require(:submission_viewing_event) # get args from triggering event
    @link_array = []
    store = LocalStorage.new() # access local pstore file

    # find relevant stored events
    submission_viewing_event_records = store.where(map_id: data[:map_id], round: data[:round])
    submission_viewing_event_records.each do |submissionviewingevent_entry|
      if submissionviewingevent_entry.end_at.nil?
        @link_array.push(submissionviewingevent_entry.link)
        submissionviewingevent_entry.end_at = data[:end_at]

        to_find = submissionviewingevent_entry.to_h()
        search = {map_id: to_find[:map_id], round: to_find[:round], link: to_find[:link]}
        if(!SubmissionViewingEvent.where(search).empty?) # checks if record already exists for link
          SubmissionViewingEvent.where(search).update_all(end_at: data[:end_at]) # if yes update current entry
        else
          store.hard_save(submissionviewingevent_entry) # if no create new entry
        end
        store.remove(submissionviewingevent_entry) # remove from local storage
      end
    end

    respond_to do |format|
      format.json { render json: @link_array }
    end
  end

  def getTimingDetails
    require 'json'
    labels = []

    timingEntries = SubmissionViewingEvent.where(map_id: params[:reponse_map_id], round: params[:round])

    timingEntries.each do |entry|
      labels.push(entry.link)
    end

    @timingDetails = {
        'Labels'=> labels,
        'Data' => [],
        'tables' => [],
        'total' => 0,
        'totalavg' => 0
    }

    puts @timingDetails

    respond_to do |format|
      format.json {render json: @timingDetails}
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def submission_viewing_event_params
    params.require(:submission_viewing_event).permit(:map_id, :round, :link, :start_at, :end_at)
  end
end