class CreateQuestionadvice < ActiveRecord::Migration[4.2]
  def self.up
    create_table 'question_advice', force: true do |t|
      t.column 'question_id', :integer # the question to which this advice belongs
      t.column 'score', :integer # the score associated with this advice
      t.column 'advice', :text # the advice to be given to the user
    end

    add_index 'question_advice', ['question_id'], name: 'fk_question_question_advice'

    execute "alter table question_advice
               add constraint fk_question_question_advice
               foreign key (question_id) references questions(id)"
  end

  def self.down
    drop_table 'question_advice'
  end
end
