class TopicDueDate < DueDate
  belongs_to :topic, class_name: 'SignUpTopic'
end