class TopicDeadline < ActiveRecord::Base
  belongs_to :topic, :class_name => 'SignUpTopic'

  validate :due_at_is_valid_datetime
  def self.find_with_tid_and_dtype(tid,dtype)
    TopicDeadline.where(topic_id:tid, deadline_type_id:  dtype)
  end

  def self.find_with_tid_and_dtype_and_round(tid,dtype,round)
    TopicDeadline.where(topic_id:tid, deadline_type_id:  dtype, round: round)
  end

  def due_at_is_valid_datetime
    errors.add(:due_at, 'must be a valid datetime') if ((DateTime.strptime(due_at.to_s, '%Y-%m-%d %H:%M:%S') rescue ArgumentError) == ArgumentError)
  end
end
