# TODO write quiz tests
require 'rails_helper'
require 'selenium-webdriver'

def create_quiz
  login_as @student.name

  # Click on the assignment link, and navigate to work view
  click_link @assignment.name
  click_link 'Your work'

  # Click on create quiz link
  click_link 'Create a quiz'

  # Fill in the form for Name
  fill_in 'questionnaire_name', :with => 'Quiz for test'

  # Fill in the form for Question 1
  fill_in 'text_area', :with => 'Test Question 1'

  # Choose the quiz to be a single choice question
  page.choose('question_type_1_type_multiplechoiceradio')

  # Fill in for all 4 choices
  fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', :with => 'Test Quiz 1'
  fill_in 'new_choices_1_MultipleChoiceRadio_2_txt', :with => 'Test Quiz 2'
  fill_in 'new_choices_1_MultipleChoiceRadio_3_txt', :with => 'Test Quiz 3'
  fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', :with => 'Test Quiz 4'

  # Choose the first one to be the correct answer
  page.choose('new_choices_1_MultipleChoiceRadio_1_iscorrect_1')

  # Save quiz
  click_on 'Create Quiz'
end

describe 'Student can create quizzes and edit them', :js => true do
  before(:each) do
    # Create an instructor
    @instructor = create(:instructor)

    # Create a student
    @student = create(:student)

    #Create an assignment with quiz
    @assignment = create :assignment, require_quiz: true, instructor: @instructor, course: nil, num_quiz_questions: 1

    # Create an assignment due date
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
    create :due_date, due_at: (DateTime.now + 1)

    @review_deadline_type=create(:deadline_type,name:"review")
    create :due_date, due_at: (DateTime.now + 1), deadline_type: @review_deadline_type

    # Create a team linked to the calibrated assignment
    @team = create :assignment_team, assignment: @assignment

    # Create an assignment participant linked to the assignment
    @participant = create :participant, assignment: @assignment, user: @student

    # Create a mapping between the assignment team and the
    # participant object's user (the submitter).
    create :team_user, team: @team, user: @student
    create :review_response_map, assignment: @assignment, reviewee: @team

  end

  it 'should be able to create quiz' do
    # Create a quiz
    create_quiz

    # If the page have link View Quiz and Edit quiz, meaning the quiz has been created.
    expect(page).to have_link('View quiz')
    expect(page).to have_link('Edit quiz')

  end

  it 'should be able to view quiz after create one' do
    # Create a quiz
    create_quiz

    # Be able to see the quiz
    click_on 'View quiz'

    # Should be able to see the question just created
    expect(page).to have_content('Test Question 1')


  end

  it 'should be able to edit quiz after create one' do
    login_as @student.name

    # Click on the assignment link, and navigate to work view
    click_link @assignment.name
    click_link 'Your work'

    # Create a quiz for the assignment
    click_link 'Create a quiz'
    fill_in 'questionnaire_name', :with => 'Quiz for test'
    fill_in 'text_area', :with => 'Test Question 1'
    page.choose('question_type_1_type_multiplechoiceradio')
    fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', :with => 'Test Quiz 1'
    fill_in 'new_choices_1_MultipleChoiceRadio_2_txt', :with => 'Test Quiz 2'
    fill_in 'new_choices_1_MultipleChoiceRadio_3_txt', :with => 'Test Quiz 3'
    fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', :with => 'Test Quiz 4'
    page.choose('new_choices_1_MultipleChoiceRadio_1_iscorrect_1')
    click_on 'Create Quiz'

    # Should be able to edit the quiz
    click_on 'Edit quiz'


    # Should be able to edit the question just created
    expect(page).to have_content('Edit Quiz')

    fill_in 'quiz_question_choices_1_MultipleChoiceRadio_1_txt', :with => 'Test Quiz 1 Edit'

    # Save the edit choice
    click_on 'Save quiz'

    # View the quiz we just edited
    click_on 'View quiz'

    # Verify that the edit choice has been saved
    expect(page).to have_content('Test Quiz 1 Edit')

  end

  it 'should have error message if the name of the quiz is missing' do
    login_as @student.name

    # Click on the assignment link, and navigate to work view
    click_link @assignment.name
    click_link 'Your work'

    # Create a quiz for the assignment without quiz name
    click_link 'Create a quiz'

    # Without fill in quiz name
    fill_in 'text_area', :with => 'Test Question 1'
    page.choose('question_type_1_type_multiplechoiceradio')
    fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', :with => 'Test Quiz 1'
    fill_in 'new_choices_1_MultipleChoiceRadio_2_txt', :with => 'Test Quiz 2'
    fill_in 'new_choices_1_MultipleChoiceRadio_3_txt', :with => 'Test Quiz 3'
    fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', :with => 'Test Quiz 4'
    page.choose('new_choices_1_MultipleChoiceRadio_1_iscorrect_1')
    click_on 'Create Quiz'

    # Should have the error message Please specify quiz name (please do not use your name or id on the page
    expect(page).to have_content ('Please specify quiz name (please do not use your name or id).')
  end

  it 'should have error message if The question text is missing for one or more questions' do
    login_as @student.name

    # Click on the assignment link, and navigate to work view
    click_link @assignment.name
    click_link 'Your work'

    #Create a quiz for the assignment without fill in question text
    click_link 'Create a quiz'
    fill_in 'questionnaire_name', :with => 'Quiz for test'

    # Withnot fill in the question text
    page.choose('question_type_1_type_multiplechoiceradio')
    fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', :with => 'Test Quiz 1'
    fill_in 'new_choices_1_MultipleChoiceRadio_2_txt', :with => 'Test Quiz 2'
    fill_in 'new_choices_1_MultipleChoiceRadio_3_txt', :with => 'Test Quiz 3'
    fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', :with => 'Test Quiz 4'
    page.choose('new_choices_1_MultipleChoiceRadio_1_iscorrect_1')
    click_on 'Create Quiz'

    #Should have the error message Please make sure all questions have text
    expect(page).to have_content ('Please make sure all questions have text')
  end

  it 'should have error message if the choices are missing for one or more questions' do
    login_as @student.name

    # Click on the assignment link, and navigate to work view
    click_link @assignment.name
    click_link 'Your work'

    #Create a quiz for the assignment without fill in every choices
    click_link 'Create a quiz'
    fill_in 'questionnaire_name', :with => 'Quiz for test'
    fill_in 'text_area', :with => 'Test Question 1'
    page.choose('question_type_1_type_multiplechoiceradio')

    #missing choice 2 and 3
    fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', :with => 'Test Quiz 1'
    fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', :with => 'Test Quiz 4'
    page.choose('new_choices_1_MultipleChoiceRadio_1_iscorrect_1')
    click_on 'Create Quiz'

    #Should have the error message Please make sure every question has text for all options
    expect(page).to have_content ('Please make sure every question has text for all options')
  end

  it 'should have error message if the correct answer(s) have not been provided' do
    login_as @student.name

    # Click on the assignment link, and navigate to work view
    click_link @assignment.name
    click_link 'Your work'

    #Create a quiz for the assignment without fill in every choices
    click_link 'Create a quiz'
    fill_in 'questionnaire_name', :with => 'Quiz for test'
    fill_in 'text_area', :with => 'Test Question 1'
    page.choose('question_type_1_type_multiplechoiceradio')

    #missing choice 2 and 3
    fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', :with => 'Test Quiz 1'
    fill_in 'new_choices_1_MultipleChoiceRadio_2_txt', :with => 'Test Quiz 2'
    fill_in 'new_choices_1_MultipleChoiceRadio_3_txt', :with => 'Test Quiz 3'
    fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', :with => 'Test Quiz 4'

    # Save without choosing the correct answer for the quiz
    click_on 'Create Quiz'

    # Should have the error message Please select a correct answer for all questions
    expect(page).to have_content ('Please select a correct answer for all questions')
  end



end