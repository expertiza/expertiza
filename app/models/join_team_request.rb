class JoinTeamRequest < ApplicationRecord
  belongs_to :team
  has_one :participant, dependent: :nullify
  # attr_accessible :comments, :status
end
