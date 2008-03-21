class CreateQuestions < ActiveRecord::Migration
  def self.up
  create_table "questions", :force => true do |t|
    t.column "txt", :text
    t.column "true_false", :boolean
    t.column "weight", :integer
    t.column "questionnaire_id", :integer
  end

  add_index "questions", ["questionnaire_id"], :name => "fk_question_questionnaires"
 
  execute "alter table questions 
             add constraint fk_question_questionnaires
             foreign key (questionnaire_id) references questionnaires(id)"
   
  execute "INSERT INTO `questions` VALUES (1,'This is a question',1,1,1);"
  end

  def self.down
  end
end
