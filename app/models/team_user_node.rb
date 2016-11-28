class TeamUserNode < Node
  belongs_to :node_object, class_name: 'TeamsUser'
  attr_accessible :parent_id, :node_object_id

  def self.table
    "teams_users"
  end

  def get_name
    TeamsUser.find(self.node_object_id).name
  end

  def self.get(parent_id)
    query = "select nodes.* from nodes, " + self.table
    query = query + " where nodes.node_object_id = " + self.table + ".id"
    query = query + " and nodes.type = '" + self.to_s + "'"
    query = query + " and " + self.table + ".team_id = " + parent_id.to_s if parent_id
    find_by_sql(query)
  end

  def is_leaf
    true
  end
end
