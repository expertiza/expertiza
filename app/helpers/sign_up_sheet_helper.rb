module SignUpSheetHelper
  # if the instructor does not specific the topic due date, it should be the same as assignment due date;
  # otherwise, it should display the topic due date.
  def check_topic_due_date_value(assignment_due_dates, topic_id, deadline_type_id = 1, review_round = 1)
    due_date = get_topic_deadline(assignment_due_dates, topic_id, deadline_type_id, review_round)
    DateTime.parse(due_date.to_s).strftime("%Y-%m-%d %H:%M").in_time_zone
  end

  def get_topic_deadline(assignment_due_dates, topic_id, deadline_type_id = 1, review_round = 1)
    topic_due_date = TopicDueDate.where(parent_id: topic_id,
                                        deadline_type_id: deadline_type_id,
                                        round: review_round).first rescue nil
    if !topic_due_date.nil?
      topic_due_date.due_at
    else
      assignment_due_dates[review_round - 1].due_at.to_s
    end
  end
end
