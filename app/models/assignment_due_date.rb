class AssignmentDueDate < DueDate
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'parent_id'
  belongs_to :deadline_type, class_name: 'DeadlineType', foreign_key: 'deadline_type_id'
  attr_accessible
  # :deadline_type_id, :submission_allowed_id, :parent_id,
  #                 :review_allowed_id, :review_of_review_allowed_id
                  # :due_at,
                  # :round, :flag, :threshold,
                  # :delayed_job_id, :deadline_name, :description_url,
                  # :quiz_allowed_id, :teammate_review_allowed_id, :type
end
