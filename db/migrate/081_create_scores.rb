class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.column :instance_id, :integer, :null => false
      t.column :question_id, :integer, :null => false
      t.column :questionnaire_type_id, :integer, :null => false
      t.column :score, :integer, :null => true
      t.column :comments, :text      
    end
    
    add_index "scores", ["question_id"], :name => "fk_score_questions"

    execute "alter table scores 
               add constraint fk_score_questions
               foreign key (question_id) references questions(id)"
               
    add_index "scores", ["questionnaire_type_id"], :name => "fk_score_questionnaire_types"
    
    execute " ALTER TABLE `questionnaire_types`  ENGINE = innodb"
    
    execute "alter table scores 
               add constraint fk_score_questionnaire_types
               foreign key (questionnaire_type_id) references questionnaire_types(id)"               
  end
  def self.down
    execute 'ALTER TABLE scores DROP FOREIGN KEY fk_score_questions'
    execute 'ALTER TABLE scores DROP FOREIGN KEY `fk_score_questionnaire_types'
    execute 'DROP TABLE scores'
  end
end
