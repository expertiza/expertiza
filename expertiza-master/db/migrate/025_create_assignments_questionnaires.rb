class CreateAssignmentsQuestionnaires < ActiveRecord::Migration
  def self.up
  create_table "assignments_questionnaires", :force => true do |t|
    t.column "questionnaire_id", :integer, :default => 0, :null => false
    t.column "assignment_id", :integer, :default => 0, :null => false
  end

  add_index "assignments_questionnaires", ["questionnaire_id"], :name => "fk_assignments_questionnaires_questionnaires"

  execute "alter table assignments_questionnaires
             add constraint fk_assignments_questionnaires_questionnaires
             foreign key (questionnaire_id) references questionnaires(id)"
  
  add_index "assignments_questionnaires", ["assignment_id"], :name => "fk_assignments_questionnaires_assignments"

  execute "alter table assignments_questionnaires
             add constraint fk_assignments_questionnaires_assignments
             foreign key (assignment_id) references assignments(id)"
  
    
  end

  def self.down
    drop_table "assignments_questionnaires"
  end
end
