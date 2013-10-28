Given 'I am logged in as a student' do
  step 'a student with the username "student" exists'
  step 'I go to the login page'
  
  fill_in 'User Name', :with => 'student'
  fill_in 'Password', :with => 'password'
  click_button 'Login'
  
  step 'I should be logged in as "student"'
end

Given /^a student with the username "(\S+)" exists$/ do |username|
  user = User.find_by_name(username)

  if(user.nil?)
    User.create({
                    :name => username,
                    :fullname => username,
                    :password => 'password',
                    :password_confirmation => 'password',
                    :role => Role.find_by_name!('student'),
                    :email => "#{username}@mailinator.com",
                    :is_new_user => false
                })
  end
end

Then /I should be logged in as "(\S+)"/ do |username|
  find('.sidebar td', :text => username)
    .has_text?(username)
    .should be_true
end

Given /I am logged in as "([^"]*)"/ do |username|
  step "I go to the login page"
  
  fill_in 'login_name', :with => username
  fill_in 'login_password', :with => 'password'
  click_button 'Login'
  
  step "I should be logged in as \"#{username}\""
end

Given 'I am logged in as admin' do
  step 'I go to the login page'

  fill_in 'login_name', :with => 'admin'
  fill_in 'login_password', :with => 'admin'
  click_button 'Login'

  step 'I should be logged in as "admin"'
end

# Create any type of user provided a Full Name and Username
Given /an? (Student|Teaching Assistant|Instructor|Administrator|Super-Administrator) named "([^"]*)"( created by "([^"]+)")?/i do |user_type,name,garbage,parent|
   # Set the parent_id for the new user.
   parent_id = (parent) ? User.find_by_name(parent).id : User.find_by_name('admin').id
    
  User.create({
    :name => name,
    :fullname => name,
    :password => 'password',
    :password_confirmation => 'password',
    :role => Role.find_by_name!(user_type),
    :email => "#{name}@mailinator.com",
    :parent_id => parent_id,
    :is_new_user => false
  })
end

Given /^these Users:$/ do |table|
# table is a Cucumber::Ast::Table
    @users = table.hashes
    @users.each do |user|
        step "a #{user[:type]} named #{user[:name]} created by #{user[:parent]}"
    end
end

When /I log in as "([^"]*)"/ do |username|
  step "I go to the login page"

  fill_in 'login_name', :with => username
  fill_in 'login_password', :with => 'password'
  click_button 'Login'

  step "I should be logged in as \"#{username}\""
end

Given 'I am not logged in' do
  first('#logout-button').try(:click)
end

When /^I log in as a "([^\"]*)" with password "([^\"]*)"$/ do |username, password|
  fill_in 'login_name', :with => username
  fill_in 'login_password', :with => password
  click_button 'Login'
end
