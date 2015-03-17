Given(/^I am not currently logged in$/) do
  visit '/login' # express the regexp above with the code you wish you had
end

When(/^I am on the login page$/) do
  # express the regexp above with the code you wish you had
end

When(/^I fill in Email with "(.*?)"$/) do |name|
  fill_in "login[name]", with: name # express the regexp above with the code you wish you had
end

When(/^I fill in Password with "(.*?)"$/) do |password|
  fill_in "login[password]", with: password # express the regexp above with the code you wish you had
end

When(/^I press Login$/) do
  click_button("Login") # express the regexp above with the code you wish you had
end

Then(/^I should see "(.*?)"$/) do |title|
  page.should have_content(title) # express the regexp above with the code you wish you had
end


When(/^I click on "(.*?)"$/) do |link|
  click_link(link) # express the regexp above with the code you wish you had
end

