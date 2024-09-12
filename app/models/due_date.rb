class DueDate < ApplicationRecord
  include Comparable
  validate :due_at_is_valid_datetime
  #  has_paper_trail

  # Retrieves the default permission for a given deadline type and permission type
  def self.default_permission(deadline_type, permission_type)
    DeadlineRight::DEFAULT_PERMISSION[deadline_type][permission_type]
  end

  # Retrieves the current due date from a list of due dates
  def self.current(due_dates)
    due_dates.detect { |due_date| due_date.due_at > Time.now }
  end

  # Checks if teammate review is allowed 
  def teammate_review_allowed?(student)
    due_date = self.class.current(student.assignment.due_dates)
    student.assignment.find_current_stage == 'Finished' ||
      (due_date && [2, 3].include?(due_date.teammate_review_allowed_id))
  end

  def set_flag
    update_attribute(:flag, true)
  end

  # Validates if due_at attribute is a valid datetime
  def due_at_is_valid_datetime
    if due_at.present?
      errors.add(:due_at, 'must be a valid datetime') if (begin
                                                            DateTime.strptime(due_at.to_s, '%Y-%m-%d %H:%M:%S')
                                                          rescue StandardError
                                                            ArgumentError
                                                          end) == ArgumentError
    end
  end

  # Copies due dates from one assignment to another
  def self.copy(old_assignment_id, new_assignment_id)
    where(parent_id: old_assignment_id).each do |orig_due_date|
      new_due_date = orig_due_date.dup
      new_due_date.parent_id = new_assignment_id
      new_due_date.save
    end
  end

  # Sets a due date with specified attributes
  def self.set_due_date(duedate, deadline, assign_id, max_round)
    submit_duedate = DueDate.new(duedate)
    submit_duedate.update(deadline_type_id: deadline, parent_id: assign_id, round: max_round)
  end

  # Compares due dates for sorting purposes
  def <=>(other)
    return nil unless other.is_a?(DueDate)

    if due_at && other.due_at
      due_at <=> other.due_at
    elsif due_at
      -1
    else
      1
    end
  end

  # Determines the round of a response within an assignment
  def self.done_in_assignment_round(assignment_id, response)
    # for author feedback, quiz, teammate review and metareview, Expertiza only support one round, so the round # should be 1
    return 0 if ResponseMap.find(response.map_id).type != 'ReviewResponseMap'

    due_dates = DueDate.where(parent_id: assignment_id)
    # sorted so that the earliest deadline is at the first
    sorted_deadlines = due_dates.sort
    due_dates.reject { |due_date| ![1, 2].include?(due_date.deadline_type_id) }
    round = 1
    sorted_deadlines.each do |due_date|
      break if response.created_at < due_date.due_at

      round += 1 if due_date.deadline_type_id == 2
    end
    round
  end

  # Gets the next due date for an assignment
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
