class TeamUserNode < Node
  belongs_to :node_object, class_name: 'TeamsUser'
  # attr_accessible :parent_id, :node_object_id  # unnecessary protected attributes

  def self.table
    'teams_users'
  end

  # Gets the name of the user of the team depending on the object id which is team_user id
  def get_name(ip_address = nil)
    TeamsUser.find(node_object_id).name(ip_address)
  end


  # Gets the team users/members based on the query
  def self.get(parent_id)
    nodes = Node.joins('INNER JOIN teams_users ON nodes.node_object_id = teams_users.id')
                .select('nodes.*')
                .where("nodes.type = 'TeamUserNode'")
    nodes.where('teams_users.team_id = ?', parent_id) if parent_id
  end

  # Indicates that this object is always a leaf
  def is_leaf
    true
  end
end
