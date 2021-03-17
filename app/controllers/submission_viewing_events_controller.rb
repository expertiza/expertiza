class SubmissionViewingEventsController < ApplicationController
  include SubmittedContentHelper
  include SubmissionViewingEventHelper

  before_action :ensure_store

  def action_allowed?
    true
  end

  # Records the start time for a review asset and clears the end time.
  # The intent here is to signal "we're currently tracking this as being reviewed."
  def record_start_time2
    args = request_params2

    start_time = DateTime.now

    # check for pre-existing record
    records = @store.where(
      map_id: args[:map_id],
      round: args[:round],
      link: args[:link]
    )

    if records
      record = records[0]
      record.start_at = start_time
      record.end_at = nil
      record.updated_at = start_time
    else
      # one did not exist in local storage already
      # create a new one and save the new record to
      # local storage
      record = LocalSubmittedContent.new map_id: args[:map_id],
                                         round: args[:round],
                                         link: args[:link],
                                         start_at: start_time,
                                         end_at: nil,
                                         created_at: start_time,
                                         updated_at: start_time,
                                         total_time: 0
      @store.save(record)
    end

    head :ok
  end

  # Record the end time for a single link given by :link
  # or all links if :link is absent from the request args.
  #
  # This function records the end time, and accumulates
  # total_time for a given record.
  #
  # The intent here is that "these are done being review for now."
  def record_end_time2
    args = request_params2
    if args[:link]
      end_timing_for_link(args[:map_id], args[:round], args[:link])
    else
      end_timing_for_round(args[:map_id], args[:round])
    end
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # Provide a function to explicitly flush local storage to
  # the database.
  def hard_save
    args = request_params2
    @uncommitted = save_and_remove_all(args[map_id], args[:round])
    # TODO: why does the previous group render json with the
    # links that were just committed?
    respond_to do |format|
      format.json { render json: @uncommitted }
    end
  end

  # Provide a convenience function to stop timing for all
  # links in a round and flush them to the database.
  #
  # This allows the client to combine these actions
  # without necessarily having to send back-to-back requests.
  def end_round_and_save
    args = request_params2
    end_timing_for_round(args[:map_id], args[:round])
    save_and_remove_all(args[:map_id], args[:round])
    head :no_content
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

  # Respond with a JSON containing relevant timing information for specified review and round
  def getTimingDetails
    require 'json'
    labels = [] # store links accessed during review
    percentages = [] # store percentages per link for pie chart
    tables = [] # store timing data breakdown per link

    # get total time spent on review
    totalTime = getTotalTime(params[:reponse_map_id], params[:round])

    # get all timing entries for review (each link has one entry)
    timingEntries = SubmissionViewingEvent.where(map_id: params[:reponse_map_id], round: params[:round])

    # push all data into relevant arrays for JSON
    timingEntries.each do |entry|
      labels.push(entry.link)
      percentages.push((entry.end_at - entry.start_at).to_f/totalTime)
      tables.push({
                      "subject" => entry.link,
                      "timecost" => secondsToHuman((entry.end_at - entry.start_at).to_i),
                      "clsavg" => 0
                  })
    end

    # create JSON
    @timingDetails = {
        'Labels'=> labels,
        'Data' => percentages,
        'tables' => tables,
        'total' => secondsToHuman(totalTime),
        'totalavg' => 0
    }

    # respond to request with JSON containing all data
    respond_to do |format|
      format.json {render json: @timingDetails}
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def request_params
    params.require(:submission_viewing_event).permit(:map_id, :round, :link)
  end

  # Require: :map_id, :round
  # Permit: :link
  def request_params2
    params.require(%i[map_id round]).permit(:link)
  end

  # Ensure that we have a non-nil instance of LocalStorage
  # to work with.
  def ensure_store
    unless @store
      @store = LocalStorage.new
    end
  end

  # End timing for a single [link] in the given review and [round].
  def end_timing_for_link(map_id, round, link)
    # if link is provided, we'll update the end time for it
    records = @store.where(map_id: map_id, round: round, link: link)
    _record_end_time(records)
  end

  # End timing for all links for the given [map_id] and [round].
  def end_timing_for_round(map_id, round)
    # if no specific link is provided, then update the end
    # time for all links _except_ the Expertiza Review
    # TODO: determine _why_ the last group needed this logic
    records = @store.where(map_id: map_id, round: round).select { |item| item.link != "Expertiza Review" }
    _record_end_time(records)
  end

  # For each record in [records], set the end time
  # to DateTime.now and update the total_time accumulator
  def _record_end_time(records)
    end_time = DateTime.now
    records.each do |record|
      record.end_at = end_time
      record.updated_at = end_time
      record.total_time += record.time_diff
    end
  end

  # Actually performs the work flushing records from
  # local storage to the database and removing them.
  def save_and_remove_all(map_id, round)
    uncommitted = []
    records = @store.where(map_id: map_id, round: round)

    records.each do |record|
      # push the uncommitted link on to the stack
      uncommitted << record.link

      previous = SubmissionViewingEvent.where(
        map_id: record.map_id,
        round: record.round,
        link: record.link
      )

      if previous
        # make sure to add the total time on this record
        # with what may have already been in the database
        updated = record.merge(previous)
        SubmissionViewingEvent.update(updated.to_h)
      else
        # if a previous record doesn't exist,
        # we can delegate saving to `LocalStorage`
        store.hard_save(record)
      end

      # once the data is updated or added to the database,
      # remove it from `LocalStorage`
      store.remove(record)
    end

    uncommitted
  end

end