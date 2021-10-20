class ModifyUsers < ActiveRecord::Migration
  def self.up
    # t.column :username, :string, :limit=>32  --  called "name" in Goldberg
    # t.column :password, :string -- already included in Goldberg table
    add_column :institution_id, :integer # reference to an entry in institutions table, referring to the institution at which this user is registered ... this tells format of record to be uploaded & prevents usernames from diff. insts. from clashing
    # t.column :first_name, :string, :limit=>30  -- subsumed by "fullname" in Goldberg data model (we may want to add this in future
    # t.column :last_name, :string, :limit=>30   -- subsumed by "fullname" in Goldberg data model   "  "
    # t.column :role_id, :integer -- already included in Goldberg table
    add_column :users, :parent_id, :integer # for an instructor, the id in this table of the administrator who created the acct for the instructor; otherwise, empty
    add_column :users, :private_by_default, :boolean # whether assgts. & questionnaires created by this instructor should be private (i.e., not viewable by others).  Can be overridden when creating a new one.
    # We used to have a home_directory_path column, but now we are just using the user name in place of the home_directory_path
    # add_column :users, :home_directory_path, :string # for an instructor, the home directory above which (s)he is not allowed access; otherwise empty
    add_column :users, :mru_directory_path, :string, :limit => 128 # for an instructor, the directory that (s)he was working in the previous time he used the system; this is the pathname relative to the home_directory_path; empty for a non-instructor
    # t.column :email_address, :string, :limit=>80  -- called "email" in Goldberg
    add_column :users, :email_on_review, :boolean
    add_column :users, :email_on_submission, :boolean
    add_column :users, :email_on_review_of_review, :boolean

    execute "alter table users 
             add constraint fk_institutions_users
             foreign key (institution_id) references institutions(id)"

    user = User.create(:username => "suadmin", :password=> User.hash_password("2wolfpack"),:role_id => "3",:parent_id => 1)#This should be the first user created in the system
    user.save
  end

  def self.down
    remove_column :users, :parent_id
    remove_column :users, :home_directory_path
    remove_column :users, :mru_directory_path
    remove_column :users, :email_on_review
    remove_column :users, :email_on_submission
    remove_column :users, :email_on_review_of_review
  end
end
