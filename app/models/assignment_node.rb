#Node type for Assignments

#Author: ajbudlon
#Date: 7/18/2008

class AssignmentNode < Node   
  
  # Returns the table in which to locate Assignments
  def self.table
    "assignments"
  end
  
  # parameters:
  #   sortvar: valid strings - name, created_at, updated_at, directory_path
  #   sortorder: valid strings - asc, desc
  #   user_id: instructor id for assignment
  #   parent_id: course_id if subset
  
  # returns: list of AssignmentNodes based on query
  def self.get(sortvar = nil,sortorder =nil,user_id = nil,parent_id = nil)    
    query = "select nodes.* from nodes, "+self.table
    query = query+" where nodes.node_object_id = "+self.table+".id"
    query = query+" and nodes.type = '"+self.to_s+"'"
    if user_id && User.find(user_id).role_id != 6 # if not teaching assistant
      query = query+" and "+self.table+".instructor_id = "+user_id.to_s
    elsif user_id #for teaching assistant
      query = query+ " and "+self.table+".id in (select assignments.id from assignments, "+
      "ta_mappings where assignments.course_id = ta_mappings.course_id and ta_mappings.ta_id="+user_id.to_s+")"    
    else
      query = query+" and "+self.table+".private = 0"
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
  
  # Indicates that this object is always a leaf
  def is_leaf
    true
  end
  
  # Gets the name from the associated object
  def get_name
    Assignment.find(self.node_object_id).name    
  end
  
  # Gets the directory_path from the associated object  
  def get_directory
    Assignment.find(self.node_object_id).directory_path    
  end  
  
  # Gets the created_at from the associated object   
  def get_creation_date
    Assignment.find(self.node_object_id).created_at
  end  
  
  # Gets the updated_at from the associated object   
  def get_modified_date
    Assignment.find(self.node_object_id).updated_at
  end   
  
  # Gets any TeamNodes associated with this object   
  def get_teams
    TeamNode.get(self.node_object_id)
  end  
end
