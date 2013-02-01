And /^Given that assignment test student signup is listed$/ do
  should have_link 'Assignments'
  click_link 'Assignments'

  if(!find_link('Accept').nil?)
     click_link 'Accept'
  end

  should have_link "test student signup"

end

Then /^I click the test student signup link$/ do
  should have_link "test student signup"
  click_link "test student signup"
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