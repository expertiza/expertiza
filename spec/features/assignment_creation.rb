require 'rails_helper'
require 'spec_helper'

RSpec.feature "create public assignment"  do
    before(:each) do
      #@user = FactoryGirl.create(:user)
      visit root_path
      fill_in('login_name', :with => 'instructor6')
      fill_in('login_password', :with => 'password')
      #click_button "SIGN IN"
      click_on('SIGN IN')
      #expect(page).to have_content('Manage')
      click_on('Assignments')
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
	scenario "Create Assignment",:js => true  do        
        #click_button 'New public course'
	      click_button 'New public assignment'
        fill_in('assignment_form_assignment_name',:with => 'RSpec')
        select('CSC 517 Fall 2010', from: 'assignment_form_assignment_course_id')
        fill_in('assignment_form_assignment_directory_path',:with => '/')
        fill_in('assignment_form_assignment_spec_location',:with => 'google.com')
        check('team_assignment')
        #uncheck('A Checkbox')
        #find(:xpath, "//input[@id='']").set "0"
        click_on('Create')
        #click_on('Rubrics')
        #select('Animation', from: 'questionnaire_id')
        #select('CSC 517 Fall 2010', from: 'assignment_form_assignment_course_id')
        #wait_for_ajax # This is new!
        expect(page).to have_content("Rusbrsicss",wait: 10)
	end
end
