# == Schema Information
#
# Table name: teams_users
#
#  id      :integer          not null, primary key
#  team_id :integer
#  user_id :integer
#

class TeamsUser < ActiveRecord::Base  
  belongs_to :user
  belongs_to :team
  
  def name
    self.user.name
  end
  
  def delete
    TeamUserNode.find_by_node_object_id(self.id)
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
