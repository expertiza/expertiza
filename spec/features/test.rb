require 'rails_helper'
require 'spec_helper'

def GenerateAssignmentName()
  (rand(1000) + 1).to_s + 'SpecID' + (1 + rand(1000)).to_s
end

RSpec.feature "create public assignment"  do
    before(:each) do
      #@user = FactoryGirl.create(:user)
      visit root_path
      fill_in('login_name', :with => 'instructor6')
      fill_in('login_password', :with => 'password')
      click_on('SIGN IN')
      expect(page).to have_content('Manage')
      within(".content") do
        click_on("Assignments")
      end
    end
  scenario "Create Assignment has Staggered deadline assignment",:js => true  do        
    click_button 'New public assignment'
        fill_in('assignment_form_assignment_name',:with => GenerateAssignmentName())
        select('CSC 517 Fall 2010', from: 'assignment_form_assignment_course_id')
        fill_in('assignment_form_assignment_directory_path',:with => '/')
        fill_in('assignment_form_assignment_spec_location',:with => 'google.com')
        check('assignment_form_assignment_staggered_deadline')
        #page.driver.browser.switch_to.alert.accept
        check('assignment_form_assignment_availability_flag')
        #find(:xpath, "//input[@id='']").set "0"
        click_on('Create')
        click_on('Rubrics')
        within('#questionnaire_table_ReviewQuestionnaire') do
         select('Animation', from: 'assignment_form[assignment_questionnaire][][questionnaire_id]')
       end
        within('#questionnaire_table_AuthorFeedbackQuestionnaire') do
         select('Author feedback OTD1', from: 'assignment_form[assignment_questionnaire][][questionnaire_id]')
        end
        expect(page).to have_content("Rubrics")
        click_on('submit_btn')
        expect(page).to have_content("successfully",:wait=>5)
  end
end