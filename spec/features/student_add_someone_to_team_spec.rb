describe 'Student adds someone to team', :type => :feature do
  it 'send invite to student' do
    student1 = FactoryGirl.create :student
    student2 = FactoryGirl.create :student

    assignment = FactoryGirl.create :assignment
    assignment.add_participant student1.name
    assignment.add_participant student2.name

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
  end
end
