class TeamUserNode < Node
  belongs_to :node_object, class_name: 'TeamsParticipant'
  # attr_accessible is no longer needed in newer Rails versions as we use Strong Parameters

  def self.table
    'team_user_nodes'
  end

  def get_name(ip_address = nil)
    TeamsParticipant.find(node_object_id).name(ip_address)
  end

  def self.get(parent_id)
    where(parent_id: parent_id)
  end

  def is_leaf
    true
  end

  def self.get_teams_users(team_id)
    where(parent_id: team_id)
  end
end
