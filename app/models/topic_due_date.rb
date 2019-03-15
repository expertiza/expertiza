class TopicDueDate < DueDate
  belongs_to :topic, class_name: 'SignUpTopic', foreign_key: 'parent_id', inverse_of: 'due_dates'
  belongs_to :deadline_type, class_name: 'DeadlineType', foreign_key: 'deadline_type_id', inverse_of: :topic_due_dates
end
