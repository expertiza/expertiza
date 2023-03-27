# Class to manage Due Dates of Assignments & Signup Sheet Topics
class DueDate < ApplicationRecord
  validates :due_at, presence: true, if: -> { :due_at.to_s.is_a?(DateTime) }
  #  has_paper_trail

  # Returns permissions allowed for each assignment stage
  # Example: 
  # 'signup' => { 
  #     'submission_allowed' => OK,
  #     'can_review' => NO,
  #     'review_of_review_allowed' => NO
  #  }
  def default_permission(deadline_type, permission_type)
    DeadlineRight::DEFAULT_PERMISSION[deadline_type][permission_type]
  end

  # Copy due dates from one assignment object to another
  def self.copy(old_assignment_id, new_assignment_id)
    duedates = where(parent_id: old_assignment_id)
    duedates.each do |orig_due_date|
      new_due_date = orig_due_date.dup
      new_due_date.parent_id = new_assignment_id
      new_due_date.save
    end
  end

  # Comparator to compare two due dates
  def <=>(other)
    if due_at && other.due_at
      due_at <=> other.due_at
    elsif due_at
      -1
    else
      1
    end
  end
end
