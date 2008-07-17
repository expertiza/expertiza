class Node < ActiveRecord::Base
  acts_as_nested_set

  def self.get(sortvar = nil,sortorder =nil,user_id = nil,parent_id = nil)       
  end
  
  def get_children(sortvar = nil,sortorder =nil,user_id = nil,parent_id = nil)    
  end
  
  def get_partial_name
     self.class.table+"_actions"      
  end
  
  def is_leaf
    false
  end
  
  def self.table 
  end
  
  def get_name
  end
  
  def get_directory
  end  
  
  def get_creation_date
  end
  
  def get_child_type   
  end
end
