class DropOutstandingReviewsMailWorker < MailWorker
  @@deadline_type = "drop_outstanding_reviews"

  def perform(assignment_id, due_at)
    super(assignment_id, @@deadline_type, due_at)
  end

  protected

  def prepare_data
    drop_outstanding_reviews
  end

  private
	
  def drop_outstanding_reviews
    reviews = ResponseMap.where(reviewed_object_id: @assignment.id)
    reviews.each do |review|
      review_has_began = Response.where(map_id: review.id)
      if review_has_began.size.zero?
        review_to_drop = ResponseMap.where(id: review.id)
        review_to_drop.first.destroy
      end
    end
  end
end
