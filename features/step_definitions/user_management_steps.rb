Given /I View User "([^"]+)"/ do |name|
  When "I fill in \"user[name]\" with \"#{name}\""
  And "I press \"Edit\""
end

Given /I Search Users for a "([^"]+)" containing "([^"]*)"/ do |search_select,search_string|
  When "I fill in \"letter\" with \"#{search_string}\""
  And "I select \"#{search_select}\" from \"search_by\""
  And "I press \"Search\""
end

Given /I try to create a "([^"]+)" user named "([^"]*)"/ do |role,name|
  When "I select \"#{role}\" from \"user[role_id]\""
  And "I fill in \"user[name]\" with \"#{name}\""
  And "I fill in \"user[fullname]\" with \"#{name}\""
  And "I fill in \"user[email]\" with \"#{name}@mailinator.com\""
  And "I fill in \"user[clear_password]\" with \"password\""
  And "I fill in \"user[clear_password_confirmation]\" with \"password\""
  And "I press \"Create\""
end

Given /I import a CSV with (invalid|valid) data for 3 new users/ do |validity| 
  When "I choose \"delim_type_comma\""
  And "I attach the file \"#{File.join(RAILS_ROOT,'features','upload_files','new_users_'+validity+'.csv')}\" to \"file\""
  And "I press \"Import\""
end

Given /I delete the user/ do
  Then "I follow \"Delete\""
end
