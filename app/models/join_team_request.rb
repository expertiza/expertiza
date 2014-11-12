class JoinTeamRequest < ActiveRecord::Base
 belongs_to :team
 has_one :participant
end
