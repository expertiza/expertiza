class CalculatedPenalty < ApplicationRecord
  belongs_to :participant, class_name: 'Participant', foreign_key: 'participant_id', dependent: :destroy
  belongs_to :deadline_type, class_name: 'DeadlineType', foreign_key: 'deadline_type_id'
end
