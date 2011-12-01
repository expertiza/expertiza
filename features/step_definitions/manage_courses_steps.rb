When /^I follow the "Manage..." link as an "([^"]*)"$/ do |role|
  visit "/menu/manage%20#{role}%20content"
end

Given /^I have a course named "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

