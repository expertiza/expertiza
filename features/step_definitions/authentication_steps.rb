Given 'I am logged in as a student' do
  And 'a student with the username "student" exists'
  When 'I go to the login page'
  
  fill_in 'login_name', :with => 'student'
  fill_in 'login_password', :with => 'password'
  click_button 'Login'
  
  Then 'I should be logged in as "student"'
end

Given /^a student with the username "(\S+)" exists$/ do |username|
  User.create({
    :name => username,
    :fullname => username,
    :clear_password => 'password',
    :clear_password_confirmation => 'password',
    :role => Role.find_by_name!('Student'),
    :email => "#{username}@mailinator.com",
    :is_new_user => false
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
