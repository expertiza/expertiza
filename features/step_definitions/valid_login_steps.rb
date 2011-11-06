When /^"([^"]*)":"([^"]*)" logs into the system$/ do |name, password|
  When 'I go to the login page'
  fill_in 'login_name', :with => 'admin'
  fill_in 'login_password', :with => 'password'
  should click_button 'Login'
end

Then /^user has logged in$/ do
  node = find('.sidebar td').node().content()
  if(node.include? 'admin')
    assert(true)
  else
    assert(false)
  end
end