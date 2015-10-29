require 'rails_helper'
require 'spec_helper'

RSpec.feature "create public course"  do
    before(:each) do
      #@user = FactoryGirl.create(:user)
      visit root_path
      fill_in('login_name', :with => 'instructor6')
      fill_in('login_password', :with => 'password')
      #click_button "SIGN IN"
      click_on('SIGN IN')
      expect(page).to have_content('Manage')
    end
   	#scenario "allow an instructor to login" do
      #create(:user)
   		#create(:role)
     #	visit root_path
      #	fill_in('login_name', :with => 'instructor6')
      #	fill_in('login_password', :with => 'password')
      	#click_button "SIGN IN"
      #	click_on('SIGN IN')
      #	expect(page).to have_content('Manage')
        #click_button 'New public course'
	#end
	scenario "Create Course",:js => true  do        
        #click_button 'New public course'
	      click_button 'New public course'
        fill_in('course_name',:with => 'OOD')
        fill_in('course_directory_path',:with => 'Dummy Path')
        fill_in('course_info',:with => 'Test course')
        #find(:xpath, "//input[@id='']").set "0"
        click_on('Create')
        #wait_for_ajax # This is new!
        expect(page).to have_content("OOD",wait: 10)
	end
end
