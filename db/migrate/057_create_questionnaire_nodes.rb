class CreateQuestionnaireNodes < ActiveRecord::Migration[4.2]
  def self.up
    questionnaires = Questionnaire.all
    questionnaires.each do |questionnaire|
      parent = QuestionnaireTypeNode.find_by_node_object_id(questionnaire.type_id)
      QuestionnaireNode.create(node_object_id: questionnaire.id, parent_id: parent.id)
    end
  end

  def self.down
    nodes = QuestionnaireNode.all
    nodes.each(&:destroy)
  end
end
