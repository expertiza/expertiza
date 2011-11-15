Given 'I am logged in as a student' do
<<<<<<< HEAD
  # Roles and permissions should be set up as fixtures someday. But for now...
  Given 'all-permissive roles are set up'
  And 'a student with the username "student" exists'
  When 'I go to the login page'
  
  fill_in 'User Name', :with => 'student'
  fill_in 'password', :with => 'password'
=======
  And 'a student with the username "student" exists'
  When 'I go to the login page'
  
  fill_in 'login_name', :with => 'student'
  fill_in 'login_password', :with => 'password'
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
  click_button 'Login'
  
  Then 'I should be logged in as "student"'
end

<<<<<<< HEAD
Given 'all-permissive roles are set up' do
=begin
  perms = Permission.all :select => :id
  names = ["Student", "Instructor", "Administrator", "Super-Administrator", "Unregistered user", "Teaching Assistant"]
  name.each do |name|
    role = Role.create! :name => name
    perms.each do |perm|
      RolesPermission.create! :role_id => role.id, :permission_id => perm.id
    end
  end
=end
end

=======
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
Given /^a student with the username "(\S+)" exists$/ do |username|
  User.create({
    :name => username,
    :fullname => username,
    :clear_password => 'password',
    :clear_password_confirmation => 'password',
    :role => Role.find_by_name!('Student'),
<<<<<<< HEAD
    :email => "#{username}@mailinator.com"
=======
    :email => "#{username}@mailinator.com",
    :is_new_user => false
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
  })
end

Then /I should be logged in as "(\S+)"/ do |username|
<<<<<<< HEAD
  find('.sidebar td').should have_content "User: #{username}"
end
=======
  #find('.sidebar td').should have_content "User: #{username}"
  node = find('.sidebar td').node().content()
  if(node.include? username)
    assert(true)
  else
    assert(false)
  end
end
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
