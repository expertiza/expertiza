describe 'Student views scores', :type => :feature do

  scenario 'viewing student scores' do
    # Student test users used in following scenarios.
    student1 = FactoryGirl.create :student

    # Create an assignment that will be reviewed.
    assignment = FactoryGirl.create :assignment

    # Use the assignment object to add the student as a participant.
    assignment.add_participant student1.name

    # Create the questionnaire.
    #questionnaire = FactoryGirl.create :questionnaire, assignment: assignment

    #topic1 = FactoryGirl.create :sign_up_topic, assignment: assignment
    scoreCache = FactoryGirl.create :score_cache, reviewee_id: student1.id

    visit root_path

    log_in_as_user(student1)

    expect(page).to have_content(student1.name)

    # NOTE: Need to make sure that this assignment exists in test data.
    click_link assignment.name

    click_link 'Your scores'

    #expect(page).to have_content('87.65')
    expect(page).to have_content('Score for')
  end
end

