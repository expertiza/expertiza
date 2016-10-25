class JoinTeamRequest < ActiveRecord::Base
  belongs_to :team
  has_one :participant


  # Check if this is the first joinTeam request
  def firstRequest?
    requests = JoinTeamRequest.where(["team_id =? and participant_id=?", self.team_id,self.participant_id])
    (requests.count < 1)
  end

end
