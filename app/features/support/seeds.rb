puts "Loading data from features/support/seeds.rb"

require Rails.root.join('db/seeds')

u = User.find_by_name('student') || User.new
u.attributes = {:name => 'student',
             :email => 'student@mailinator.com',
             :password => 'password',
             :password_confirmation => 'password',
             :role_id => Role.find_by_name('Student').id,
             :email_on_review => true,
             :email_on_submission => true,
             :email_on_review_of_review => true,
             :is_new_user => false,
             :master_permission_granted => false,
             :parent_id => User.find_by_name('admin').id}
u.save!
