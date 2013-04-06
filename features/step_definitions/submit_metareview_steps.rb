And /^I open assignment test_Metareview$/ do
  should have_link 'Assignments'
  click_link 'Assignments'

  if(!find_link('Accept').nil?)
     click_link 'Accept'
  end

  should have_link "test_Metareview"
  click_link "test_Metareview"
end

Then /^I click the Others' work link$/ do
  should have_link "Others' work"
  click_link "Others' work"
end

Then /^I click to begin the metareview$/ do
#  find(:xpath, "//table[last()]/tr/td[last()]/a").should_not be_nil
#  a =  find(:xpath, "//table[last()]/tr/td[last()]/a")
  find(:xpath, "//table[last()]//tr//td[last()]/a").should_not be_nil
  find(:xpath, "//table[last()]//tr//td[last()]/a").click()
end

And /^I fill in the metareview$/ do
  assert(true)
end

And /^I click the Save Metareview button$/ do
  should have_button("Save Metareview")
  click_button("Save Metareview")
end

Then /^I click the Continue link$/ do
  should have_link("Continue")
  click_link("Continue")
end

Then /^I click the View link$/ do
  should have_link("View")
  click_link("View")
end

And /^I verify that the metareview was saved$/ do
  should have_content('Hyperlinks')
end

