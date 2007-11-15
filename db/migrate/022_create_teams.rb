class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.column :name, :string #name of the team, unique per assignment
      t.column :assignemnt_id, :integer #fk to assignment
    end
    
    execute "alter table teams 
             add constraint fk_team_assignment
             foreign key (assignment_id) references assignments(id)"
    
  end

  def self.down
    drop_table :teams
  end
end
