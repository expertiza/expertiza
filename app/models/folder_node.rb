class FolderNode < Node  
  def self.table
    "tree_folders"
  end
  
  def self.get(sortvar = nil,sortorder =nil,user_id = nil,parent_id = nil)
    query = "select nodes.* from nodes, "+self.table
    query = query+" where nodes.node_object_id = "+self.table+".id"
    query = query+" and nodes.type = '"+self.to_s+"'"                       
    find_by_sql(query)   
  end
  
  def get_name
    TreeFolder.find(self.node_object_id).name    
  end
  
  def get_partial_name
    self.get_name.downcase+"_folder_actions"   
  end    
  
  def get_child_type 
    TreeFolder.find(self.node_object_id).child_type
  end
  
  def get_children(sortvar = nil,sortorder =nil,user_id = nil,parent_id = nil)      
    Object.const_get(self.get_child_type).get(sortvar,sortorder,user_id,parent_id)
  end
end
