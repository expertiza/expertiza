# app/services/review_report_service.rb
class ReviewReportService
    attr_reader :assignment
  
    # Initialize with the assignment object
    def initialize(assignment)
      @assignment = assignment
    end
  
    #
    # Gets the response map data such as reviewer id, reviewed object id, and type for the review report
    #
    def get_data_for_review_report(reviewed_object_id, reviewer_id, type)
      rspan = 0
      initialize_review_round_counters
  
      response_maps = fetch_response_maps(reviewed_object_id, reviewer_id, type)
      process_response_maps(response_maps, rspan)
    end
  
    private
  
    # Initialize counters for each review round
    def initialize_review_round_counters
      @review_round_counters = {}
      (1..@assignment.num_review_rounds).each do |round|
        @review_round_counters["review_in_round_#{round}"] = 0
      end
    end
  
    # Fetch response maps based on the given parameters
    def fetch_response_maps(reviewed_object_id, reviewer_id, type)
      ResponseMap.where(reviewed_object_id: reviewed_object_id, reviewer_id: reviewer_id, type: type)
    end
  
    # Process each response map and update counters
    def process_response_maps(response_maps, rspan)
      response_maps.each do |response_map|
        rspan += 1 if Team.exists?(id: response_map.reviewee_id)
        update_review_round_counters(response_map)
      end
      [response_maps, rspan, @review_round_counters]
    end
  
    # Update review round counters based on responses
    def update_review_round_counters(response_map)
      responses = response_map.response
      (1..@assignment.num_review_rounds).each do |round|
        if responses.exists?(round: round)
          @review_round_counters["review_in_round_#{round}"] += 1
        end
      end
    end
  end