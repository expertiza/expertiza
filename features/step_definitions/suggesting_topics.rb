And /^the assignment "(\S+)" allows me to suggest topics$/ do |assignment|
  When "I open the assignment #{assignment}"
  And 'I click on the link to Suggest a topic'
end

When /^I open the assignment (\S+)$/ do |assignment|
  click_link assignment
end


And 'I click on the link to Suggest a topic' do
  click_link 'Suggest a topic'
end

And /^I provide the Title & the Description on the following page$/ do
  fill_in 'suggestion_title', :with => "test suggestion title"
  fill_in 'suggestion_description', :with => "test suggestion description"
end

And /^I click "Submit"$/ do
  click_button 'Submit'
end

Then /^the following page should emit the text "Thank you for your suggestion!"$/ do
  should have_content 'Thank you for your suggestion!'
end