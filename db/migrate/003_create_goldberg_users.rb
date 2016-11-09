class CreateGoldbergUsers < ActiveRecord::Migration
  def self.up

  create_table "goldberg_users", :force => true do |t|
    t.column "name", :string, :default => "", :null => false
    t.column "password", :string, :limit => 40, :default => "", :null => false
    t.column "role_id", :integer, :default => 0, :null => false
    t.column "password_salt", :string
    t.column "fullname", :string
    t.column "email", :string
    t.column "start_path", :string
    t.column "self_reg_confirmation_required", :boolean
    t.column "confirmation_key", :string
    t.column "password_changed_at", :datetime
    t.column "password_expired", :boolean
  end

  add_index "goldberg_users", ["role_id"], :name => "fk_user_role_id"

  execute "INSERT INTO `goldberg_users` VALUES (2,'admin','d033e22ae348aeb5660fc2140aec35850c4da997',3,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);"
    
  end

  def self.down
    drop_table "goldberg_users"
  end
end
