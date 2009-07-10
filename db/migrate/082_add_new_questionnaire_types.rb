class AddNewQuestionnaireTypes < ActiveRecord::Migration
  def self.up
    type = QuestionnaireType.find_by_name('Review Rubric')
    if type == nil
      type = QuestionnaireType.find_by_name('Rubric')
    end
    if type
      type.name = 'Review'
      type.save
    end      
    execute "INSERT INTO `questionnaire_types` (`id`, `name`) VALUES 
            (6, 'Metareview'),
            (7, 'Teammate Review');"
    execute "INSERT INTO `nodes` (`parent_id`, `node_object_id`, `type`) VALUES
            (1, 6, 'QuestionnaireTypeNode'),
            (1, 7, 'QuestionnaireTypeNode');"
  end
  def self.down
  end
end
