# == Schema Information
#
# Table name: topic_deadlines
#
#  id                          :integer          not null, primary key
#  due_at                      :datetime
#  deadline_type_id            :integer
#  topic_id                    :integer
#  late_policy_id              :integer
#  submission_allowed_id       :integer
#  review_allowed_id           :integer
#  resubmission_allowed_id     :integer
#  rereview_allowed_id         :integer
#  review_of_review_allowed_id :integer
#  round                       :integer
#

class TopicDeadline < ActiveRecord::Base
  belongs_to :topic, :class_name => 'SignUpTopic'

  validate :due_at_is_valid_datetime

  def due_at_is_valid_datetime
    errors.add(:due_at, 'must be a valid datetime') if ((DateTime.strptime(due_at.to_s, '%Y-%m-%d %H:%M:%S') rescue ArgumentError) == ArgumentError)
  end
end
