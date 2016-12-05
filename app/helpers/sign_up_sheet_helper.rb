module SignUpSheetHelper

  # This method was refactored and logic for getting due dates was moved to the method get_topic_deadline as we needed
  #to use the same logic for another purpose but the return types were'nt matching.
  def check_topic_due_date_value(assignment_due_dates, topic_id, deadline_type_id = 1, review_round = 1)
    due_date=get_topic_deadline(assignment_due_dates,topic_id,deadline_type_id,review_round)
    DateTime.parse(due_date.to_s).strftime("%Y-%m-%d %H:%M")
  end

  # if the instructor does not specify the topic due date, it should be the same as assignment due date;
  # otherwise, it should return the topic due date.
  def get_topic_deadline(assignment_due_dates, topic_id,deadline_type_id,review_round)
    topic_due_date = TopicDueDate.where(parent_id: topic_id,
                                        deadline_type_id: deadline_type_id,
                                        round: review_round).first rescue nil
    if !topic_due_date.nil?
      due_date = topic_due_date.due_at
    else
      due_date = assignment_due_dates[review_round - 1].due_at
    end
  end
end
