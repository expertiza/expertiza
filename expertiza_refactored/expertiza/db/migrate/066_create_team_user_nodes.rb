class CreateTeamUserNodes < ActiveRecord::Migration
  def self.up
    begin
      remove_column :teams_participants, :assignment_id
    rescue
    end
    
    teamsusers = TeamsParticipant.find(:all)
    teamsusers.each{
      | user |
      parent = TeamNode.find_by_node_object_id(user.team_id)
      if parent
        TeamUserNode.create(:node_object_id => user.id, :parent_id => parent.id )
      end
    }    
  end

  def self.down
    teamsusers = TeamsParticipant.find(:all)
    teamsusers.each{
       |user|
       user.destroy
    }
    
    add_column :teams_participants, :assignment_id, :integer
  end
end
