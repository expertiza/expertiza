class CreateQuestionAdvices < ActiveRecord::Migration
  def self.up
  create_table "question_advices", :force => true do |t|
    t.column "question_id", :integer
    t.column "score", :integer
    t.column "advice", :text
  end

  add_index "question_advices", ["question_id"], :name => "fk_question_question_advices"
  
  execute "alter table question_advices 
             add constraint fk_question_question_advices
             foreign key (question_id) references questions(id)"
  
  end

  def self.down
  end
end
