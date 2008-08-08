class QuestionnaireTypeNode < Node  
  def self.table
    "questionnaire_types"
  end
  
  def self.get(sortvar = nil,sortorder = nil,user_id = nil,parent_id = nil)    
    query = "select nodes.* from nodes, "+self.table
    query = query+" where nodes.node_object_id = "+self.table+".id"
    query = query+" and nodes.type = '"+self.to_s+"'"            
    query = query+" order by "+self.table+".name asc"
    find_by_sql(query)
  end
  
  def get_name
    QuestionnaireType.find(self.node_object_id).name    
  end  
  
  def get_children(sortvar = nil,sortorder = nil,user_id = nil,parent_id = nil)
    QuestionnaireNode.get(sortvar,sortorder,user_id,self.node_object_id)
  end
end
