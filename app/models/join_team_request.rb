class JoinTeamRequest < ActiveRecord::Base
  belongs_to :team
  has_one :participant, dependent: :nullify
  attr_accessible :comments, :status
end
