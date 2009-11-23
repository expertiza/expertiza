class MergeQuestionnaireAndType < ActiveRecord::Migration
  def self.up
    add_column :questionnaires, :type, :string
    add_column :questionnaires, :display_type, :string
    Questionnaire.find(:all).each{
      | questionnaire |
      type = QuestionnaireType.find(questionnaire.type_id).name
      questionnaire.update_attribute('display_type',type)
      type.gsub!(/[^\w]/,'')
      questionnaire.update_attribute('type',type+"Questionnaire")
      
    }
    
    execute "ALTER TABLE `scores` 
             DROP FOREIGN KEY `fk_score_questionnaire_types`" 
    execute "ALTER TABLE `scores` 
             DROP INDEX `fk_score_questionnaire_types`"      
    
    remove_column :scores, :questionnaire_type_id
    
    remove_column :questionnaires, :type_id
    drop_table :questionnaire_types
  end

  def self.down
  end
end
