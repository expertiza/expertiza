module SignUpSheetHelper
  # if the instructor does not specific the topic due date, it should be the same as assignment due date;
  # otherwise, it should display the topic due date.
  def check_topic_due_date_value(assignment_due_dates, topic_id, deadline_type_id = 1, review_round = 1)
    if TopicDueDate.exists?(parent_id: topic_id, deadline_type_id: deadline_type_id, round: review_round)
      due_date = TopicDueDate.where(parent_id: topic_id,
                                    deadline_type_id: deadline_type_id,
                                    round: review_round).first.due_at
    else
      due_date = assignment_due_dates[review_round - 1].due_at.to_s
    end
    DateTime.parse(due_date.to_s).strftime("%Y-%m-%d %H:%M")
  end
end
