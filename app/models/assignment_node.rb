#Node type for Assignments

#Author: ajbudlon
#Date: 7/18/2008

class AssignmentNode < Node   
  belongs_to :assignment, :class_name => "Assignment", :foreign_key => "node_object_id"
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
  def self.get(sortvar = nil,sortorder =nil,user_id = nil,show = nil,parent_id = nil)    
    if show   
      if User.find(user_id).role.name != "Teaching Assistant"
        conditions = 'assignments.instructor_id = ?'
      else
        conditions = 'assignments.course_id in (?)'
      end
    else
      if User.find(user_id).role.name != "Teaching Assistant"
        conditions = '(assignments.private = 0 or assignments.instructor_id = ?)'
      else
        conditions = '(assignments.private = 0 or assignments.course_id in (?))'
      end   
    end
    
    if User.find(user_id).role.name != "Teaching Assistant"
      values = user_id
    else
      values = Ta.get_mapped_courses(user_id)
    end
          
    if parent_id
      conditions += " and course_id = #{parent_id}"
    end
    
    if sortvar.nil?
      sortvar = 'name'
    end
    if sortorder.nil?
      sortorder = 'ASC'
    end         
        
    find(:all, :include => :assignment, :conditions => [conditions,values], :order => "assignments.#{sortvar} #{sortorder}")    
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
