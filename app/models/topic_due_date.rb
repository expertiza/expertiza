class TopicDueDate < DueDate
  belongs_to :topic, class_name: 'SignUpTopic', :foreign_key => 'parent_id'
end