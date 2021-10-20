class CreateQuestions < ActiveRecord::Migration
  def self.up
  create_table "questions", :force => true do |t|
    t.column "txt", :text # the question content
    t.column "true_false", :boolean # is this a true/false question?
    t.column "weight", :integer # the scoring weight
    t.column "questionnaire_id", :integer # the questionnaire to which this question belongs
  end

  add_index "questions", ["questionnaire_id"], :name => "fk_question_questionnaires"
 
  execute "alter table questions 
             add constraint fk_question_questionnaires
             foreign key (questionnaire_id) references questionnaires(id)"
  end

  def self.down
    drop_table "questions"
  end
end
