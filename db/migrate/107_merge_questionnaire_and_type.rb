class MergeQuestionnaireAndType < ActiveRecord::Migration
  def self.up
    begin
      execute "ALTER TABLE `scores` 
               DROP FOREIGN KEY `fk_score_questionnaire_types`"       
    rescue
    end
  
    begin
       execute "ALTER TABLE `scores` 
                DROP INDEX `fk_score_questionnaire_types`"       
    rescue
    end

    begin
      execute "ALTER TABLE `questionnaires` 
               DROP FOREIGN KEY `fk_questionnaire_type`"       
    rescue
    end
  
    begin
       execute "ALTER TABLE `questionnaires` 
                DROP INDEX `fk_questionnaire_type`"       
    rescue
    end  

    begin
      execute "ALTER TABLE `assignments` 
               DROP FOREIGN KEY `fk_assignments_author_feedback`"       
    rescue
    end
  
    begin
       execute "ALTER TABLE `assignments`
                DROP INDEX `fk_assignments_author_feedback`"       
    rescue
    end  
 
     
    add_column :questionnaires, :type, :string
    add_column :questionnaires, :display_type, :string
    Questionnaire.find(:all).each{
      | questionnaire |
      records = ActiveRecord::Base.connection.select_all("select * from questionnaire_types where id = #{questionnaire.type_id}")
      type = records[0]['name']
      questionnaire.update_attribute('display_type',type)
      type.gsub!(/[^\w]/,'')
      questionnaire.update_attribute('type',type+"Questionnaire")      
    }     
    
    remove_column :scores, :questionnaire_type_id
    
    remove_column :questionnaires, :type_id
    drop_table :questionnaire_types
  end

  def self.down
  end
end
