puts "Loading data from features/support/seeds.rb"

User.create!(:name => 'student',
             :email => 'student@mailinator.com',
             :clear_password => 'password',
             :clear_password_confirmation => 'password',
             :role_id => Role.find_by_name('Student').id,
             :email_on_review => true,
             :email_on_submission => true,
             :email_on_review_of_review => true,
             :is_new_user => false,
             :master_permission_granted => false,
             :parent_id => User.find_by_name('admin').id)