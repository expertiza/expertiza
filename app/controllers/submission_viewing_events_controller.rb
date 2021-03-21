require 'local_storage'
require 'local_submitted_content'

class SubmissionViewingEventsController < ApplicationController
  include SubmittedContentHelper
  include SubmissionViewingEventHelper

  before_action :ensure_store, only: %i[start_timing end_timing reset_timing hard_save end_round_and_save]

  def action_allowed?
    true
  end

  # Records the start time for a review asset and clears the end time.
  # The intent here is to signal "we're currently tracking this as being reviewed."
  def start_timing
    args = request_params2
    ExpertizaLogger.info "Received request to start timing event with params #{args}"

    if !args[:link].nil?
      start_timing_for_link(args[:map_id], args[:round], args[:link])
    else
      start_timing_for_round(args[:map_id], args[:round])
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
  def end_timing
    args = request_params2
    ExpertizaLogger.info "Received request to stop timing event with params #{args}"
    if !args[:link].nil?
      end_timing_for_link(args[:map_id], args[:round], args[:link])
    else
      end_timing_for_round(args[:map_id], args[:round])
    end
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def reset_timing
    args = request_params2
    ExpertizaLogger.info "Received request to reset timing event with params #{args}"
    if !args[:link].nil?
      end_timing_for_link(args[:map_id], args[:round], args[:link])
      start_timing_for_link(args[:map_id], args[:round], args[:link])
    else
      end_timing_for_round(args[:map_id], args[:round])
      start_timing_for_round(args[:map_id], args[:round])
    end

    head :ok
  end

  # Provide a function to explicitly flush local storage to
  # the database.
  def hard_save
    args = request_params2
    ExpertizaLogger.info "Received request to flush local storage with params #{args}"
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
    ExpertizaLogger.info "Received request to end and save timing for round #{args[:round]} with params #{args}"
    end_timing_for_round(args[:map_id], args[:round])
    save_and_remove_all(args[:map_id], args[:round])
    head :no_content
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
      percentages.push((entry.end_at - entry.start_at).to_f / totalTime)
      tables.push({
                    "subject" => entry.link,
                    "timecost" => secondsToHuman((entry.end_at - entry.start_at).to_i),
                    "clsavg" => 0
                  })
    end

    # create JSON
    @timingDetails = {
      'Labels' => labels,
      'Data' => percentages,
      'tables' => tables,
      'total' => secondsToHuman(totalTime),
      'totalavg' => 0
    }

    # respond to request with JSON containing all data
    respond_to do |format|
      format.json { render json: @timingDetails }
    end
  end

  private

  # Require: :map_id, :round
  # Permit: :link
  def request_params2
    ExpertizaLogger.info("Submission Viewing Event Params: #{params}")
    params.require(:submission_viewing_event).permit(:map_id, :round, :link)
  end

  # Ensure that we have a non-nil instance of LocalStorage
  # to work with.
  attr_accessor :store

  def ensure_store
    @store ||= LocalStorage.new
    ExpertizaLogger.info("Local Storage: #{@store}")
  end

  def start_timing_for_link(map_id, round, link)
    start_time = DateTime.now

    # check for pre-existing record
    records = @store.where(
      map_id: map_id,
      round: round,
      link: link
    )

    if !records.empty?
      ExpertizaLogger.info("#{records.length} previous link records found, updating start time.")
      _record_start_time(records)
    else
      ExpertizaLogger.info("No previous link record found, creating a new one.")
      new = LocalSubmittedContent.new map_id: map_id,
                                      round: round,
                                      link: link,
                                      start_at: start_time,
                                      end_at: nil,
                                      created_at: start_time,
                                      updated_at: start_time,
                                      total_time: 0
      @store.save(new)
    end
  end

  def start_timing_for_round(map_id, round)
    # check for pre-existing record
    records = @store.where(
      map_id: map_id,
      round: round
    )

    _record_start_time(records)
  end

  def _record_start_time(records)
    start_time = DateTime.now
    unless records.empty?
      records.each do |record|
        record.start_at = start_time
        record.end_at = nil
        record.updated_at = start_time
      end
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
    # time for all links
    records = @store.where(map_id: map_id, round: round)
    _record_end_time(records)
  end

  # For each record in [records], set the end time
  # to DateTime.now and update the total_time accumulator
  def _record_end_time(records)
    end_time = DateTime.now
    unless records.empty?
      records.each do |record|
        record.end_at = end_time
        record.updated_at = end_time
        record.total_time += record.time_diff
      end
    end
  end

  # Actually performs the work flushing records from
  # local storage to the database and removing them.
  def save_and_remove_all(map_id, round)
    ExpertizaLogger.info("Flushing LocalStorage to the database...")
    uncommitted = []
    records = @store.where(map_id: map_id, round: round)
    ExpertizaLogger.info("Found #{records.length} records in local storage for timing events")

    unless records.empty?
      records.each do |record|
        # push the uncommitted link on to the stack
        uncommitted << record.link

        previous = SubmissionViewingEvent.where(
          map_id: record.map_id,
          round: record.round,
          link: record.link
        )

        if !previous.empty?
          # make sure to add the total time on this record
          # with what may have already been in the database
          previous.each do |event|
            updated = record.merge(event)
            event.update_attribute(:total_time, updated)
          end
        else
          # if a previous record doesn't exist,
          # we can delegate saving to `LocalStorage`
          @store.hard_save(record)
        end

        # once the data is updated or added to the database,
        # remove it from `LocalStorage`
        @store.remove(record)
      end
    end

    ExpertizaLogger.info("Flushed #{uncommitted.length} links\n#{uncommitted}")
    uncommitted
  end
end