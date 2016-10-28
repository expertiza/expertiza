class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column "name", :string, :default => "", :null => false
      t.column "password", :string, :limit => 40, :default => "", :null => false
      t.column "role_id", :integer, :default => 0, :null => false
      t.column "password_salt", :string
      t.column "fullname", :string
      t.column "email", :string
      t.column "parent_id", :integer
      t.column "private_by_default", :boolean, :default => false
      t.column "mru_directory_path", :string, :limit => 128
      t.column "email_on_review", :boolean
      t.column "email_on_submission", :boolean
      t.column "email_on_review_of_review", :boolean
      t.column "is_new_user", :boolean, :default => 1
      t.column "master_permission_granted", :boolean


    end

    add_index "users", ["role_id"], :name => "fk_user_role_id"
   
    execute "INSERT INTO `users` VALUES (2,'admin','d033e22ae348aeb5660fc2140aec35850c4da997',4,NULL,'','',2,0,NULL,1,1,1,0,0);"
  end
  
  def self.down
  end
end
