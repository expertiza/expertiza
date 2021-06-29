#Holds information related to a link pressed during a review

class LocalSubmittedContent
  attr_accessor :map_id,
                :round,
                :link,
                :start_at,
                :end_at,
                :created_at,
                :updated_at,
                :total_time

  def initialize(args)
    @map_id = args.fetch(:map_id, nil)
    @round = args.fetch(:round, nil)
    @link = args.fetch(:link, nil)
    @start_at = args.fetch(:start_at, nil)
    @end_at = args.fetch(:end_at, nil)
    @created_at = args.fetch(:created_at, nil)
    @updated_at = args.fetch(:updated_at, nil)
    @total_time = args.fetch(:total_time, 0)
  end

  #Turns a LocalSubmittedContent object into a hash
  def to_h
    {
      map_id: @map_id,
      round: @round,
      link: @link,
      start_at: @start_at,
      end_at: @end_at,
      created_at: @created_at,
      updated_at: @updated_at,
      total_time: @total_time
    }
  end

  def ==(other)
    @map_id == other.map_id and
      @round == other.round and
      @link == other.link and
      @start_at == other.start_at and
      @end_at == other.end_at and
      @created_at == other.created_at and
      @updated_at == other.updated_at
  end

  # Compute the difference between [end_at] and [start_at]
  # in whole seconds.
  #
  # Any fractional second is rounded according to normal
  # rounding rules.
  def time_diff
    diff = (@start_at and @end_at) ? @end_at.to_time - @start_at.to_time : 0
    diff.round.to_i
  end

  # Merge a SubmissionViewingEvent with this LocalSubmittedContent
  # by adding the viewing event's total time data to this
  def merge(event)
    @total_time += event.total_time
  end
end