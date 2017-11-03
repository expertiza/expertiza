class CreateUsers < ActiveRecord::Migration
  def self.up
    # t.column :username, :string, :limit=>32  --  called "name" in Goldberg
    # t.column :password, :string -- already included in Goldberg table
    # t.column :first_name, :string, :limit=>30  -- subsumed by "fullname" in Goldberg data model (we may want to add this in future
    # t.column :last_name, :string, :limit=>30   -- subsumed by "fullname" in Goldberg data model   "  "
    # t.column :role_id, :integer -- already included in Goldberg table
    add_column :parent_id, :integer # for an instructor, the id in this table of the administrator who created the acct for the instructor; otherwise, empty
    add_column :home_directory_path, :string # for an instructor, the home directory above which (s)he is not allowed access; otherwise empty
    add_column :mru_directory_path, :string, :limit => 128 # for an instructor, the directory that (s)he was working in the previous time he used the system; this is the pathname relative to the home_directory_path; empty for a non-instructor
    # t.column :email_address, :string, :limit=>80  -- called "email" in Goldberg
    add_column :email_on_review, :boolean
    add_column :email_on_submission, :boolean
    add_column :email_on_review_of_review, :boolean

    user = User.create(:username => "testuser1", :password=> User.hash_password("1wolfpack"), :role_id => "3")
    user.save
    user = User.create(:username => "testuser2", :password=> User.hash_password("2wolfpack"),:role_id => "3")
    user.save
    user = User.create(:username => "abcuser1",  :password=> User.hash_password("1wolfpack"),:role_id => "3")
    user.save
    user = User.create(:username => "abcuser2", :password=> User.hash_password("2wolfpack"),:role_id => "3")
    user.save
  end

  def self.down
    drop_table :users
  end
end
