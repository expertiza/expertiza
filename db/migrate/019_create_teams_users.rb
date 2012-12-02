class CreateTeamsUsers < ActiveRecord::Migration
  def self.up
  create_table "teams_users", :force => true do |t|
    t.column "team_id", :integer
    t.column "user_id", :integer
  end

  add_index "teams_users", ["team_id"], :name => "fk_users_teams"

  execute "alter table teams_users
             add constraint fk_users_teams
             foreign key (team_id) references teams(id)"   

  add_index "teams_users", ["user_id"], :name => "fk_teams_users"

  execute "alter table teams_users
             add constraint fk_teams_users
             foreign key (user_id) references users(id)"   
  
  end

  def self.down
    drop_table "teams_users"
  end
end
