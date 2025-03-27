class CreateQuestionadvice < ActiveRecord::Migration[4.2]
  def self.up
    create_table :question_advice do |t|
      t.column :question_id, :integer
      t.column :score, :integer # either an integer or true/false.  false should be assigned a score of 0, and true should be assigned a score of 1
      t.column :advice, :text # the meaning of giving this score for this question
    end

    execute "alter table question_advice
             add constraint fk_question_question_advice
             foreign key (question_id) references questions(id)"
  end

  def self.down
    drop_table :question_advice
  end
end
