#Node type for Courses

#Author: ajbudlon
#Date: 7/18/2008

class CourseNode < Node 
  
  # Returns the table in which to locate Courses
  def self.table
    "courses"
  end

  # parameters:
  #   sortvar: valid strings - name, created_at, updated_at, directory_path
  #   sortorder: valid strings - asc, desc
  #   user_id: instructor id for Course
  #   parent_id: not used for this type of object
  
  # returns: list of CourseNodes based on query
  def self.get(sortvar = nil,sortorder =nil,user_id = nil,parent_id = nil)    
    query = "select nodes.* from nodes, "+self.table
    query = query+" where nodes.node_object_id = "+self.table+".id"
    query = query+" and nodes.type = '"+self.to_s+"'"
    if user_id
      query = query+" and "+self.table+".instructor_id = "+user_id.to_s
    else
      query = query+" and "+self.table+".private = 0"
    end    
    if sortvar            
      query = query+" order by "+self.table+"."+sortvar
      if sortorder
        query = query+" "+sortorder
      end
    end       
    find_by_sql(query)
  end  
  
  # Gets any children associated with this object
  def get_children(sortvar = nil,sortorder =nil,user_id = nil,parent_id = nil)
    AssignmentNode.get(sortvar,sortorder,user_id,self.node_object_id)
  end
  
  # Gets the name from the associated object  
  def get_name
    Course.find(self.node_object_id).name    
  end    
  
  # Gets the directory_path from the associated object  
  def get_directory
    Course.find(self.node_object_id).directory_path
  end    
  
  # Gets the created_at from the associated object   
  def get_creation_date
    Course.find(self.node_object_id).created_at
  end 
  
  # Gets the updated_at from the associated object   
  def get_modified_date
    Course.find(self.node_object_id).updated_at
  end 
  
  # Gets any TeamNodes associated with this object   
  def get_teams
    TeamNode.get(self.node_object_id)
  end   
end
