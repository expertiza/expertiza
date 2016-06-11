class TeamsParticipant < ActiveRecord::Base
  belongs_to :user
  belongs_to :team

  def name
    self.user.name
  end

  def delete
    TeamUserNode.find_by_node_object_id(self.id)
    team = self.team
    self.destroy
    team.delete if team.teams_participants.empty?
  end

  def hello
    "Hello"
  end

  def get_team_members(team_id)
  end
end
