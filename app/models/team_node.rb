class TeamNode < Node
  def self.table
    "teams"
  end
  
  def self.get(parent_id)
    query = "select nodes.* from nodes, "+self.table
    query = query+" where nodes.node_object_id = "+self.table+".id"
    query = query+" and nodes.type = '"+self.to_s+"'" 
    if parent_id
      query = query+ " and "+self.table+".parent_id = "+parent_id.to_s
    end  
    find_by_sql(query)
  end 
  
  def get_name
    Team.find(self.node_object_id).name    
  end
  
  def get_children(sortvar = nil,sortorder = nil,user_id = nil,parent_id = nil)
    TeamUserNode.get(self.node_object_id)
  end  
end
