class TopicDueDate < DueDate
  belongs_to :topic, class_name: 'SignUpTopic', foreign_key: 'parent_id'
  belongs_to :deadline_type, class_name: 'DeadlineType', foreign_key: 'deadline_type_id'
end
