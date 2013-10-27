#When /^I follow the "Manage..." link as an "([^"]+)"/ do |role| 
#  visit "/menu/manage%20#{role}%20content"
#end

Given /^I follow the "Manage..." link$/ do
  visit "/menu/manage%20instructor%20content"
end


Given /^I try to create a (public|private) teammate review/ do |public_or_private|
    When "I follow the \"Manage...\" link as an \"instructor\""
      And "I follow \"Create #{public_or_private.capitalize} Teammate Review\""
      And "I fill in \"TeammateReview1\" for \"Name\""
      And "I fill in \"Question1\" for \"Question\""
      And "I press \"Create teammate review\""
    Then "I should see \"TeammateReview1\""
end


Given /^I try to create a (public|private) review/ do |public_or_private|
    When "I follow the \"Manage...\" link as an \"instructor\""
      And "I follow \"Create #{public_or_private.capitalize} Review\""
      And "I fill in \"Review1\" for \"Name\""
      And "I fill in \"Question1\" for \"Question\""
      And "I press \"Create review\""
    Then "I should see \"Review1\""
end


Given /^I try to create a (public|private) metareview/ do |public_or_private|
    When "I follow the \"Manage...\" link as an \"instructor\""
      And "I follow \"Create #{public_or_private.capitalize} Metareview\""
      And "I fill in \"Metareview1\" for \"Name\""
      And "I fill in \"Question1\" for \"Question\""
      And "I press \"Create Metareview\""
    Then "I should see \"Metareview1\""
end


Given /^I try to create a (public|private) author feedback review/ do |public_or_private|
    When "I follow the \"Manage...\" link as an \"instructor\""
      And "I follow \"Create #{public_or_private.capitalize} Author Feedback\""
      And "I fill in \"AuthorFeedback1\" for \"Name\""
      And "I fill in \"Question1\" for \"Question\""
      And "I press \"Create author feedback\""
    Then "I should see \"AuthorFeedback1\""
end

