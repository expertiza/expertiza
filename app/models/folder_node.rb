class FolderNode < Node  
  belongs_to :folder, :class_name => "TreeFolder", :foreign_key => "node_object_id"
  
  def self.get(sortvar = nil,sortorder =nil,user_id = nil,show = nil,parent_id = nil)
    find(:all, :include => :folder, :conditions => ['type = ? and tree_folders.parent_id is NULL',self.to_s])    
  end
  
  def get_name
    TreeFolder.find(self.node_object_id).name    
  end
  
  def get_partial_name
    if self.parent_id.nil?
      return self.get_name.downcase+"_folder_actions"
    else
      return "questionnaire_types_actions"
    end
  end    
  
  def get_child_type 
    TreeFolder.find(self.node_object_id).child_type
  end
  
  def get_children(sortvar = nil,sortorder =nil,user_id = nil,show = nil, parent_id = nil)  
    if self.folder.parent_id != nil
      parent_id = self.folder.id
    end
    Object.const_get(self.get_child_type).get(sortvar,sortorder,user_id,show,parent_id)
  end
end
