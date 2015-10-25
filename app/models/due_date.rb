class DueDate < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :deadline_type
  validate :due_at_is_valid_datetime
#  has_paper_trail

  def self.default_permission(deadline_type, permission_type)
    permission_id = Hash.new
    permission_id['OK'] = DeadlineRight.find_by_name('OK').id
    permission_id['No'] = DeadlineRight.find_by_name('No').id
    permission_id['Late'] = DeadlineRight.find_by_name('Late').id

    default_permission = Hash.new
    default_permission['submission'] = Hash.new
    default_permission['submission']['submission_allowed'] = permission_id['OK']
    default_permission['submission']['can_review'] = permission_id['No']
    default_permission['submission']['review_of_review_allowed'] = permission_id['No']

    default_permission['review'] = Hash.new
    default_permission['review']['submission_allowed'] = permission_id['No']
    default_permission['review']['can_review'] = permission_id['OK']
    default_permission['review']['review_of_review_allowed'] = permission_id['No']

    default_permission['metareview'] = Hash.new
    default_permission['metareview']['submission_allowed'] = permission_id['No']
    default_permission['metareview']['can_review'] = permission_id['No']
    default_permission['metareview']['review_of_review_allowed'] = permission_id['OK']

    default_permission['drop_topic'] = Hash.new
    default_permission['drop_topic']['submission_allowed'] = permission_id['OK']
    default_permission['drop_topic']['can_review'] = permission_id['No']
    default_permission['drop_topic']['review_of_review_allowed'] = permission_id['No']

    default_permission['signup'] = Hash.new
    default_permission['signup']['submission_allowed'] = permission_id['OK']
    default_permission['signup']['can_review'] = permission_id['No']
    default_permission['signup']['review_of_review_allowed'] = permission_id['No']

    default_permission['team_formation'] = Hash.new
    default_permission['team_formation']['submission_allowed'] = permission_id['OK']
    default_permission['team_formation']['can_review'] = permission_id['No']
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
      new_due_date = orig_due_date.dup
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
    #select count(*) from topic_deadlines where late_policy_id IS NULL;
    #all 'late_policy_id' in 'topic_deadlines' table is NULL
    topic_deadline.late_policy_id = nil
    topic_deadline.submission_allowed_id = due_date.submission_allowed_id
    topic_deadline.review_allowed_id = due_date.review_allowed_id
    #topic_deadline.resubmission_allowed_id = due_date.resubmission_allowed_id
    #topic_deadline.rereview_allowed_id = due_date.rereview_allowed_id
    topic_deadline.review_of_review_allowed_id = due_date.review_of_review_allowed_id
    topic_deadline.round = due_date.round
    topic_deadline.save
  end

  def self.done_in_assignment_round(assignment_id, response)
    #for author feedback, quiz, teammate review and metareview, Expertiza only support one round, so the round # should be 1
    if(ResponseMap.find(response.map_id).type!="ReviewResponseMap")
      return 0
    end
    due_dates = DueDate.where(["assignment_id = ?", assignment_id])
    sorted_deadlines = Array.new
    #sorted so that the earliest deadline is at the first
    sorted_deadlines = due_dates.sort { |m1, m2| (m1.due_at and m2.due_at) ? m1.due_at <=> m2.due_at : (m1.due_at ? -1 : 1) }
    due_dates.reject{|due_date| due_date.type!=1 && due_date.type!=2}
    round=1;
    for due_date in sorted_deadlines
      if (response.created_at < due_date.due_at)
        break;
      end
      if due_date.type==2
        round+=1;
      end
    end
    round
  end
end
