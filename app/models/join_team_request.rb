class JoinTeamRequest < ActiveRecord::Base
  belongs_to :team
  has_one :participant


  # Check if this is the first joinTeam request
  def firstRequest?
    requests = JoinTeamRequest.where(
        ["team_id =? and participant_id=?", self.team_id,self.participant_id])
    (requests.count < 1)
  end

  def self.remove_pending_join_team_requests(participant_id)
    pendingJoinTeamRequests = JoinTeamRequest.where(["status =? and participant_id=?", 'P',participant_id]).destroy_all
    #debugger
    #pendingInvites.each do |invite|
    #  invite.destroy
    #end
  end

end
