class AssignmentNode < Node   
  def self.table
    "assignments"
  end
  
  def self.get(sortvar = nil,sortorder =nil,user_id = nil,parent_id = nil)    
    query = "select nodes.* from nodes, "+self.table
    query = query+" where nodes.node_object_id = "+self.table+".id"
    query = query+" and nodes.type = '"+self.to_s+"'"
    if user_id
      query = query+" and "+self.table+".instructor_id = "+user_id.to_s
    end     
    if parent_id
      query = query+ " and course_id = "+parent_id.to_s
    end    
    if sortvar            
      query = query+" order by "+self.table+"."+sortvar
      if sortorder
        query = query+" "+sortorder
      end
    end              
    find_by_sql(query)
  end
  
  def is_leaf
    true
  end
  
  def get_name
    Assignment.find(self.node_object_id).name    
  end
  
  def get_directory
    Assignment.find(self.node_object_id).directory_path    
  end  
  
  def get_creation_date
    Assignment.find(self.node_object_id).created_at
  end      
end
