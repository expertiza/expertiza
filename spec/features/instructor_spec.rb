require 'rails_helper'
require 'spec_helper'


RSpec.feature "login as instructor",:js => true do
   scenario "allow an instructor to login" do
   	create(:user)
   	#create(:role)
     visit root_path
      fill_in('User Name', :with => 'instructor6')
      fill_in('Password', :with => 'password')
      #click_button "SIGN IN"
      click_on('SIGN IN')
      expect(page).to have_content('Manage')
	end
end

#RSpec.feature "create public course",:js => true  do
	#create(:user)
 #  	scenario "allow an instructor to login" do
  # 		create(:role)
    # 	visit root_path
     # 	fill_in('User Name', :with => 'instructor6')
      #	fill_in('Password', :with => 'password')
      	#click_button "SIGN IN"
      
 #	click_on('SIGN IN')
  #    	expect(page).to have_content('Manage')
	#end
	#scenario "Test",:js => true  do
	#	expect(page).to have_content('name')

	#end
#end

#RSpec.feature "Invalid login as instructor" do
 #  scenario "not allow an instructor to login if invalid password" do
  # 	create(:user)
   	#create(:role)
   #  visit root_path
    #  fill_in('User Name', :with => 'instructor6')
     # fill_in('Password', :with => 'passwors')
      #click_button "SIGN IN"
      #click_on('SIGN IN')
      #expect(page).to have_content('Incorrect')
	#end
#end