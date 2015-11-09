require 'spec_helper'
require 'rails_helper'

require File.join('./app/controllers/application_controller')

require File.join('./app/controllers/suggestion_controller')


describe "SuggestionController" do

  describe "#Test1:approve_suggestion_in_waitlist" do
  
    # Prepare for test
    before(:each) do
        @assignment_id = 711
        @topic_id = 2864
        @team_id = 27816
        @assignment = Assignment.find_by_id(@assignment_id)
        @topc = SignUpTopic.find_by_assignment_id(@topic_id)
        @team = Team.find_by_id(@team_id)
        
        if !@assignment.nil?
          @assignment.update_attribute(:allow_suggestions, 1);
          # puts "==> modify success? " + @assignment.allow_suggestions.to_s
        else
          puts "==> assignment is nil"
        end
    end
    
    # Test login with account of student5717
    it "should be able to login " do
      visit 'content_pages/view'
      expect(page).to have_content('Welcome')
      fill_in "User Name", with: "student5717"
      fill_in "Password", with: "password"
      click_button "SIGN IN"
    
      expect(page).to have_content('Assignments')
      expect(page).to have_content('Writing assignment 1a')
      
      visit '/suggestion/new?id=711'
      expect(page).to have_content('New suggestion')
    end
    
    # Test function of suggesting a new topic
    it "should be able to suggest a new topic " do
      # login with account student5717
      visit 'content_pages/view'
      expect(page).to have_content('Welcome')
      fill_in "User Name", with: "student5717"
      fill_in "Password", with: "password"
      click_button "SIGN IN"
    
      # suggest a new topic
      visit '/suggestion/new?id=711'
      fill_in 'suggestion_title',  with: 'RSpect'
      fill_in 'suggestion_description',  with: 'RSpect is a ROR test framework. It focus on function test'
      # select 'suggestion_signup_preference', with: 'Y'
      expect{click_button "Submit"}.to change(Suggestion, :count).by(1)
    end
    
    # Test logout function
    it " should be able to logout " do
      # login with account student5717
      visit 'content_pages/view'
      expect(page).to have_content('Welcome')
      fill_in "User Name", with: "student5717"
      fill_in "Password", with: "password"
      click_button "SIGN IN"
      
      # click logout link
      visit '/suggestion/new?id=711'
      click_link "Logout"
      current_path.should == "/"
      
      # check logout successfully
      visit '/suggestion/new?id=711'
      expect(page).to have_content('This is not allowed')
      expect(page).to have_content('Welcome')
      expect(page).to have_no_content('User: student5717')
      
      # check logout successfully
      visit '/menu/Course%20Evaluation'
      expect(page).to have_content('This is not allowed')
      expect(page).to have_content('Welcome')
    end

    it " should be able to approve a new suggestion " do
      # Login with student5717 account
      visit 'content_pages/view'
      expect(page).to have_content('Welcome')
      fill_in "User Name", with: "student5717"
      fill_in "Password", with: "password"
      click_button "SIGN IN"
    
      # suggest a new suggestion
      visit '/suggestion/new?id=711'
      fill_in 'suggestion_title',  with: 'RSpect'
      fill_in 'suggestion_description',  with: 'RSpect is a ROR test framework. It focus on function test'
      # select 'suggestion_signup_preference', with: 'Y'
      expect{click_button "Submit"}.to change(Suggestion, :count).by(1)
    
      # Logout current account student5717
      visit '/suggestion/new?id=711'
      click_link "Logout"
      expect(current_path).to eq("/")
      
      # Login with account instructor6
      visit 'content_pages/view'
      expect(page).to have_content('Welcome.')
      fill_in "User Name", with: 'instructor6'
      fill_in "Password", with: 'password'
      click_button "SIGN IN"
      
      # approve the suggestion
      expect(page).to have_content('Manage content')
      visit '/suggestion/list?id=711&type=Assignment'
      expect(page).to have_content('Suggested topics for Writing assignment 1a')
      expect(page).to have_content('RSpect')
      
      num = Suggestion.last.id
      visit "/suggestion/"+num.to_s
      expect(page).to have_content('Suggestion')
      expect(page).to have_content('Title:	RSpect')
      click_button "Approve suggestion"
      visit "/suggestion/"+num.to_s
      expect(page).to have_content('status:	Approved')
      
      # check if is not in waitlist
      visit "/assignments/711/edit#tabs-2"
      expect(page).to have_no_content("<br/><b>Writing assignment 1a_Team14</b><br/>student5717 <font color='red'>(waitlisted)</font>")
      
      # Logout current account instructor6
      visit '/suggestion/new?id=711'
      click_link "Logout"
      current_path.should == "/"
      
      # Login with student5717 account
      visit 'content_pages/view'
      expect(page).to have_content('Welcome')
      fill_in "User Name", with: "student5717"
      fill_in "Password", with: "password"
      click_button "SIGN IN"
      
      # Check if you select the topic successfully
      visit '/sign_up_sheet/list?assignment_id=711'
      expect(page).to have_content('Your topic(s): RSpect')
      
    end
  end
  
  describe "test2"  do
    it 'should switch to suggested topic after it got approved' do
      @newtopic = 'Violet and Zoe'


      #sign in as student5404:
      visit 'content_pages/view'
      fill_in "User Name", with: 'student5404'
      fill_in "Password", with: 'password'
      click_button "SIGN IN"
      expect(page).to have_content('Assignments')

      #suggest a topic:
      # signup_preference default to be Y
      visit "/student_task/view?id=28634"
      expect(page).to have_content('Submit or Review work')
      visit "/suggestion/new?id=711"
      expect(page).to have_content('New suggestion')
      fill_in 'Title',with: @newtopic
      expect{click_button "Submit"}.to change(Suggestion, :count).by(1)

      #logout
      click_link "Logout"
      expect(current_path).to eq("/")
      visit '/suggestion/new?id=711'
      expect(page).to have_content('This is not allowed')
      expect(page).to have_content('Welcome')
      expect(page).to have_no_content('User: student5404')

      #sign in as instructor6
      visit 'content_pages/view'
      expect(page).to have_content('Welcome.')
      fill_in "User Name", with: 'instructor6'
      fill_in "Password", with: 'password'
      click_button "SIGN IN"
      expect(page).to have_content('Manage content')

      #approve the suggestion
      visit '/suggestion/list?id=711&type=Assignment'
      expect(page).to have_content('Suggested topics for Writing assignment 1a')
      num = Suggestion.last.id.to_s
      visit "/suggestion/"+num
      expect(page).to have_content('Suggestion')
      expect(page).to have_content('Title: '+@newtopic)
      click_button "Approve suggestion"
      visit "/suggestion/"+num.to_s
      expect(page).to have_content('status:	Approved')

      #logout as instructor6
      click_link "Logout"
      expect(current_path).to eq("/")
      visit '/suggestion/new?id=711'
      expect(page).to have_content('This is not allowed')
      expect(page).to have_content('Welcome')

      #sign in as student5404:
      visit 'content_pages/view'
      fill_in "User Name", with: 'student5404'
      fill_in "Password", with: 'password'
      click_button "SIGN IN"
      expect(page).to have_content('Assignments')

      #check the approved suggestion in topics list
      visit "/sign_up_sheet/list?assignment_id=711"
      expect(page).to have_content("Your approved suggested topic")

      # switch to the new topic
      num2 = SignUpTopic.last.id.to_s
      visit "/sign_up_sheet/switch_original_topic_to_approved_suggested_topic/"+num2+"?assignment_id=711"
      expect(page).to have_content("Your topic(s): "+@newtopic)
      
      #logout student5404
      click_link "Logout"
      expect(current_path).to eq("/")
      visit '/suggestion/new?id=711'
      expect(page).to have_content('This is not allowed')
      expect(page).to have_content('Welcome')
      expect(page).to have_no_content('User: student5404')

      #sign in as instructor6
      visit 'content_pages/view'
      expect(page).to have_content('Welcome.')
      fill_in "User Name", with: 'instructor6'
      fill_in "Password", with: 'password'
      click_button "SIGN IN"
      expect(page).to have_content('Manage content')
      
      # check if team1 is has not enrolled
      visit "/assignments/711/edit#tabs-2"
      expect(page).to have_no_content("<br/><b>Writing assignment 1a_Team1</b><br/>student5404 student5731 <br/>")
      expect(page).to have_content("Writing assignment 1a_Team5 student5740 student5704")
      expect(page).to have_content("Violet and Zoe Writing assignment 1a_Team1 student5404 student5731")
    end
  end
  
  # Test by Hma
  describe "test3" do
    it "test" do
      # login as student and submit a suggestion
      visit 'content_pages/view'
      fill_in "User Name", with: "student5404"
      fill_in "Password", with: "password"
      click_button "SIGN IN"
  
      visit '/suggestion/new?id=711'
      fill_in 'suggestion_title',  with: 'test title'
      fill_in 'suggestion_description',  with: 'test description'
      select 'No', from: "suggestion_signup_preference"
      click_button "Submit"
  
      click_link "Logout"
  
      #login as a professor and approve the suggestion
      visit 'content_pages/view'
      fill_in "User Name", with: 'instructor6'
      fill_in "Password", with: 'password'
      click_button "SIGN IN"
  
      visit "/suggestion/" + Suggestion.last.id.to_s
      click_button "Approve suggestion"
  
      click_link "Logout"
      
      #login again as a student, check if the topic is changed
      visit 'content_pages/view'
      fill_in "User Name", with: 'student5404'
      fill_in "Password", with: 'password'
      click_button "SIGN IN"
  
      visit '/sign_up_sheet/list?assignment_id=711'
      expect(page).to have_content('Your topic(s): Amazon S3 and Rails')
      
      #logout student5404
      click_link "Logout"
      expect(current_path).to eq("/")
      visit '/suggestion/new?id=711'
      expect(page).to have_content('This is not allowed')
      expect(page).to have_content('Welcome')
      expect(page).to have_no_content('User: student5404')

      #sign in as instructor6
      visit 'content_pages/view'
      expect(page).to have_content('Welcome.')
      fill_in "User Name", with: 'instructor6'
      fill_in "Password", with: 'password'
      click_button "SIGN IN"
      expect(page).to have_content('Manage content')
      
      # check if team1 is has not enrolled
      visit "/assignments/711/edit#tabs-2"
      expect(page).to have_content("Amazon S3 and Rails Writing assignment 1a_Team1 student5404 student5731")
      expect(page).to have_content("test title No choosers.")
    end
  end

end 
