class DropOutstandingReviewsWorker < Worker
    @@deadline_type = "drop_outstanding_reviews"
  
    # Runs the delayed Sidekiq function for dropping outstanding reviews
    def perform(assignment_id)
      drop_outstanding_reviews(assignment_id)
    end
  
    private
  
    # Drops reviews that have not been worked on	
    def drop_outstanding_reviews(assignment_id)
      reviews = ResponseMap.where(reviewed_object_id: assignment_id)
      reviews.each do |review|
        review_has_began = Response.where(map_id: review.id)
        if review_has_began.size.zero?
          review_to_drop = ResponseMap.where(id: review.id)
          review_to_drop.first.destroy
        end
      end
    end
  end