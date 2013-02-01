class CreateTeams < ActiveRecord::Migration
  def self.up
  create_table "teams", :force => true do |t|
    t.column "name", :string
    t.column "assignment_id", :integer, :default => 0, :null => false
  end

  add_index "teams", ["assignment_id"], :name => "fk_teams_assignments"
 
  execute "alter table teams
             add constraint fk_teams_assignments
             foreign key (assignment_id) references assignments(id)"   
  end

  def self.down
    drop_table "teams"
  end
end
