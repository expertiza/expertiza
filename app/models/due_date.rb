class DueDate < ApplicationRecord
  validate :due_at_is_valid_datetime
  #  has_paper_trail

  def self.default_permission(deadline_type, permission_type)
    DeadlineRight::DEFAULT_PERMISSION[deadline_type][permission_type]
  end

  def self.current_due_date(due_dates)
    # Get the current due date from list of due dates
    due_dates.each do |due_date|
      if due_date.due_at > Time.now
        current_due_date = due_date
        return current_due_date
      end
    end
    # in case current due date not found
    nil
  end

  def self.teammate_review_allowed(student)
    # time when teammate review is allowed
    due_date = current_due_date(student.assignment.due_dates)
    student.assignment.find_current_stage == 'Finished' ||
      due_date &&
        (due_date.teammate_review_allowed_id == 3 ||
        due_date.teammate_review_allowed_id == 2) # late(2) or yes(3)
  end

  def set_flag
    self.flag = true
    save
  end

  def due_at_is_valid_datetime
    if due_at.present?
      errors.add(:due_at, 'must be a valid datetime') if (begin
                                                            DateTime.strptime(due_at.to_s, '%Y-%m-%d %H:%M:%S')
                                                          rescue StandardError
                                                            ArgumentError
                                                          end) == ArgumentError
    end
  end

  def self.copy(old_assignment_id, new_assignment_id)
    duedates = where(parent_id: old_assignment_id)
    duedates.each do |orig_due_date|
      new_due_date = orig_due_date.dup
      new_due_date.parent_id = new_assignment_id
      new_due_date.save
    end
  end

  def self.set_duedate(duedate, deadline, assign_id, max_round)
    submit_duedate = DueDate.new(duedate)
    submit_duedate.deadline_type_id = deadline
    submit_duedate.parent_id = assign_id
    submit_duedate.round = max_round
    submit_duedate.save
  end

  def self.deadline_sort(due_dates)
    due_dates.sort do |m1, m2|
      if m1.due_at && m2.due_at
        m1.due_at <=> m2.due_at
      elsif m1.due_at
        -1
      else
        1
      end
    end
  end

  def self.done_in_assignment_round(assignment_id, response)
    # for author feedback, quiz, teammate review and metareview, Expertiza only support one round, so the round # should be 1
    return 0 if ResponseMap.find(response.map_id).type != 'ReviewResponseMap'

    due_dates = DueDate.where(parent_id: assignment_id)
    # sorted so that the earliest deadline is at the first
    sorted_deadlines = deadline_sort(due_dates)
    due_dates.reject { |due_date| due_date.deadline_type_id != 1 && due_date.deadline_type_id != 2 }
    round = 1
    sorted_deadlines.each do |due_date|
      break if response.created_at < due_date.due_at

      round += 1 if due_date.deadline_type_id == 2
    end
    round
  end

  def self.get_next_due_date(assignment_id, topic_id = nil)
    if Assignment.find(assignment_id).staggered_deadline?
      next_due_date = TopicDueDate.find_by(['parent_id = ? and due_at >= ?', topic_id, Time.zone.now])
      # if certion TopicDueDate is not exist, we should query next corresponding AssignmentDueDate.
      # eg. Time.now is 08/28/2016
      # One topic uses following deadlines:
      # TopicDueDate      08/01/2016
      # TopicDueDate      08/02/2016
      # TopicDueDate      08/03/2016
      # AssignmentDueDate 09/04/2016
      # In this case, we cannot find due_at later than Time.now in TopicDueDate.
      # So we should find next corresponding AssignmentDueDate, starting with the 4th one, not the 1st one!
      if next_due_date.nil?
        topic_due_date_size = TopicDueDate.where(parent_id: topic_id).size
        following_assignment_due_dates = AssignmentDueDate.where(parent_id: assignment_id)[topic_due_date_size..-1]
        unless following_assignment_due_dates.nil?
          following_assignment_due_dates.each do |assignment_due_date|
            if assignment_due_date.due_at >= Time.zone.now
              next_due_date = assignment_due_date
              break
            end
          end
        end
      end
    else
      next_due_date = AssignmentDueDate.find_by(['parent_id = ? && due_at >= ?', assignment_id, Time.zone.now])
    end
    next_due_date
  end
end
