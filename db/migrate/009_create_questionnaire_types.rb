class CreateQuestionnaireTypes < ActiveRecord::Migration
  def self.up
  create_table "questionnaire_types", :force => true do |t|
    t.column "name", :string, :default => "", :null => false
  end
 
  execute "INSERT INTO `questionnaire_types` VALUES (1,'Rubric');"
  execute "INSERT INTO `questionnaire_types` VALUES (2,'Survey');"
  execute "INSERT INTO `questionnaire_types` VALUES (3,'Global Survey');"
  execute "INSERT INTO `questionnaire_types` VALUES (4,'Course Evaluation');" 
  end

  def self.down
    drop_table "questionnaire_types"
  end
end
