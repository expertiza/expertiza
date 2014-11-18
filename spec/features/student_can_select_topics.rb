describe 'Student can select topics', :type => :feature do
  it 'select a topic' do
    assignment = FactoryGirl.create :assignment
    student = FactoryGirl.create :student

    assignment.add_participant student.name
    
    topic1 = FactoryGirl.create :sign_up_topic, assignment: assignment
    topic2 = FactoryGirl.create :sign_up_topic, assignment: assignment
    topic3 = FactoryGirl.create :sign_up_topic, assignment: assignment
    topic4 = FactoryGirl.create :sign_up_topic, assignment: assignment
    topic5 = FactoryGirl.create :sign_up_topic, assignment: assignment

    visit root_path

    # Log in as student1
    fill_in 'login_name', with: student1.name
    fill_in 'login_password', with: student1.password
    click_on 'Login'

    # Navigate to the assignment
    click_link assignment.name
    click_link 'Signup sheet'

    # Create a team
    fill_in 'team_name', with: 'TestTeamName'
    click_on 'Create Team'

    # Expect team name to be displayed
    expect(page).to have_content('TestTeamName')

    # Invite student2 to the team
    fill_in 'user_name', with: student2.name
    click_on 'Invite'

    # Expect student2 to show up under 'Sent Invitations'
    expect(page).to have_content(student2.name)
  end
end
