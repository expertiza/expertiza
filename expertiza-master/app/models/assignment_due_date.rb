class AssignmentDueDate < DueDate
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'parent_id'
  belongs_to :deadline_type, class_name: 'DeadlineType', foreign_key: 'deadline_type_id'
end
