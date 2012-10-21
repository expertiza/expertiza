#Node type for Courses

#Author: ajbudlon
#Date: 7/18/2008

class CourseNode < Node 
  belongs_to :course, :class_name => "Course", :foreign_key => "node_object_id"
  
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
  def self.get(sortvar = nil,sortorder =nil,user_id = nil,show = nil, parent_id = nil) 
    if show      
      conditions = 'courses.instructor_id in (?)'      
    else
      conditions = '(courses.private = 0 or courses.instructor_id in (?))'     
    end   

    if show   
      if User.find(user_id).role.name != "Teaching Assistant"
        conditions = 'courses.instructor_id = ?'
      else
        conditions = 'courses.id in (?)'
      end
    else
      if User.find(user_id).role.name != "Teaching Assistant"
        conditions = '(courses.private = 0 or courses.instructor_id = ?)'
      else
        conditions = '(courses.private = 0 or courses.id in (?))'
      end   
    end    
    
    
    if sortvar.nil?
      sortvar = 'name'
    end
    if sortorder.nil?
      sortorder = 'ASC'
    end         
    
    
    if User.find(user_id).role.name != "Teaching Assistant"
      values = user_id
    else
      values = Ta.get_mapped_courses(user_id)
    end
    
    find(:all, :include => :course, :conditions => [conditions,values], :order => "courses.#{sortvar} #{sortorder}")       
  end  
  
  # Gets any children associated with this object
  def get_children(sortvar = nil,sortorder =nil,user_id = nil,show = nil, parent_id = nil)
    AssignmentNode.get(sortvar,sortorder,user_id,show,self.node_object_id)
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
  def get_survey_distribution_id
    Course.find(self.node_object_id).survey_distribution_id
  end
  def get_creation_date
    Course.find(self.node_object_id).created_at
  end   
end
