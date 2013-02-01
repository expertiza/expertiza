And /^I delete the instructor "(\S+)"/ do |instructor|
  click_link instructor
  click_link 'Delete'
end

Then /^I should not be able to see "(\S+)" under the list of instructors$/ do |instructor|
  should have_no_content instructor
end