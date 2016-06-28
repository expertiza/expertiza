class DueDate < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :deadline_type
  validate :due_at_is_valid_datetime
  #  has_paper_trail

  @@permission_id = {}
  @@permission_id['OK'] = DeadlineRight.exists?(name: 'OK') ? DeadlineRight.find_by_name('OK').id : 3
  @@permission_id['No'] = DeadlineRight.exists?(name: 'No') ? DeadlineRight.find_by_name('No').id : 1
  @@permission_id['Late'] = DeadlineRight.exists?(name: 'Late') ? DeadlineRight.find_by_name('Late').id : 2

  def self.default_permission(deadline_type, permission_type)
    permission_id = {}

    default_permission = {}
    case deadline_type
    when 'submission'
      default_permission['submission'] = {}
      default_permission['submission']['submission_allowed'] = @@permission_id['OK']
      default_permission['submission']['can_review'] = @@permission_id['No']
      default_permission['submission']['review_of_review_allowed'] = @@permission_id['No']
    when 'review'
      default_permission['review'] = {}
      default_permission['review']['submission_allowed'] = @@permission_id['No']
      default_permission['review']['can_review'] = @@permission_id['OK']
      default_permission['review']['review_of_review_allowed'] = @@permission_id['No']
    when 'metareview'
      default_permission['metareview'] = {}
      default_permission['metareview']['submission_allowed'] = @@permission_id['No']
      default_permission['metareview']['can_review'] = @@permission_id['No']
      default_permission['metareview']['review_of_review_allowed'] = @@permission_id['OK']
    when 'drop_topic'
      default_permission['drop_topic'] = {}
      default_permission['drop_topic']['submission_allowed'] = @@permission_id['OK']
      default_permission['drop_topic']['can_review'] = @@permission_id['No']
      default_permission['drop_topic']['review_of_review_allowed'] = @@permission_id['No']
    when 'signup'
      default_permission['signup'] = {}
      default_permission['signup']['submission_allowed'] = @@permission_id['OK']
      default_permission['signup']['can_review'] = @@permission_id['No']
      default_permission['signup']['review_of_review_allowed'] = @@permission_id['No']
    when 'team_formation'
      default_permission['team_formation'] = {}
      default_permission['team_formation']['submission_allowed'] = @@permission_id['OK']
      default_permission['team_formation']['can_review'] = @@permission_id['No']
      default_permission['team_formation']['review_of_review_allowed'] = @@permission_id['No']
    end

    default_permission[deadline_type][permission_type]
  end

  def type
    self.deadline_type.name
  end

  def set_flag
    self.flag = true
    self.save
  end

  def due_at_is_valid_datetime
    unless due_at.blank?
      errors.add(:due_at, 'must be a valid datetime') if (DateTime.strptime(due_at.to_s, '%Y-%m-%d %H:%M:%S') rescue ArgumentError) == ArgumentError
    end
  end

  def self.copy(old_assignment_id, new_assignment_id)
    duedates = where(['assignment_id = ?', old_assignment_id])
    duedates.each do |orig_due_date|
      new_due_date = orig_due_date.dup
      new_due_date.assignment_id = new_assignment_id
      new_due_date.save
    end
  end

  def self.set_duedate(duedate, deadline, assign_id, max_round)
    submit_duedate = DueDate.new(duedate)
    submit_duedate.deadline_type_id = deadline
    submit_duedate.assignment_id = assign_id
    submit_duedate.round = max_round
    submit_duedate.save
  end



  def self.deadline_sort(due_dates)
    due_dates.sort {|m1, m2| (m1.due_at and m2.due_at) ? m1.due_at <=> m2.due_at : (m1.due_at ? -1 : 1) }
  end

  def self.done_in_assignment_round(assignment_id, response)
    # for author feedback, quiz, teammate review and metareview, Expertiza only support one round, so the round # should be 1
    return 0 if ResponseMap.find(response.map_id).type != "ReviewResponseMap"
    due_dates = DueDate.where(["assignment_id = ?", assignment_id])
    sorted_deadlines = []
    # sorted so that the earliest deadline is at the first
    sorted_deadlines = deadline_sort(due_dates)
    due_dates.reject {|due_date| due_date.type != 1 && due_date.type != 2 }
    round = 1
    for due_date in sorted_deadlines
      break if response.created_at < due_date.due_at
      round += 1 if due_date.type == 2
    end
    round
  end
end
