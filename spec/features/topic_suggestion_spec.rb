require 'rails_helper'
require 'selenium-webdriver'
########################################

#   Case 1: One team is on the waitlist. They sent a suggestion for new topic and they want to choose their suggested topic. After their suggested topic is approved, they should leave the waitlist and hold their suggested topic;

########################################

  describe "Assignment Topic Suggestion Test", :js => true do
    pubAssignment = nil
    before(:each) do
      create(:assignment)
      create(:student)
      create(:studentb)
      create(:assignment_node)
      create(:deadline_type,name:"submission")
      create(:deadline_type,name:"review")
      create(:deadline_type,name:"resubmission")
      create(:deadline_type,name:"rereview")
      create(:deadline_type,name:"metareview")
      create(:deadline_type,name:"drop_topic")
      create(:deadline_type,name:"signup")
      create(:deadline_type,name:"team_formation")
      create(:deadline_right)
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:due_date)
      create(:due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100*24*60*60))
    end
  

   describe "case1", :js => true do

    it "Instructor set an assignment which allow student suggest topic and register student11" do
      login_as "student10"
      click_link("Logout")
      sleep(1000)
      login_as "instructor6"
      #create an assignment
      visit '/assignments/new?private=0'
      expect(page).to have_content "Assignment name"
      fill_in "Assignment name:", with: 'Assignment_suggest_topic'
      click_button "Create"
      expect(Assignment.where(name: "Assignment_suggest_topic")).to exist

      #allow student suggest topic	
      expect(page).to have_content "Topics"
      find_link('Topics').click
      find('#assignment_form_assignment_allow_suggestions').set(true)
      click_button "Save"
      expect(page).to have_content "Assignment was successfully saved"    
      expect(Assignment.find(2).allow_suggestions).to eq true
      #sleep 1000

      #register student
      visit '/tree_display/list'
     #expect(page).to have_content "Assignment_suggest_topic"
      visit '/participants/list?id=2&model=Assignment'
      #fill_in "Enter a user login:", with: 'student11'
      fill_in "user_name", with: 'student11'
      click_button "Add"
      expect(page).to have_content "expertiza@mailinator.com"
      
      #@@@student 10 need to be registered 
      visit '/participants/list?id=2&model=Assignment'
      #fill_in "Enter a user login:", with: 'student10'
      fill_in "user_name", with: 'student10'
      click_button "Add"
      expect(page).to have_content "expertiza@mailinator.com"
      #logout instructor6
      find_link('Logout').click
      visit 'http://0.0.0.0:3000/'
     

      #login as student11, Note by Xing Pan: modify spec/factories/factories.rb to generate student11 and call "create student" at beginning
      fill_in 'login_name', with: 'student11'
      fill_in 'login_password', with: 'password'
      click_button 'SIGN IN'
      #login_as("student11")
      expect(page).to have_content "Assignment_suggest_topic"
      #sleep 1000

      #student11 suggest topic
      find_link('Assignment_suggest_topic').click
      expect(page).to have_content "Suggest a topic"
      find_link('Suggest a topic').click    
      expect(page).to have_content "Title"
      fill_in 'suggestion_title', with: 'suggested_topic'
      fill_in 'suggestion_description', with: 'suggested_description'
      click_button 'Submit'
      expect(page).to have_content "Thank you for your suggestion"
      #sleep 1000

      #logout student11
      find_link('Logout').click
      visit 'http://127.0.0.1:3000/'
      #login as instructor6
      #fill_in 'login_name', with: 'instructor6'
      #fill_in 'login_password', with: 'password'
      #click_button 'SIGN IN'
      login_as("instructor6")
      
      #instructor approve the suggestion topic
      # DUE date need to be added here
      visit '/tree_display/list'
      visit '/suggestion/list?id=2&type=Assignment'  
      expect(page).to have_content "Suggested topics for Assignment_suggest_topic"
      expect(page).to have_content "suggested_topic"
      find_link('View').click  
      expect(page).to have_content "suggested_description"     
      click_button 'Approve suggestion'
      expect(page).to have_content "Successfully approved the suggestion"
      # log out instructor6
      find_link('Logout').click
      visit 'http://127.0.0.1:3000/'
  
      # case 1 need to verify the student's sign up sheet   
   
      # case 2 student already have topic switch to new topic
      # need two students one to be on the waitlist of previous suggested topic,
      # the other one (student11) is holding it and suggest another topic and wish to switch to the new one
      #login as student10 and add itself to the wishlist of the topic
      login_as "student10"            
      click_link('Assignments')
      find_link('Assignment_suggest_topic').click
      find_link('Signup sheet').click
      # Bug found and need the select action name 
      # replace "select" with mark
"""
      find(:xpath, "//tr[contains(.,'suggested_topic')]/td/a", :figure=>"select").click
      # sign up to waitlist
      # but got error
      # expect(page).to have_content "" 
      find_link('Logout').click
      visit 'http://0.0.0.0:3000/'
      
      # log in student11 
      login_as @student.name
      find_link('Assignment_suggest_topic').click
      expect(page).to have_content "Suggest a topic"
      find_link('Suggest a topic').click    
      expect(page).to have_content "Title"
      fill_in 'suggestion_title', with: 'suggested_topic2_will_switch'
      fill_in 'suggestion_description', with: 'suggested_description_2'
      click_button 'Submit'
      expect(page).to have_content "Thank you for your suggestion"
      find_link('Logout').click
      visit 'http://0.0.0.0:3000/'
      
      # login_as instructor6 to approve the 2nd suggested topic  
      login_as("instructor6")
      
      #instructor approve the suggestion topic
      visit '/tree_display/list'
      visit '/suggestion/list?id=2&type=Assignment'  
      expect(page).to have_content "Suggested topics for Assignment_suggest_topic"
      expect(page).to have_content "suggested_topic2_will_switch"
      # find link for new suggested view
      find(:xpath, "//tr[contains(.,'suggested_topic2_with_switch')]/td/a", :text => 'View').click
      #find_link('View').click  
      expect(page).to have_content "suggested_description"     
      click_button 'Approve suggestion'
      expect(page).to have_content "Successfully approved the suggestion"
      # log out instructor6
      find_link('Logout').click
      visit 'http://127.0.0.1:3000/'
   
      # login as student 10 to see if it's holding the topic rather than on the wait list
      login_as "student10"            
      click_link('Assignments')
      find_link('Assignment_suggest_topic').click
      find_link('Signup sheet').click
      find('tr', text: 'suggested_topic').should have_content("x")
      find_link('Logout').click
      visit 'http://0.0.0.0:3000/'

      # login as studnet 11 to see if it's already shifted to the new suggested topic 
      login_as "student11"            
      click_link('Assignments')
      find_link('Assignment_suggest_topic').click
      find_link('Signup sheet').click
      find('tr', text: 'suggested_topic2_with_switch').should have_content("x")
      find_link('Logout').click
      visit 'http://0.0.0.0:3000/'

 """    
    end
   
   end

end
