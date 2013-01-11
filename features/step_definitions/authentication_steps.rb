Given 'I am logged in as a student' do
  And 'a student with the username "student" exists'
  When 'I go to the login page'
  
  fill_in 'login_name', :with => 'student'
  fill_in 'login_password', :with => 'password'
  click_button 'Login'
  
  Then 'I should be logged in as "student"'
end

Given /^a student with the username "(\S+)" exists$/ do |username|
  user = User.find_by_name(username)

  if(user.nil?)
    User.create({
                    :name => username,
                    :fullname => username,
                    :clear_password => 'password',
                    :clear_password_confirmation => 'password',
                    :role => Role.find_by_name!('student'),
                    :email => "#{username}@mailinator.com",
                    :is_new_user => false
                })
  end
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

Given /I am logged in as "([^"]*)"/ do |username|
  When "I go to the login page"
  
  fill_in 'login_name', :with => username
  fill_in 'login_password', :with => 'password'
  click_button 'Login'
  
  Then "I should be logged in as \"#{username}\""
end


# Create any type of user provided a Full Name and Username
Given /an? (super-administrator|admin|instructor|teaching assistant|student) named "([^"]*)"( created by "([^"]+)")?/i do |user_type,name,garbage,parent|
  user_type = user_type.downcase
  # Set the parent_id for the new user.
  parent_id = (parent) ? User.find_by_name(parent).id : User.find_by_name('admin').id
    
  User.create({
    :name => name,
    :fullname => name,
    :clear_password => 'password',
    :clear_password_confirmation => 'password',
    :role => Role.find_by_name!(user_type),
    :email => "#{name}@mailinator.com",
    :parent_id => parent_id,
    :is_new_user => false
  })
end

When /I log in as "([^"]*)"/ do |username|
  When "I go to the login page"

  fill_in 'login_name', :with => username
  fill_in 'login_password', :with => 'password'
  click_button 'Login'

  Then "I should be logged in as \"#{username}\""
end

Given 'I am not logged in' do
  if(find_button('Logout').nil?)
    puts "not Logged in"
  else
    click_link('Logout')
  end
end

When /^I log in as a "([^\"]*)" with password "([^\"]*)"$/ do |username, password|
  fill_in 'login_name', :with => username
  fill_in 'login_password', :with => password
  click_button 'Login'
end