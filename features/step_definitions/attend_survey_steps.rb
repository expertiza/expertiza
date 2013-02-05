And /^I move to the "([^"]*)" page$/ do |assignment|
  should have_link assignment
  click_link assignment
end

And /^I click the "([^"]*)" link$/ do |task|
  if(!find_link('Accept').nil?)
    click_link 'Accept'
  end

  should have_link task
  click_link task
end

And /^I click the "([^"]*)" link to the survey page$/ do |survey|
  should have_link survey
  click_link survey
end

And /^I fill in my email address$/ do
  should have_button "Continue"
  fill_in 'email', :with => 'test@gamil.com'
end

And /^I fill in my name$/ do
   fill_in 'login_name', :with => 'mmythri'
end

And /^I fill in my password$/ do
   fill_in 'login_password', :with => 'password'
end


And /^I click the "([^"]*)" button$/ do |button|
  should have_button button
  click_button button
end

Then /^I should have attended the survey$/ do
  should have_content('Welcome to Expertiza')
end