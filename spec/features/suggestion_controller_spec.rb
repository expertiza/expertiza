# Test suite developed by Anubhab Majumdar (amajumd@ncsu.edu)

require 'rails_helper'
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

	scenario "allow student to log in, add suggestion, add comment, in Assignment 1" do	
		
		user = User.find_by_name('student2064')
    	stub_current_user(user, user.role.name, user.role)
      	
      	visit '/student_task/list'
      	expect(page).to have_content "Assignment 1"

      	find_link('Assignment 1').click
		
		find_link('Suggest a topic').click
		expect(page).to have_content "New suggestion"

		fill_in 'suggestion_title', with: 'Computer Vision'
		fill_in 'suggestion_description', with: 'This is a Computer Vision suggestion'
		select "Y", :from => "suggestion_signup_preference"
		select "Y", :from => "suggestion_signup_preference"
		click_button 'Submit'
      	expect(page).to have_content "Thank you for your suggestion!"
      	expect(page).to have_content "Suggested topics for Assignment 1"	
		expect(page).to have_content "Computer Vision"	
		expect(page).to have_content "Initiated"	
		
		find_link('View').click
		expect(page).to have_content "View Suggested topic Computer Vision"

		fill_in 'suggestion_comment_comments', with: 'Student2064 commenting on Computer Vision'
		click_button 'Submit comment'
		expect(page).to have_content "Your comment has been successfully added."
		expect(page).to have_content "Student2064 commenting on Computer Vision"

		find_link('Back').click
		expect(page).to have_content "Suggested topics for Assignment 1"
				

		find_link('Edit').click
		expect(page).to have_content "Edit Suggested topic Assignment 1"


    end

    

end

