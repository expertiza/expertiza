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
    nodes = Node.joins("INNER JOIN #{self.table} ON nodes.node_object_id = #{self.table}.id")
                .select('nodes.*')
                .where('nodes.type = ?', self)
    nodes.where("#{self.table}.team_id = ?", parent_id) if parent_id
  end

  def is_leaf
    true
  end
end
