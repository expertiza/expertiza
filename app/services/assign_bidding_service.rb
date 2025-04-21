class AssignBiddingService
    Result = Struct.new(:success?, :error_message)
  
    def self.call(participant)
      new(participant).tap(&:run).result
    end
  
    def initialize(participant)
      @participant = participant
      @assignment  = participant.assignment
      @result      = Result.new(true, nil)
    end
  
    # Manages the bidding assignment process
    def run
      ActiveRecord::Base.transaction do
        reviewer_ids   = fetch_reviewer_ids
        matched_topics = process_bidding(reviewer_ids)
        ensure_valid_topics(matched_topics, reviewer_ids)
        ReviewBid.assign_review_topics(
          @assignment.id,
          reviewer_ids,
          matched_topics
        )
  
        @assignment.update!(can_choose_topic_to_review: false)
      end
    rescue => e
      @result = Result.new(false, e.message)
    end
  
    def result
      @result
    end
  
    private
  
    # Fetch all reviewer participant IDs for this assignment
    def fetch_reviewer_ids
      AssignmentParticipant
        .where(assignment_id: @assignment.id)
        .pluck(:id)
    end
  
    # Runs the bidding algorithm using the external web service
    # Falls back to the built-in algorithm if the service fails
    def process_bidding(reviewer_ids)
      response = BidsAlgorithmService.process_bidding(@assignment.id, reviewer_ids)
      if response[:success]
        response[:data]
      else
        Rails.logger.error("Bidding webservice failed: #{response[:error]}. Using fallback algorithm.")
        ReviewBid.fallback_algorithm(@assignment.id, reviewer_ids)
      end
    end
  
    # Ensures each reviewer has at least one topic assigned
    # Raises an exception if any reviewer is missing assignments
    def ensure_valid_topics(matched_topics, reviewer_ids)
      missing = reviewer_ids.reject do |rev_id|
        topics = matched_topics[rev_id.to_s]
        topics.is_a?(Array) && topics.any?
      end
  
      return if missing.empty?
  
      raise "Invalid topic assignments: no topics for reviewers: #{missing.join(', ')}"
    end
  end
  
  # Controller method (ReviewBidsController)
  def assign_bidding
    result = AssignBiddingService.call(@participant)
  
    unless result.success?
      redirect_back fallback_location: root_path,
                    alert: "Could not assign bids: #{result.error_message}"
      return
    end
  
    flash[:notice] = 'Bidding assignments updated.'
    redirect_back fallback_location: root_path
  end
  