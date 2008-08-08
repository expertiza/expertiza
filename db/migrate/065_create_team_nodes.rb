class CreateTeamNodes < ActiveRecord::Migration
  def self.up
    teams = Team.find(:all)
    teams.each{
      | team |
      parent = AssignmentNode.find_by_node_object_id(team.parent_id)
      if parent
        TeamNode.create(:node_object_id => team.id, :parent_id => parent.id)
      end
    }
  end

  def self.down
    nodes = TeamNode.find(:all)
    nodes.each{
      |node|
      node.destroy
    }
  end
end
