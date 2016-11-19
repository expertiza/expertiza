class JoinGroupRequest < ActiveRecord::Base
  has_one :participant
  belongs_to :group
end
