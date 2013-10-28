=begin
Given 'I am logged in as "Student1"' do
  And 'I am logged in as admin'
  And 'a student with the username "Student1" exists'
  click_button 'Logout'
  When 'I go to the login page'
  fill_in 'login_name', :with => 'Student1'
  fill_in 'login_password', :with => 'password'
  click_button 'Login'

  Then 'I should be logged in as "Student1"'

end


Given 'I am participating in "test_assignment"' do
  And 'a student with the username "student1" exists'
#  And 'a student with the username "student2" exists'
#  Then '"student2" is assigned as the reviewer'
  And
  click_button 'Logout'
end
=end

Given /^I submit the assignment "(\S+)"$/ do |assignment|
  click_link assignment
  click_link 'Your work'
  fill_in 'uploaded_file', :with => 'C:\Users\Mythri\Desktop\Dec 2.txt'
  click_button 'Upload file'
end


Given 'I click the Leaderboard link' do
  find(:xpath, "//a[contains(.,'Leaderboard')]").click
end

Given 'I click the View Top 3 Leaderboards link' do
  find(:xpath, "//a/span[contains(.,'View Top 3 Leaderboards')]").click
  #find(:css,'#top3Leaderboard_show').click
  #click_link 'View Top 3 Leaderboards'
end

=begin
And /^I click the "(\S+)" link/ do |link|
  click link
end


Then /^I should find "Top 3 Submitted Work"$/ do
  #node =  find(:xpath, "//a[contains(.,#{link})]")
  if(find(:xpath, "//a[contains(.,'Top 3 Submitted Work')]").visible?)
    assert(true)
  else
    assert(false)
  end
end
=end

Then /^I should find "([^"]*)"$/ do |something|
  #find('.sidebar td').should have_content "User: #{username}"
  #node = find('.sidebar td').node().content()
  #node = find('.top3Leaderboard_myDiv td').node().content()
  #within("//a[@id='top3Leaderboard_myDiv']") do
  #  find('something')
  #end

  node = find(:xpath, "//a[@id='top3Leaderboard_myDiv']").node().content

  if(node.include something)
    assert(true)
  else
    assert(false)
  end
end







