class CreateQuestionAdvices < ActiveRecord::Migration
  def self.up
  create_table "question_advices", :force => true do |t|
    t.column "question_id", :integer # the question to which this advice belongs
    t.column "score", :integer # the score associated with this advice 
    t.column "advice", :text # the advice to be given to the user
  end

  add_index "question_advices", ["question_id"], :name => "fk_question_question_advices"
  
  execute "alter table question_advices 
             add constraint fk_question_question_advices
             foreign key (question_id) references questions(id)"
  
  end

  def self.down
    drop_table "question_advices"
  end
end
