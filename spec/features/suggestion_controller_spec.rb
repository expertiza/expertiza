# Test suite developed by Anubhab Majumdar (amajumd@ncsu.edu)

require 'rails_helper'
# require 'selenium-webdriver'
include LogInHelper

def log_in(name, password)
    visit '/'
    expect(page).to have_content 'Welcome!'

    fill_in 'User Name', with: name
    fill_in 'Password', with: password
    click_button 'SIGN IN'

    expect(page).to have_content "User: #{name}"
 end


RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end


RSpec.feature "list suggestions"  do

	before(:each) do
		
		create(:assignment, name: 'Assignment 1', allow_suggestions: true)
	    create_list(:participant, 3)
	    create(:assignment_node)
	    create(:deadline_type, name: "submission")
	    create(:deadline_type, name: "review")
	    create(:deadline_type, name: "metareview")
	    create(:deadline_type, name: "drop_topic")
	    create(:deadline_type, name: "signup")
	    create(:deadline_type, name: "team_formation")
	    create(:deadline_right)
	    create(:deadline_right, name: 'Late')
	    create(:deadline_right, name: 'OK')
	    create(:assignment_due_date)
	    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (30 * 24 * 60 * 60))
	end

	scenario "allow instructor to log in and view suggestions (suggestions should be empty) for Assignment 1" do	
		
		user = User.find_by_name('instructor6')
        stub_current_user(user, user.role.name, user.role)
		visit '/suggestion/list?id=1&type=Assignment'
		expect(page).to have_content "Suggested topics for Assignment 1"
		expect(page).to have_no_content "Computer Vision"
		
	end

	scenario "allow student to log in, add suggestion, add comment, edit suggestion in Assignment 1" do	
		
		# Select and log in student2064
		user = User.find_by_name('student2064')
    	stub_current_user(user, user.role.name, user.role)
      	
      	# Check Assignment 1 present in task list
      	visit '/student_task/list'
      	expect(page).to have_content "Assignment 1"

      	# Click on Assignment 1
      	find_link('Assignment 1').click
		
		# Click on suggest topic
		find_link('Suggest a topic').click
		expect(page).to have_content "New suggestion"

		# Create new suggestion (Computer Vision)
		fill_in 'suggestion_title', with: 'Computer Vision'
		fill_in 'suggestion_description', with: 'This is a Computer Vision suggestion'
		select "N", :from => "suggestion_signup_preference"
		click_button 'Submit'
      	expect(page).to have_content "Thank you for your suggestion!"
      	expect(page).to have_content "Suggested topics for Assignment 1"	
		expect(page).to have_content "Computer Vision"	
		expect(page).to have_content "Initiated"	
		
		# View the suggestion
		find_link('View').click
		expect(page).to have_content "View Suggested topic Computer Vision"

		# Add comment
		fill_in 'suggestion_comment_comments', with: 'Student2064 commenting on Computer Vision'
		click_button 'Submit comment'
		expect(page).to have_content "Your comment has been successfully added."
		expect(page).to have_content "Student2064 commenting on Computer Vision"

		# Try adding blank comment
		click_button 'Submit comment'
		expect(page).to have_content "There was an error adding your comment."

		# Go Back
		find_link('Back').click
		
		# Edit title and description
		find_link('Edit').click
		expect(page).to have_content "Edit Suggested topic Computer Vision"
		fill_in 'suggestion_title', with: 'Computer Vision 2'
		fill_in 'suggestion_description', with: 'This is a Computer Vision suggestion 2'
		select "Y", :from => "suggestion_signup_preference"
		click_button 'Submit'
		expect(page).to have_content "Suggested topics for Assignment 1"
		expect(page).to have_content "Computer Vision 2"	
		
		# Check view to make sure changes are persistent
		find_link('View').click
		expect(page).to have_content "View Suggested topic Computer Vision 2"
		expect(page).to have_content "This is a Computer Vision suggestion 2"	
		
		# Succesfully logout
		find_link('Logout').click
		expect(page).to have_content "Welcome!"	
		
    end

    scenario "allow instructor to log in, view suggestions and approve it for Assignment 1" do	
		
		# ------------------------------------------ Student creates suggestion --------------------------------- #
    	# Select and log in student2064
		user = User.find_by_name('student2064')
    	stub_current_user(user, user.role.name, user.role)
      	
      	# Check Assignment 1 present in task list
      	visit '/student_task/list'
      	
      	# Click on Assignment 1
      	find_link('Assignment 1').click
		
		# Click on suggest topic
		find_link('Suggest a topic').click
		
		# Create new suggestion (Computer Vision)
		fill_in 'suggestion_title', with: 'Computer Vision'
		fill_in 'suggestion_description', with: 'This is a Computer Vision suggestion'
		select "Y", :from => "suggestion_signup_preference"
		click_button 'Submit'
      
		# View the suggestion
		find_link('View').click
		
		# Add comment
		fill_in 'suggestion_comment_comments', with: 'Student2064 commenting on Computer Vision'
		click_button 'Submit comment'
		
		# ---------------------------------------------Instructor test------------------------------------------ #
    	
		user = User.find_by_name('instructor6')
        stub_current_user(user, user.role.name, user.role)
		
		visit '/suggestion/list?id=1&type=Assignment'
		
		# Check suggestion has been added for Assignment 1
		expect(page).to have_content "Suggested topics for Assignment 1"
		expect(page).to have_content "Computer Vision"
		expect(page).to have_content "Initiated"
		expect(page).to have_content "student2064"

		# View the suggestion
		find_link('View').click
		expect(page).to have_content "Suggestion"
		expect(page).to have_content "Computer Vision"
		expect(page).to have_content "Student2064 commenting on Computer Vision"
		expect(page).to have_content "student2064"
		expect(page).to have_content "Yes"
		expect(page).to have_content "Initiated"
		expect(page).to have_content "This is a Computer Vision suggestion"
		
		# Approve suggestion				
		click_button 'Approve suggestion'
		expect(page).to have_content "The suggestion was successfully approved."

		# ------------------------------------------ Student checks suggestion --------------------------------- #
    	# Select and log in student2064
		user = User.find_by_name('student2064')
    	stub_current_user(user, user.role.name, user.role)
      	
      	# Check Assignment 1 present in task list
      	visit '/student_task/list'
      	
      	# Click on Assignment 1
      	find_link('Assignment 1').click
		
		# Click on suggest topic
		find_link('Suggest a topic').click
		
		# Check suggestion has been approved for Assignment 1
		expect(page).to have_content "Suggested topics for Assignment 1"
		expect(page).to have_content "Computer Vision"
		expect(page).to have_content "Approved"
		expect(page).to have_content "student2064"

	end

	scenario "allow instructor to log in, view suggestions and reject it for Assignment 1" do	
		
		# ------------------------------------------ Student creates suggestion --------------------------------- #
    	# Select and log in student2064
		user = User.find_by_name('student2064')
    	stub_current_user(user, user.role.name, user.role)
      	
      	# Check Assignment 1 present in task list
      	visit '/student_task/list'
      	
      	# Click on Assignment 1
      	find_link('Assignment 1').click
		
		# Click on suggest topic
		find_link('Suggest a topic').click
		
		# Create new suggestion (Computer Vision)
		fill_in 'suggestion_title', with: 'Computer Vision'
		fill_in 'suggestion_description', with: 'This is a Computer Vision suggestion'
		select "Y", :from => "suggestion_signup_preference"
		click_button 'Submit'
      
		# View the suggestion
		find_link('View').click
		
		# Add comment
		fill_in 'suggestion_comment_comments', with: 'Student2064 commenting on Computer Vision'
		click_button 'Submit comment'
		
		# ---------------------------------------------Instructor test------------------------------------------ #
    	
		user = User.find_by_name('instructor6')
        stub_current_user(user, user.role.name, user.role)
		
		visit '/suggestion/list?id=1&type=Assignment'
		
		# Check suggestion has been added for Assignment 1
		expect(page).to have_content "Suggested topics for Assignment 1"
		expect(page).to have_content "Computer Vision"
		expect(page).to have_content "Initiated"
		expect(page).to have_content "student2064"

		# View the suggestion
		find_link('View').click
		expect(page).to have_content "Suggestion"
		expect(page).to have_content "Computer Vision"
		expect(page).to have_content "Student2064 commenting on Computer Vision"
		expect(page).to have_content "student2064"
		expect(page).to have_content "Yes"
		expect(page).to have_content "Initiated"
		expect(page).to have_content "This is a Computer Vision suggestion"
		
		# Reject suggestion				
		click_button 'Reject suggestion'
		expect(page).to have_content "The suggestion has been successfully rejected."

		# ------------------------------------------ Student checks suggestion --------------------------------- #
    	# Select and log in student2064
		user = User.find_by_name('student2064')
    	stub_current_user(user, user.role.name, user.role)
      	
      	# Check Assignment 1 present in task list
      	visit '/student_task/list'
      	
      	# Click on Assignment 1
      	find_link('Assignment 1').click
		
		# Click on suggest topic
		find_link('Suggest a topic').click
		
		# Check suggestion has been approved for Assignment 1
		expect(page).to have_content "Suggested topics for Assignment 1"
		expect(page).to have_content "Computer Vision"
		expect(page).to have_content "Rejected"
		expect(page).to have_content "student2064"

	end

	scenario "allow instructor to log in, view suggestions and add comment and vote for Assignment 1" do	
		
		# ------------------------------------------ Student creates suggestion --------------------------------- #
    	# Select and log in student2064
		user = User.find_by_name('student2064')
    	stub_current_user(user, user.role.name, user.role)
      	
      	# Check Assignment 1 present in task list
      	visit '/student_task/list'
      	
      	# Click on Assignment 1
      	find_link('Assignment 1').click
		
		# Click on suggest topic
		find_link('Suggest a topic').click
		
		# Create new suggestion (Computer Vision)
		fill_in 'suggestion_title', with: 'Computer Vision'
		fill_in 'suggestion_description', with: 'This is a Computer Vision suggestion'
		select "Y", :from => "suggestion_signup_preference"
		click_button 'Submit'
      
		# View the suggestion
		find_link('View').click
		
		# Add comment
		fill_in 'suggestion_comment_comments', with: 'Student2064 commenting on Computer Vision'
		click_button 'Submit comment'
		
		# ---------------------------------------------Instructor test------------------------------------------ #
    	
		user = User.find_by_name('instructor6')
        stub_current_user(user, user.role.name, user.role)
		
		visit '/suggestion/list?id=1&type=Assignment'
		
		# View the suggestion
		find_link('View').click
		
		# Add Comment
		fill_in 'suggestion_comment_comments', with: 'Instructor6 commenting on Computer Vision'
		select "Y", :from => "suggestion_comment_vote"
		click_button 'Submit vote'
		
		fill_in 'suggestion_comment_comments', with: 'Instructor6 commenting on Computer Vision'
		select "N", :from => "suggestion_comment_vote"
		click_button 'Submit vote'
		
		fill_in 'suggestion_comment_comments', with: 'Instructor6 commenting on Computer Vision'
		select "R", :from => "suggestion_comment_vote"
		click_button 'Submit vote'
		
		# ------------------------------------------ Student checks suggestion --------------------------------- #
    	# Select and log in student2064
		user = User.find_by_name('student2064')
    	stub_current_user(user, user.role.name, user.role)
      	
      	# Check Assignment 1 present in task list
      	visit '/student_task/list'
      	
      	# Click on Assignment 1
      	find_link('Assignment 1').click
		
		# Click on suggest topic
		find_link('Suggest a topic').click
		
		# Click on view
		find_link('View').click
		
		# Check suggestion has been approved for Assignment 1
		expect(page).to have_content "Computer Vision"
		expect(page).to have_content "Yes"
		expect(page).to have_content "No"
		expect(page).to have_content "Revise"
		expect(page).to have_content "Instructor6 commenting on Computer Vision"
		
	end


	scenario "Instructor approves topic not preferred by student suggesting it" do	
		
		# ------------------------------------------ Student creates suggestion --------------------------------- #
    	# Select and log in student2064
		user = User.find_by_name('student2064')
    	stub_current_user(user, user.role.name, user.role)
      	
      	# Check Assignment 1 present in task list
      	visit '/student_task/list'
      	
      	# Click on Assignment 1
      	find_link('Assignment 1').click
		
		# Click on suggest topic
		find_link('Suggest a topic').click
		
		# Create new suggestion (Computer Vision)
		fill_in 'suggestion_title', with: 'Computer Vision'
		fill_in 'suggestion_description', with: 'This is a Computer Vision suggestion'
		select "N", :from => "suggestion_signup_preference"
		click_button 'Submit'
      
		# View the suggestion
		find_link('View').click
		
		# Add comment
		fill_in 'suggestion_comment_comments', with: 'Student2064 commenting on Computer Vision'
		click_button 'Submit comment'
		
		# ---------------------------------------------Instructor test------------------------------------------ #
    	
		user = User.find_by_name('instructor6')
        stub_current_user(user, user.role.name, user.role)
		
		visit '/suggestion/list?id=1&type=Assignment'
		
		
		# View the suggestion
		find_link('View').click
		
		# Approve suggestion				
		click_button 'Approve suggestion'	# Also checks send mail feature is working correctly
		expect(page).to have_content "The suggestion was successfully approved."
	end

	scenario "Form team and approve topic" do	
		
		user = User.find_by_name('instructor6')
        stub_current_user(user, user.role.name, user.role)
		
		visit '/teams/list?id=1&type=Assignment'
		
		find_link("Create Team").click

		fill_in 'Team Name:', with: 'Team1'
		click_button "Save"
		

		# ------------------------------------------ Student creates suggestion --------------------------------- #
    	# Select and log in student2064
		# user = User.find_by_name('student2064')
  #   	stub_current_user(user, user.role.name, user.role)
      	
  #     	# Check Assignment 1 present in task list
  #     	visit '/student_task/list'
      	
  #     	# Click on Assignment 1
  #     	find_link('Assignment 1').click
		
		# # Click on suggest topic
		# find_link('Your team').click
		# expect(page).to have_content "Team Information for Assignment 1"
		# expect(page).to have_content "Invite people"
		
	end	
	


end

