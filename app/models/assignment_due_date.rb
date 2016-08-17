class AssignmentDueDate < DueDate
  belongs_to :assignment, class_name: 'Assignment'
end