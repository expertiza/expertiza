# Class to manage Due Dates of Assignments & Signup Sheet Topics
class DueDate < ApplicationRecord
  validates :due_at, presence: true, if: -> { :due_at.to_s.is_a?(DateTime) }
  #  has_paper_trail

  def default_permission(deadline_type, permission_type)
    DeadlineRight::DEFAULT_PERMISSION[deadline_type][permission_type]
  end

  def self.copy(old_assignment_id, new_assignment_id)
    duedates = where(parent_id: old_assignment_id)
    duedates.each do |orig_due_date|
      new_due_date = orig_due_date.dup
      new_due_date.parent_id = new_assignment_id
      new_due_date.save
    end
  end

  def <=>(other)
    if due_at && other.due_at
      due_at <=> other.due_at
    elsif due_at
      -1
    else
      1
    end
  end

  def self.deadline_sort(due_dates)
    due_dates.sort
  end
  
  def self.assignment_latest_review_round(assignment_id, response)
    # for author feedback, quiz, teammate reviews, rounds # should be 1
    maps = ResponseMap.where(id: response.map_id, type: 'ReviewResponseMap')
    return 0 if maps.empty?

    # sorted so that the earliest deadline is at the first
    sorted_deadlines = deadline_sort(DueDate.where(parent_id: assignment_id))
    round = 1
    sorted_deadlines.each do |due_date|
      round += 1 if due_date.deadline_type_id == 2 && response.created_at >= due_date.due_at
    end
    round
  end
end
