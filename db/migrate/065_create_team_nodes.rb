class CreateTeamNodes < ActiveRecord::Migration[4.2]
  def self.up
    teams = Team.all
    teams.each do |team|
      parent = AssignmentNode.find_by_node_object_id(team.parent_id)
      TeamNode.create(node_object_id: team.id, parent_id: parent.id) if parent
    end
  end

  def self.down
    nodes = TeamNode.all
    nodes.each(&:destroy)
  end
end
