class TeamsUser < ActiveRecord::Base  
  belongs_to :user
  belongs_to :team
  has_one :team_user_node,:foreign_key => :node_object_id,:dependent => :destroy
  has_paper_trail
  
  def name
    self.user.name
  end
  
  def delete
    TeamUserNode.find_by_node_object_id(self.id).destroy
    team = self.team
    self.destroy
    if team.teams_users.length == 0
      team.delete    
    end
  end

  def hello
    return "Hello"
  end

  def get_team_members(team_id)



  end
end