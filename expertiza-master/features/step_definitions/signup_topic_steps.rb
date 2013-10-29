And /^Given that assignment Test Student Signup is listed$/ do
  should have_link 'Assignments'
  click_link 'Assignments'

  if(!find_link('Accept').nil?)
     click_link 'Accept'
  end

  should have_link "Test Student Signup"

end

Then /^I click the Test Student Signup link$/ do
  should have_link "Test Student Signup"
  click_link "Test Student Signup"
end

Then /^I click the Signup sheet link$/ do
  should have_link "Signup sheet"
  click_link "Signup sheet"
end

And /^I click on signup action$/ do
  find(:xpath, "//img[@title = 'Signup']/parent::a").should_not be_nil
  find(:xpath, "//img[@title = 'Signup']/parent::a").click()
end

And /^I verify that the page contains cancel action$/ do
  find(:xpath, "//img[@title = 'Leave Topic']/parent::a").should_not be_nil
end