class TeamNode < Node
  belongs_to :node_object, class_name: 'Team', inverse_of: :team_node
  attr_accessible :parent_id, :node_object_id
  def self.table
    "teams"
  end

  def self.get(parent_id)
    nodes = Node.joins("INNER JOIN teams ON nodes.node_object_id = teams.id")
                .select('nodes.*')
                .where("nodes.type = 'TeamNode'")
    nodes.where("teams.parent_id = ?", parent_id) if parent_id
  end

  def get_name(_ip_address = nil)
    Team.find(self.node_object_id).name
  end

  def get_children()
    TeamUserNode.get(self.node_object_id)
  end
end
