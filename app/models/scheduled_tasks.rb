class ScheduledTasks
  # Keeps info required for scheduled task (see delayed job gem)
  # to perform an action at a particular time
  attr_accessor :task
  attr_accessor :due_at

  # every task must have task variable saying what the task is and a
  # due_at variable saying when the task needs to executed
  # kwargs that are valid will depend on the task
  def initialize(task, due_at, **kwargs)
    self.task = task
    self.due_at = due_at
    self.kwargs = kwargs
  end

  # All scheduled tasks must have a perform method which is called when the
  # delayed job is executed
  # see delayed_job gem documentation
  def perform
    case task
    when :drop_one_member_topics
      assignment_id = self.kwargs[:assignment_id]
      assignment = Assignment.find(assignment_id)
      drop_one_member_topics unless assignment.nil?
    when :drop_outstanding_reviews
      assignment_id = self.kwargs[:assignment_id]
      assignment = Assignment.find(assignment_id)
      drop_outstanding_reviews unless assignment.nil?
    end
  end

  def drop_one_member_topics
    teams = TeamsUser.all.group(:team_id).count(:team_id)
    teams.keys.each do |team_id|
      if teams[team_id] == 1
        topic_to_drop = SignedUpTeam.find_by(team_id: team_id)
        topic_to_drop.delete if topic_to_drop # check if the one-person-team has signed up a topic
      end
    end
  end

  def drop_outstanding_reviews
    reviews = ResponseMap.where(reviewed_object_id: self.assignment_id)
    reviews.each do |review|
      review_has_began = Response.where(map_id: review.id)
      if review_has_began.size.zero?
        review_to_drop = ResponseMap.where(id: review.id)
        review_to_drop.first.destroy
      end
    end
  end
end
