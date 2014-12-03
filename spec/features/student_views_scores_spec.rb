describe 'Student views scores', :type => :feature do

  scenario 'viewing student scores' do
    # Student test users used in following scenarios.
    student1 = FactoryGirl.create :student

    # This student is used as the reviewer.
    student2 = FactoryGirl.create :student

    # Create an assignment that will be reviewed.
    assignment = FactoryGirl.create :assignment

    # Use the assignment object to add the student as a participant.
    assignment.add_participant student1.name

    # Create the questionnaire.
    questionnaire = FactoryGirl.create :questionnaire, assignment: assignment

    topic1 = FactoryGirl.create :sign_up_topic, assignment: assignment

    visit root_path

    fill_in 'login_name', with: student1.name
    fill_in 'login_password', with: 'bogus'
    click_on 'Login'

    expect(page).to have_content(student1.name)

    # TODO: Need to make sure that this assignment exists in test data.
    click_on 'assignment'
  end
end

