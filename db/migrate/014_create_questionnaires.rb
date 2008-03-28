class CreateQuestionnaires < ActiveRecord::Migration
  def self.up
  create_table "questionnaires", :force => true do |t|
    t.column "name", :string, :limit => 64
    t.column "instructor_id", :integer, :default => 0, :null => false
    t.column "private", :boolean, :default => false, :null => false
    t.column "min_question_score", :integer, :default => 0, :null => false
    t.column "max_question_score", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime, :null => false
    t.column "default_num_choices", :integer
    t.column "type_id", :integer, :default => 1, :null => false
  end

  add_index "questionnaires", ["type_id"], :name => "fk_questionnaire_type"
  
  execute "alter table questionnaires 
             add constraint fk_questionnaire_type
             foreign key (type_id) references questionnaire_types(id)"
  
  end

  def self.down
    drop_table "questionnaires"
  end
end
