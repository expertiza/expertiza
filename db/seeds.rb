# User.create(name: 'dli35',
#     crypted_password: 'password',
#     role_id: 2,
#     password_salt: 1,
#     fullname: '6, dli35',
#     email: 'dli35@ncsu.edu',
#     parent_id: 1,
#     private_by_default: false,
#     mru_directory_path: nil,
#     email_on_review: true,
#     email_on_submission: true,
#     email_on_review_of_review: true,
#     is_new_user: false,
#     master_permission_granted: 0,
#     handle: 'handle',
#     digital_certificate: nil,
#     timezonepref: 'Eastern Time (US & Canada)',
#     public_key: nil,
#     copy_of_emails: nil,
#     institution_id: 1)
# t.column "name", :string,       t.column "name", :string, :default => "", :null => false
# t.column "password", :string, :limit => 40, :default => "", :null => false
# t.column "role_id", :integer, :default => 0, :null => false
# t.column "password_salt", :string
# t.column "fullname", :string
# t.column "email", :string
# t.column "parent_id", :integer
# t.column "private_by_default", :boolean, :default => false
# t.column "mru_directory_path", :string, :limit => 128
# t.column "email_on_review", :boolean
# t.column "email_on_submission", :boolean
# t.column "email_on_review_of_review", :boolean
# t.column "is_new_user", :boolean, :default => 1
# t.column "master_permission_granted", :boolean