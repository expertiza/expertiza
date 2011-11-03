Given 'I am logged in as a student' do
  # Roles and permissions should be set up as fixtures someday. But for now...
  Given 'all-permissive roles are set up'
  And 'a student with the username "student" exists'
  When 'I go to the login page'
  
  #fill_in 'User Name', :with => 'student'
  #fill_in 'password', :with => 'password'
  fill_in 'login_name', :with => 'student'
  fill_in 'login_password', :with => 'password'
  click_button 'Login'
  
  Then 'I should be logged in as "student"'
end

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

Given /^a student with the username "(\S+)" exists$/ do |username|
  User.create({
    :name => username,
    :fullname => username,
    :clear_password => 'password',
    :clear_password_confirmation => 'password',
    :role => Role.find_by_name!('Student'),
    :email => "#{username}@mailinator.com"
  })
end

Then /I should be logged in as "(\S+)"/ do |username|
  #find('.sidebar td').should have_content "User: #{username}"
  node = find('.sidebar td').node().content()
  if(node.include? username)
    assert(true)
  else
    assert(false)
  end
end