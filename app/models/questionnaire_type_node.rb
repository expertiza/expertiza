class QuestionnaireTypeNode < FolderNode  
  belongs_to :table, :class_name => "TreeFolder", :foreign_key => "node_object_id"
  
  def self.table
    "tree_folders"
  end
  
  def self.get(sortvar = nil,sortorder =nil,user_id = nil,show = nil,parent_id = nil)
    parent = TreeFolder.find_by_name("Questionnaires")
    folders = TreeFolder.find_all_by_parent_id(parent.id)
    nodes = Array.new
    folders.each{
      | folder |
      node = FolderNode.find_by_node_object_id(folder.id)
      if node != nil
        nodes << node
      end
    }
    return nodes  
  end  
  
  def get_partial_name
    "questionnaire_type_actions"   
  end      
    
  def get_name
    TreeFolder.find(self.node_object_id).name    
  end  
  
  def get_children(sortvar = nil,sortorder = nil,user_id = nil,show=nil,parent_id = nil)
    QuestionnaireNode.get(sortvar,sortorder,user_id,show,self.node_object_id)
  end
end
