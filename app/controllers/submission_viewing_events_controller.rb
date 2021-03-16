class SubmissionViewingEventsController < ApplicationController
  include SubmittedContentHelper

  before_action :ensure_store

  def action_allowed?
    true
  end

  # Records the start time for a review asset and clears the end time.
  # The intent here is to signal "we're currently tracking this as being reviewed."
  def record_start_time2
    args = request_params

    # :start_at has been updated to be a timestamp from the client-side
    # so it needs to be parsed to a DateTime for the database
    start_time = Time.at(args[:start_at]).to_datetime

    # check for pre-existing record
    records = @store.where(
      map_id: args[:map_id],
      round: args[:round],
      link: args[:link]
    )

    if records
      # one existed in local storage already
      # update the start time, and clear the end time
      record = records[0]
      record.start_at = start_time
      record.end_at = nil
    else
      # one did not exist in local storage already
      # create a new one, record the start time, and clear the end time
      # be sure to save the new record to local storage at the end
      record = LocalSubmittedContent.new(args)
      record.start_at = start_time
      record.end_at = nil
      @store.save(record)
    end
  end

  def record_end_time2
    args = request_params
    link = args[:link]
    records = if link
                # if link is provided, we'll update the end time for it
                @store.where(map_id: args[:map_id], round: args[:round], link: [:link])
              else
                # if no specific link is provided, then update the end
                # time for all links _except_ the Expertiza Review
                # TODO: determine _why_ the last group needed this logic
                @store.where(map_id: args[:map_id], round: args[:round])
                      .select { |item| item.link != "Expertiza Review" }
              end

    records.each do |record|
      record.end_at = DateTime.now
    end

    respond_to do |format|
      format.json { head :no_content }
    end

  end

  def hard_save
    args = request_params
    # TODO:
    #   hard save all links in local storage
    #   remove them from local storage
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
    submission_viewing_event = LocalSubmittedContent.new(request_params)
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

  private

  # Only allow a trusted parameter "white list" through.
  def request_params
    params.require(:submission_viewing_event).permit(:map_id, :round, :link, :start_at, :end_at)
  end

  def ensure_store
    unless @store
      @store = LocalStorage.new
    end
  end
end