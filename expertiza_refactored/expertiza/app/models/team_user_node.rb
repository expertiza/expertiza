class TeamUserNode < Node
  def self.table
    "teams_participants"
  end  
  
  def get_name
    TeamsParticipant.find(self.node_object_id).name
  end  
  
  def self.get(parent_id)
    query = "select nodes.* from nodes, "+self.table
    query = query+" where nodes.node_object_id = "+self.table+".id"
    query = query+" and nodes.type = '"+self.to_s+"'" 
    if parent_id
      query = query+ " and "+self.table+".team_id = "+parent_id.to_s
    end  
    find_by_sql(query)
  end 
  
  def is_leaf
    true
  end
end
