class AddNewQuestionnaireTypes < ActiveRecord::Migration
  def self.up
    execute "UPDATE `questionnaire_types` set name = 'Review' where name in ('Review Rubric', 'Rubric')" 
          
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
