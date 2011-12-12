Given 'a topic exists under this assignment' do
  find(:xpath, "//a/img[@title='Add signup sheet']/..").click
  click_link 'New topic'
  fill_in 'topic_topic_identifier', :with => '001'
  fill_in 'topic_topic_name', :with => 'Cucumber Tests'
  fill_in 'topic_category', :with => 'Expertiza testing'
  fill_in 'topic_max_choosers', :with => '2'
  click_button 'Create'
#  click_button 'Logout'
end

Given /^I choose a topic from the list of topics in the assignment "(\S+)"$/ do |assignment|
  click_link assignment
  click_link 'Signup sheet'
  find(:xpath, "//a/img[@title='Signup']/..").click
end

Then /^The topic I chose must be displayed as my topic$/ do
  should have_content('Your topic(s):')
end

