class CreateTeamRolesets < ActiveRecord::Migration
  def self.up
    create_table "team_rolesets", :force => true do |t|
      #t.integer "id"
      t.string "roleset_name"
    end
  end

  def self.down
    drop_table :team_rolesets
  end
end
