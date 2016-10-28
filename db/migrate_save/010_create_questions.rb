class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.column :txt, :text
      t.column :true_false, :boolean  # either it's a true/false question, or it's a question that is to be given a numeric score
      t.column :weight, :integer
      t.column :questionnaire_id, :integer
    end
    execute "alter table questions
             add constraint fk_question_questionnaires
             foreign key (questionnaire_id) references questionnaires(id)"
  end

  def self.down
    drop_table :questions
  end
end
