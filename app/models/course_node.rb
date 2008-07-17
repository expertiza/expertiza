class CourseNode < Node 
  def self.table
    "courses"
  end

  def self.get(sortvar = nil,sortorder =nil,user_id = nil,parent_id = nil)    
    query = "select nodes.* from nodes, "+self.table
    query = query+" where nodes.node_object_id = "+self.table+".id"
    query = query+" and nodes.type = '"+self.to_s+"'"
    if user_id
      query = query+" and "+self.table+".instructor_id = "+user_id.to_s
    end    
    if sortvar            
      query = query+" order by "+self.table+"."+sortvar
      if sortorder
        query = query+" "+sortorder
      end
    end       
    find_by_sql(query)
  end  
  
  def get_children(sortvar = nil,sortorder =nil,user_id = nil,parent_id = nil)
    AssignmentNode.get(sortvar,sortorder,user_id,self.node_object_id)
  end
  
  def get_name
    Course.find(self.node_object_id).name    
  end    
  
  def get_directory
    Course.find(self.node_object_id).directory_path
  end    
  
  def get_creation_date
    Course.find(self.node_object_id).created_at
  end 
end
