class DeadlineType < ApplicationRecord
  has_many :assignment_due_dates, class_name: 'AssignmentDueDate', foreign_key: 'deadline_type_id'
  has_many :topic_due_dates, class_name: 'TopicDueDate', foreign_key: 'deadline_type_id'

  def default_permission(deadline_type, permission_type)
    DeadlineRight::DEFAULT_PERMISSION[deadline_type][permission_type]
  end
end
