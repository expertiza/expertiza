class DropOutstandingReviewsMailWorker < MailWorker
  @@deadline_type = "drop_outstanding_reviews"

  def perform(assignment_id, due_at)
    super(assignment_id, @@deadline_type, due_at)
  end

  protected

  def prepare_data
    drop_outstanding_reviews
    drop_one_member_topics if assignment.team_assignment
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

  def drop_one_member_topics
    teams = TeamsUser.all.group(:team_id).count(:team_id)
    teams.keys.each do |team_id|
      if teams[team_id] == 1
        topic_to_drop = SignedUpTeam.where(team_id: team_id).first
        topic_to_drop.delete if topic_to_drop # check if the one-person-team has signed up a topic
      end
    end
  end

end