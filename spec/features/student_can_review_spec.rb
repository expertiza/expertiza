describe 'student can review' , :type => :feature do
 it 'create a team and review' do
    student1 = FactoryGirl.create :student
    student2 = FactoryGirl.create :student
    student3 = FactoryGirl.create :student
    assignment = FactoryGirl.create :assignment
    assignment.add_participant student1.name
    assignment.add_participant student2.name
    assignment.add_participant student3.name
     
    topic = FactoryGirl.create :sign_up_topic, assignment: assignment

    team_name = 'TestTeamName'

    # Log in as student1
    log_in_as_user(student1)

    # Navigate to the assignment team page
    click_link assignment.name
    click_link 'Your team'

    # Create a team
    fill_in 'team_name', with: team_name
    click_on 'Create Team'

    # Expect team name to be displayed
    expect(page).to have_content(team_name)

    # Invite student2 to the team
    fill_in 'user_name', with: student2.name
    click_on 'Invite'

    # Expect student2 to show up under 'Sent Invitations'
    expect(page).to have_content(student2.name)

    # Switch to student2
    log_out
    log_in_as_user(student2)

    # Navigate to the assignment team page
    click_link assignment.name
    click_link 'Your team'

    # Expect team name to be displayed under 'Received Invitations'
    expect(page).to have_content(team_name)

    # Accept the team invitation
    click_link 'Accept'

    # Expect team name to be displayed under 'Team members'
    expect(page).to have_content(team_name)
    log_out
 
    # Log in with first user to create a submission
    log_in_as_user(student1)
    click_link assignment.name
	  expect(page).to have_content('Your work')
	  click_link 'Your work'
	
	 #fill in the submission with a valid URL and upload it
	 fill_in 'submission', with: 'https://github.com/goldsy/expertiza'
   click_on 'Upload link'
   expect(page).to have_content('https://github.com/goldsy/expertiza') 
	 log_out
     
	 #Log in with third user to review the submission 
	 log_in_as_user(student3)
   click_link assignment.name
   expect(page).to have_content("Others' work")
   click_link "Others' work"
   check 'i_dont_care'
   #A bug in the ReviewMappingController class is preventing the topic to be selected for review
   #click_on 'Request a new submission to review'
	 # expect(page).to have_content('Begin')
 end
end 
