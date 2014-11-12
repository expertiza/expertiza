
And /^I click the "edit" link for "Week 4 wiki"$/ do
  visit('/assignment/edit/18')
end

And /^I fill in "([^"]*)" for "([^"]*)" $/ do |due_date, deadline|
  step "I fill in \"#{due_date}\" for \"due_date\""
  step "I fill in \"#{deadline}\" for \"deadline\""
end

And /^I use Review Round1 named "update_wiki" $/ do
  step "I select \"update_wiki\" from \"questionnaires[review1]\""
end

And /^I use Review Round1 named "rubric1" $/ do
  step "I select \"rubric1\" from \"questionnaires[review2]\""
end