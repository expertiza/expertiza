class CreateSurveyResponses < ActiveRecord::Migration
  def self.up
  create_table "survey_responses", :force => true do |t|
    t.column "score", :integer, :limit => 10
    t.column "comments", :text
    t.column "assignment_id", :integer, :limit => 10, :default => 0, :null => false
    t.column "question_id", :integer, :limit => 10, :default => 0, :null => false
    t.column "survey_id", :integer, :limit => 10, :default => 0, :null => false
    t.column "email", :string
  end
  
  add_index "survey_responses", ["assignment_id"], :name => "fk_survey_assignments"

  execute "alter table survey_responses
             add constraint fk_survey_assignments
             foreign key (assignment_id) references assignments(id)"
  
  add_index "survey_responses", ["question_id"], :name => "fk_survey_questions"

  execute "alter table survey_responses 
             add constraint fk_survey_questions
             foreign key (question_id) references questions(id)"
  
  add_index "survey_responses", ["survey_id"], :name => "fk_survey_questionnaires"

  execute "alter table survey_responses 
             add constraint fk_survey_questionnaires
             foreign key (survey_id) references questionnaires(id)" 
  
  end

  def self.down
    drop_table "survey_responses"
  end
end
