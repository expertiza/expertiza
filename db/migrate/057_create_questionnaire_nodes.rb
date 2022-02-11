class CreateQuestionnaireNodes < ActiveRecord::Migration[4.2][4.2]
  def self.up
    questionnaires = Questionnaire.all
    questionnaires.each {
      |questionnaire|
      parent = QuestionnaireTypeNode.find_by_node_object_id(questionnaire.type_id)
      QuestionnaireNode.create(:node_object_id => questionnaire.id, :parent_id => parent.id)         
    }
  end

  def self.down
    nodes = QuestionnaireNode.all
    nodes.each { |node| node.destroy }    
  end
end
