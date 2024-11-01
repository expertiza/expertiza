# This helper contains methods to manipulate due dates of topics in an assignment. This helper if used by
# sign_up_controller
module DeadlineHelper
  DEADLINE_TYPE_SUBMISSION = 1
  DEADLINE_TYPE_REVIEW = 2
  DEADLINE_TYPE_METAREVIEW = 5
  DEADLINE_TYPE_DROP_TOPIC = 6
  DEADLINE_TYPE_SIGN_UP = 7
  DEADLINE_TYPE_TEAM_FORMATION = 8

  # Creates a new topic deadline for topic specified by topic_id.
  # The deadline itself is specified by due_date object which contains several values which specify
  # type { submission deadline, metareview deadline, etc.} a set of other parameters that
  # specify whether submission, review, metareview, etc. are allowed for the particular deadline
  def create_topic_deadline(due_date, offset, topic_id)
    topic_deadline = TopicDueDate.new
    topic_deadline.parent_id = topic_id
    topic_deadline.due_at = Time.zone.parse(due_date.due_at.to_s) + offset.to_i
    topic_deadline.deadline_type_id = due_date.deadline_type_id
    # select count(*) from topic_deadlines where late_policy_id IS NULL;
    # all 'late_policy_id' in 'topic_deadlines' table is NULL
    # topic_deadline.late_policy_id = nil
    topic_deadline.submission_allowed_id = due_date.submission_allowed_id
    topic_deadline.review_allowed_id = due_date.review_allowed_id
    topic_deadline.review_of_review_allowed_id = due_date.review_of_review_allowed_id
    topic_deadline.round = due_date.round
    topic_deadline.save
  end
end
