require 'rails_helper'

########################################

#   Case 1: One team is on the waitlist. They sent a suggestion for new topic and they want to choose their suggested topic. After their suggested topic is approved, they should leave the waitlist and hold their suggested topic;

########################################

describe "Assignment Topic Suggestion Test", :js => true do
    pubAssignment = nil
    before(:each) do
      create(:assignment)
      create(:instructorb)
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
  

   ########################################
 # Case 3: 
# One team is holding a topic. They sent a suggestion for new topic, and keep themselves in old topic
########################################



  describe "case3", :js => true do

    it "student11 hold suggest topic and suggest a new one, but wish to stay in the old topic" do
      login_as "instructor7"
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

      visit '/participants/list?id=2&model=Assignment'
      fill_in "user_name", with: 'student11'
      click_button "Add"
      expect(page).to have_content "expertiza@mailinator.com"
      visit '/participants/list?id=2&model=Assignment'
      fill_in "user_name", with: 'student10'
      click_button "Add"
      expect(page).to have_content "expertiza@mailinator.com"
      #logout instructor7
      #find_link('Logout').click

      #login_as "student11"
      user = User.find_by_name('student11')
      stub_current_user(user, user.role.name, user.role)
      visit '/student_task/list'
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
      #find_link('Logout').click
      #click_button 'SIGN IN'
      #login_as "instructor7"
      user = User.find_by_name('instructor7')
      stub_current_user(user, user.role.name, user.role)
      #find_link('Logout').click
      #login_as "student11"
      
      #instructor approve the suggestion topic
      # DUE date need to be added here
      visit '/suggestion/list?id=2&type=Assignment'  
      #expect(page).to have_content "Assignment_suggest_topic"
      find_link('View').click
      expect(page).to have_content "suggested_description"     
      click_button 'Approve suggestion'
      expect(page).to have_content "Successfully approved the suggestion"

      ######################################
      # One team is holding a topic. They sent a suggestion for new topic
     ######################################
      #login_as "student11"
      user = User.find_by_name('student11')
      stub_current_user(user, user.role.name, user.role)
      visit '/student_task/list'
      expect(page).to have_content "Assignment_suggest_topic"

      #student11 suggest topic
      find_link('Assignment_suggest_topic').click
      expect(page).to have_content "Suggest a topic"
      find_link('Suggest a topic').click
      expect(page).to have_content "Title"
      fill_in 'suggestion_title', with: 'suggested_topic2_without_switch'
      fill_in 'suggestion_description', with: 'suggested_description2_without_switch'
      #find('#suggestion_signup_preference').set(N)
      find('#suggestion_signup_preference').find(:xpath, 'option[1]').select_option
      click_button 'Submit'
      expect(page).to have_content "Thank you for your suggestion"
      #sleep 1000

      #login_as "instructor7"
      user = User.find_by_name('instructor7')
      stub_current_user(user, user.role.name, user.role)

      #instructor approve the suggestion topic
      visit '/tree_display/list'
      visit '/suggestion/list?id=2&type=Assignment'
      expect(page).to have_content "Suggested topics for Assignment_suggest_topic"
     expect(page).to have_content "suggested_topic2_without_switch"
      find(:xpath, "//tr[contains(.,'suggested_topic2_without_switch')]/td/a", :text => 'View').click
     #find_link('View').click
     expect(page).to have_content "suggested_description2_without_switch"
     click_button 'Approve suggestion'
     expect(page).to have_content "Successfully approved the suggestion"

      #login_as "student11"
      user = User.find_by_name('student11')
      stub_current_user(user, user.role.name, user.role)
      visit '/student_task/list'
      expect(page).to have_content "Assignment_suggest_topic"
      find_link('Assignment_suggest_topic').click
      expect(page).to have_content "Signup sheet"
      find_link('Signup sheet').click
      expect(page).to have_content " suggested_topic2_without_switch"
      #find_link('publish_approved_suggested_topic').click
      visit '/sign_up_sheet/publish_approved_suggested_topic/2?assignment_id=2'
      #find(:xpath, "//tr[contains(.,'suggested_topic2_without_switch')]/td/a", :figure=>"Publish Topic").click
      visit '/student_task/list'
      expect(page).to have_content "suggested_topic"

      #login_as "student10"
      user = User.find_by_name('student10')
      stub_current_user(user, user.role.name, user.role)
      visit '/student_task/list'
      expect(page).to have_content "Assignment_suggest_topic"
      find_link('Assignment_suggest_topic').click
      expect(page).to have_content "Signup sheet"
      find_link('Signup sheet').click
      expect(page).to have_content " suggested_topic2_without_switch"
      visit '/sign_up_sheet/sign_up?assignment_id=2&id=2'
      visit '/student_task/list'
      expect(page).to have_content " suggested_topic2_without_switch"

     #sleep 1000



    end

  end

end
