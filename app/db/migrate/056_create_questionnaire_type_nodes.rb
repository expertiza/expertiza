class CreateQuestionnaireTypeNodes < ActiveRecord::Migration  
  def self.up      
    #Retrieve all questionnaire types
    types = ActiveRecord::Base.connection.select_all("select * from questionnaire_types")          
    folder = TreeFolder.find_by_name('Questionnaires')
    parent = FolderNode.find_by_node_object_id(folder.id)
    types.each{
      |type|
      QuestionnaireTypeNode.create(:node_object_id => type["id"], :parent_id => parent.id)
    }        
  end

  def self.down  
    nodes = QuestionnaireTypeNode.find(:all)
    nodes.each {|node| node.destroy }    
  end
end
