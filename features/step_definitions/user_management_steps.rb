Given /I View User "([^"]+)"/ do |name|
  step "I fill in \"user[name]\" with \"#{name}\""
  step "I press \"Edit\""
end

Given /I Search Users for a "([^"]+)" containing "([^"]*)"/ do |search_select,search_string|
  step "I fill in \"letter\" with \"#{search_string}\""
  step "I select \"#{search_select}\" from \"search_by\""
  step "I press \"Search\""
end

Given /I try to create a "([^"]+)" user named "([^"]*)"/ do |role,name|
  step "I select \"#{role}\" from \"user[role_id]\""
  step "I fill in \"user[name]\" with \"#{name}\""
  step "I fill in \"user[fullname]\" with \"#{name}\""
  step "I fill in \"user[email]\" with \"#{name}@mailinator.com\""
  step "I fill in \"user[clear_password]\" with \"password\""
  step "I fill in \"user[clear_password_confirmation]\" with \"password\""
  step "I press \"Create\""
end

Given /I import a CSV with (invalid|valid) data for 3 new users/ do |validity| 
  step "I choose \"delim_type_comma\""
  step "I attach the file \"#{File.join(RAILS_ROOT,'features','upload_files','new_users_'+validity+'.csv')}\" to \"file\""
  step "I press \"Import\""
end

Given /I delete the user/ do
  step "I follow \"Delete\""
end
