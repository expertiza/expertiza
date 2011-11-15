class CreateQuestionnaireNodes < ActiveRecord::Migration
  def self.up
    questionnaires = Questionnaire.find(:all)
    questionnaires.each {
      |questionnaire|
      parent = QuestionnaireTypeNode.find_by_node_object_id(questionnaire.type_id)
      QuestionnaireNode.create(:node_object_id => questionnaire.id, :parent_id => parent.id)         
    }
  end

  def self.down
    nodes = QuestionnaireNode.find(:all)
    nodes.each { |node| node.destroy }    
  end
end
