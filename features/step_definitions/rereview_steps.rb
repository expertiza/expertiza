Given(/^I am not currently logged in$/) do
  visit '/login' # express the regexp above with the code you wish you had
end

When(/^I am on the login page$/) do
   # express the regexp above with the code you wish you had
end

When(/^I fill in User Name with "(.*?)"$/) do |arg1|
  fill_in "User Name", with: arg1 # express the regexp above with the code you wish you had
end

When(/^I fill in Password with "(.*?)"$/) do |password|
  fill_in "Password", with: password # express the regexp above with the code you wish you had
end

When(/^I press Login$/) do 
  click_button("Login") # express the regexp above with the code you wish you had
end

Then(/^I should see "(.*?)"$/) do |title|
   # assert page.has_title(title),"Login failed!!- This is a custom message" # express the regexp above with the code you wish you had
     page.should have_content(title)
end

Then(/^I click "(.*?)"$/) do |link|
  click_link(link) # express the regexp above with the code you wish you had
end


Then(/^I should be on the homework page$/) do
  page.should have_content('Submit or Review work for Writing assignment 1b, Spring 2013') # express the regexp above with the code you wish you had
end

Then(/^I should be on the managecontent page$/) do
  page.should have_content('Manage content') # express the regexp above with the code you wish you had
end

Then(/^I should still be on the managecontent page$/) do
  page.should have_content('Manage content') # express the regexp above with the code you wish you had
end

Then(/^I press "(.*?)"$/) do |link|
  click_button(link) # express the regexp above with the code you wish you had
end

Then(/^I click the "(.*?)" link next to it$/) do |arg1|
  page.all(:link,"Update")[1].click # express the regexp above with the code you wish you had
end

Then(/^I click on "(.*?)" in the top bar$/) do |arg1|
  page.all(:link,"Assignments")[0].click # express the regexp above with the code you wish you had
end

Then(/^I should see flash error "(.*?)"$/) do |arg1|
  page.should have_css('div#.flash_error') # express the regexp above with the code you wish you had
end

Then(/^I should not have access to it$/) do
  # express the regexp above with the code you wish you had
end

