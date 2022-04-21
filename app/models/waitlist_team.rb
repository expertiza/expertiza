class WaitlistTeam < ApplicationRecord
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :team, class_name: 'Team'

  validates :topic_id, :team_id, presence: true
  scope :by_team_id, ->(team_id) { where('team_id = ?', team_id) }
  scope :by_topic_id, ->(topic_id) { where('topic_id = ?', topic_id) }
end