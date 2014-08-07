class DueDate < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :deadline_type
  validate :due_at_is_valid_datetime

  def self.default_permission(deadline_type, permission_type)
    permission_id = Hash.new
    permission_id['OK'] = DeadlineRight.find_by_name('OK').id
    permission_id['No'] = DeadlineRight.find_by_name('No').id
    permission_id['Late'] = DeadlineRight.find_by_name('Late').id

    default_permission = Hash.new
    default_permission['submission'] = Hash.new
    default_permission['submission']['submission_allowed'] = permission_id['OK']
    default_permission['submission']['review_allowed'] = permission_id['No']
    default_permission['submission']['review_of_review_allowed'] = permission_id['No']

    default_permission['review'] = Hash.new
    default_permission['review']['submission_allowed'] = permission_id['No']
    default_permission['review']['review_allowed'] = permission_id['OK']
    default_permission['review']['review_of_review_allowed'] = permission_id['No']

    default_permission['metareview'] = Hash.new
    default_permission['metareview']['submission_allowed'] = permission_id['No']
    default_permission['metareview']['review_allowed'] = permission_id['No']
    default_permission['metareview']['review_of_review_allowed'] = permission_id['OK']

    default_permission['drop_topic'] = Hash.new
    default_permission['drop_topic']['submission_allowed'] = permission_id['OK']
    default_permission['drop_topic']['review_allowed'] = permission_id['No']
    default_permission['drop_topic']['review_of_review_allowed'] = permission_id['No']

    default_permission['signup'] = Hash.new
    default_permission['signup']['submission_allowed'] = permission_id['OK']
    default_permission['signup']['review_allowed'] = permission_id['No']
    default_permission['signup']['review_of_review_allowed'] = permission_id['No']

    default_permission['team_formation'] = Hash.new
    default_permission['team_formation']['submission_allowed'] = permission_id['OK']
    default_permission['team_formation']['review_allowed'] = permission_id['No']
    default_permission['team_formation']['review_of_review_allowed'] = permission_id['No']

    default_permission[deadline_type][permission_type]
  end

  def type
    self.deadline_type.name
  end

  def due_at_is_valid_datetime
    unless due_at.blank?
      errors.add(:due_at, 'must be a valid datetime') if ((DateTime.strptime(due_at.to_s, '%Y-%m-%d %H:%M:%S') rescue ArgumentError) == ArgumentError)
    end
  end

  def self.copy(old_assignment_id, new_assignment_id)
    duedates = where(['assignment_id = ?', old_assignment_id])
    duedates.each do |orig_due_date|
      new_due_date = orig_due_date.clone
      new_due_date.assignment_id = new_assignment_id
      new_due_date.save
    end
  end

  def self.set_duedate (duedate, deadline, assign_id, max_round)
    submit_duedate=DueDate.new(duedate)
    submit_duedate.deadline_type_id = deadline
    submit_duedate.assignment_id = assign_id
    submit_duedate.round = max_round
    submit_duedate.save
  end

  def setFlag()
    self.flag = true
    self.save
  end

  def self.assign_topic_deadline(due_date,offset,topic_id)
    topic_deadline = TopicDeadline.new
    topic_deadline.topic_id = topic_id
    topic_deadline.due_at = DateTime.parse(due_date.due_at.to_s) + offset.to_i
    topic_deadline.deadline_type_id = due_date.deadline_type_id
    topic_deadline.late_policy_id = due_date.late_policy_id
    topic_deadline.submission_allowed_id = due_date.submission_allowed_id
    topic_deadline.review_allowed_id = due_date.review_allowed_id
    #topic_deadline.resubmission_allowed_id = due_date.resubmission_allowed_id
    #topic_deadline.rereview_allowed_id = due_date.rereview_allowed_id
    topic_deadline.review_of_review_allowed_id = due_date.review_of_review_allowed_id
    topic_deadline.round = due_date.round
    topic_deadline.save
  end

end
