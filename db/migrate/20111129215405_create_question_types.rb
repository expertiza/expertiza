class CreateQuestionTypes < ActiveRecord::Migration
  def self.up
    create_table "question_types", :force => true do |t|
      t.column "q_type", :string, :null => false # the type of custom question
      t.column "parameters", :string # parameters for a given question
      t.column "question_id", :integer, :default => 1, :null => false # Questionnaire Type join
    end


    add_index "question_types", ["question_id"], :name => "fk_question_type_question"

    execute "alter table question_types
             add constraint fk_question_type_question
             foreign key (question_id) references questions(id)"
  end

  def self.down
    drop_table :question_types
  end
end
