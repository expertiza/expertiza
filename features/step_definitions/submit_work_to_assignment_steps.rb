<<<<<<< HEAD
<<<<<<< HEAD
And /^I open assignment test_submit_assigment$/ do
  should have_link 'Assignments'
  click_link 'Assignments'

  should have_link "test_submit_assigment"
  click_link "test_submit_assigment"
end

Then /^I click the Your work link$/ do
 should have_link "Your work"
 click_link "Your work"
end

And /^I enter the hyperlink "([^"]*)" for my work$/ do |hyperlink|
   should have_button "Upload link"
   fill_in 'submission', :with => hyperlink
end

Then /^I should see that the link "([^"]*)" is present on the page$/ do |hyperlink|
  should have_link hyperlink
=======
And /^I open assignment test_submit_assigment$/ do
  should have_link 'Assignments'
  click_link 'Assignments'

  should have_link "test_submit_assigment"
  click_link "test_submit_assigment"
end

Then /^I click the Your work link$/ do
 should have_link "Your work"
 click_link "Your work"
end

And /^I enter the hyperlink "([^"]*)" for my work$/ do |hyperlink|
   should have_button "Upload link"
   fill_in 'submission', :with => hyperlink
end

Then /^I should see that the link "([^"]*)" is present on the page$/ do |hyperlink|
  should have_link hyperlink
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
And /^I open assignment test_submit_assigment$/ do
  should have_link 'Assignments'
  click_link 'Assignments'

  should have_link "test_submit_assigment"
  click_link "test_submit_assigment"
end

Then /^I click the Your work link$/ do
 should have_link "Your work"
 click_link "Your work"
end

And /^I enter the hyperlink "([^"]*)" for my work$/ do |hyperlink|
   should have_button "Upload link"
   fill_in 'submission', :with => hyperlink
end

Then /^I should see that the link "([^"]*)" is present on the page$/ do |hyperlink|
  should have_link hyperlink
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
end