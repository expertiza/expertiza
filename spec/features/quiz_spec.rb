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
  fill_in 'questionnaire_name', with: 'Quiz for test'

  # Fill in the form for Question 1
  fill_in 'text_area', with: 'Test Question 1'

  # Choose the quiz to be a single choice question
  page.choose('question_type_1_type_multiplechoiceradio')

  # Fill in for all 4 choices
  fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', with: 'Test Quiz 1'
  fill_in 'new_choices_1_MultipleChoiceRadio_2_txt', with: 'Test Quiz 2'
  fill_in 'new_choices_1_MultipleChoiceRadio_3_txt', with: 'Test Quiz 3'
  fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', with: 'Test Quiz 4'

  # Choose the first one to be the correct answer
  page.choose('new_choices_1_MultipleChoiceRadio_1_iscorrect_1')

  # Save quiz
  click_on 'Create Quiz'
end
  describe 'Student can create quizzes and edit them', js: true do


    before(:each) do
      # Create an instructor
      @instructor = User.find_by(name:'instructor6')
      # Create a student
      @student = User.find_by(name:'student4')
      # Create an assignment with quiz
      @assignment = Assignment.find_by(name:'quiz_test_assignment1')
      @student2 = User.find_by(name:'student5')

    end
    it 'should be able to create quiz' do
      # Create a quiz
      create_quiz

      # If the page have link View Quiz and Edit quiz, meaning the quiz has been created.
      expect(page).to have_link('View quiz')
      expect(page).to have_link('Edit quiz')
      QuizQuestionChoice.where(question_id:Question.find_by(txt:'Test Question 1').id).delete_all
      Question.where(txt:'Test Question 1').delete_all
      Questionnaire.where(name:'Quiz for test').delete_all
    end

    it 'should be able to view quiz after create one' do
      # Create a quiz
      create_quiz

      # Be able to see the quiz
      click_on 'View quiz'

      # Should be able to see the question just created
      expect(page).to have_content('Test Question 1')
      QuizQuestionChoice.where(question_id:Question.find_by(txt:'Test Question 1').id).delete_all
      Question.where(txt:'Test Question 1').delete_all
      Questionnaire.where(name:'Quiz for test').delete_all

    end

    it 'should be able to edit quiz after create one' do
      login_as @student.name

      # Click on the assignment link, and navigate to work view
      click_link @assignment.name
      click_link 'Your work'

      # Create a quiz for the assignment
      click_link 'Create a quiz'
      fill_in 'questionnaire_name', with: 'Quiz for test'
      fill_in 'text_area', with: 'Test Question 1'
      page.choose('question_type_1_type_multiplechoiceradio')
      fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', with: 'Test Quiz 1'
      fill_in 'new_choices_1_MultipleChoiceRadio_2_txt', with: 'Test Quiz 2'
      fill_in 'new_choices_1_MultipleChoiceRadio_3_txt', with: 'Test Quiz 3'
      fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', with: 'Test Quiz 4'
      page.choose('new_choices_1_MultipleChoiceRadio_1_iscorrect_1')
      click_on 'Create Quiz'

      # Should be able to edit the quiz
      click_on 'Edit quiz'

      # Should be able to edit the question just created
      expect(page).to have_content('Edit Quiz')
      @id=Question.find_by(txt:'Test Question 1').id
      fill_in "quiz_question_choices_#{@id}_MultipleChoiceRadio_1_txt", with: 'Test Quiz 1 Edit'

      # Save the edit choice
      click_on 'Save quiz'

      # View the quiz we just edited
      click_on 'View quiz'

      # Verify that the edit choice has been saved
      expect(page).to have_content('Test Quiz 1 Edit')
      QuizQuestionChoice.where(question_id:Question.find_by(txt:'Test Question 1').id).delete_all
      Question.where(txt:'Test Question 1').delete_all
      Questionnaire.where(name:'Quiz for test').delete_all
    end

    it 'should have error message if the name of the quiz is missing' do
      login_as @student.name

      # Click on the assignment link, and navigate to work view
      click_link @assignment.name
      click_link 'Your work'

      # Create a quiz for the assignment without quiz name
      click_link 'Create a quiz'

      # Without fill in quiz name
      fill_in 'text_area', with: 'Test Question 1'
      page.choose('question_type_1_type_multiplechoiceradio')
      fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', with: 'Test Quiz 1'
      fill_in 'new_choices_1_MultipleChoiceRadio_2_txt', with: 'Test Quiz 2'
      fill_in 'new_choices_1_MultipleChoiceRadio_3_txt', with: 'Test Quiz 3'
      fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', with: 'Test Quiz 4'
      page.choose('new_choices_1_MultipleChoiceRadio_1_iscorrect_1')
      click_on 'Create Quiz'

      # Should have the error message Please specify quiz name (please do not use your name or id on the page
      expect(page).to have_content 'Please specify quiz name (please do not use your name or id).'
    end

    it 'should have error message if The question text is missing for one or more questions' do
      login_as @student.name

      # Click on the assignment link, and navigate to work view
      click_link @assignment.name
      click_link 'Your work'

      # Create a quiz for the assignment without fill in question text
      click_link 'Create a quiz'
      fill_in 'questionnaire_name', with: 'Quiz for test'

      # Withnot fill in the question text
      page.choose('question_type_1_type_multiplechoiceradio')
      fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', with: 'Test Quiz 1'
      fill_in 'new_choices_1_MultipleChoiceRadio_2_txt', with: 'Test Quiz 2'
      fill_in 'new_choices_1_MultipleChoiceRadio_3_txt', with: 'Test Quiz 3'
      fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', with: 'Test Quiz 4'
      page.choose('new_choices_1_MultipleChoiceRadio_1_iscorrect_1')
      click_on 'Create Quiz'

      # Should have the error message Please make sure all questions have text
      expect(page).to have_content 'Please make sure all questions have text'
    end

    it 'should have error message if the choices are missing for one or more questions' do
      login_as @student.name

      # Click on the assignment link, and navigate to work view
      click_link @assignment.name
      click_link 'Your work'

      # Create a quiz for the assignment without fill in every choices
      click_link 'Create a quiz'
      fill_in 'questionnaire_name', with: 'Quiz for test'
      fill_in 'text_area', with: 'Test Question 1'
      page.choose('question_type_1_type_multiplechoiceradio')

      # missing choice 2 and 3
      fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', with: 'Test Quiz 1'
      fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', with: 'Test Quiz 4'
      page.choose('new_choices_1_MultipleChoiceRadio_1_iscorrect_1')
      click_on 'Create Quiz'

      # Should have the error message Please make sure every question has text for all options
      expect(page).to have_content 'Please make sure every question has text for all options'
    end

    it 'should have error message if the correct answer(s) have not been provided' do
      login_as @student.name

      # Click on the assignment link, and navigate to work view
      click_link @assignment.name
      click_link 'Your work'

      # Create a quiz for the assignment without fill in every choices
      click_link 'Create a quiz'
      fill_in 'questionnaire_name', with: 'Quiz for test'
      fill_in 'text_area', with: 'Test Question 1'
      page.choose('question_type_1_type_multiplechoiceradio')

      # missing choice 2 and 3
      fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', with: 'Test Quiz 1'
      fill_in 'new_choices_1_MultipleChoiceRadio_2_txt', with: 'Test Quiz 2'
      fill_in 'new_choices_1_MultipleChoiceRadio_3_txt', with: 'Test Quiz 3'
      fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', with: 'Test Quiz 4'

      # Save without choosing the correct answer for the quiz
      click_on 'Create Quiz'

      # Should have the error message Please select a correct answer for all questions
      expect(page).to have_content 'Please select a correct answer for all questions'
    end
  end

  describe 'multiple quiz question test', js: true do


  before(:each) do
    # Create an instructor
    @instructor = User.find_by(name:'instructor6')
    # Create a student
    @student = User.find_by(name:'student4')
    # Create an assignment with quiz
    @assignment = Assignment.find_by(name:'quiz_test_assignment1')
    @student2 = User.find_by(name:'student5')

  end
    it 'number of questions set matches number of quiz questions avaliable' do
      # [S2] - When an assignment has a quiz there is an input field that accepts the number of questions that will be on each quiz. Setting this number appropriately changes the number of quiz questions.
      # Create a quiz
      login_as @student.name

      # Click on the assignment link, and navigate to work view
      click_link @assignment.name
      click_link 'Your work'

      # Click on create quiz link
      click_link 'Create a quiz'

      # Fill in the form for Name
      fill_in 'questionnaire_name', with: 'Quiz for test'

      # Fill in the form for Question 1
      expect(page).to have_content("Question 1")    # one shall be the number thou shalt count,
      expect(page).to have_no_content("Question 2")

    end
  end

  describe 'appropriate quiz taking times', js: true do
  before(:each) do
    @instructor = User.find_by(name:'instructor6')
    # Create a student
    @student = User.find_by(name:'student4')
    # Create an assignment with quiz
    @assignment = Assignment.find_by(name:'quiz_test_assignment2')
    @student2 = User.find_by(name:'student5')
    @team=Team.find_by(name:'quiz_team1_2')
    @participant=Participant.where(user_id:@student2.id,parent_id:@assignment.id).first
  end
    # [S3] - Students may not take quizzes on a phase that does not allow them to do so. When on a stage that does allow for quizzes, they may take quizzes on work that they have reviewed.
    it 'should not be able to take quiz before doing review' do
      login_as @student2.name

      # Click on the assignment link, and navigate to work view
      click_link @assignment.name
      expect(page).to have_content("Take quizzes")
      click_link "Take quizzes"

      # should not be able to see this option until after review has been done
      expect(page).to have_no_content("Request a new quiz to take")
      expect(page).to have_no_content("quiz_test2")
    end

    it 'should be able to take quiz after doing review' do
      create :review_response_map, assignment: @assignment, reviewee:@team, reviewer_id: @participant.id

      login_as @student2.name

      # Click on the assignment link, and navigate to work view
      click_link @assignment.name
      expect(page).to have_content("Take quizzes")

      click_link "Take quizzes"
      # do the review
      expect(page).to have_no_content("Request a new quiz to take")
      expect(page).to have_content("quiz_test2")

      ResponseMap.where(reviewed_object_id: @assignment.id).destroy_all
    end
  end

#Tests regarding the instructor's ability to interact with quizzes.
  describe 'Instructor', js: true do
    # Setup for testing by creating the following
    #   An instructor
    #   An assignment with a 1 question quiz and a valid deadline
    #   A student, with a valid team in the assignment, that has created a quiz
    #   A second student, also in the assignment, that has completed the quiz.
    before(:each) do
      # Create an instructor
      @instructor = User.find_by(name:'instructor6')
      # Create a student
      @student = User.find_by(name:'student4')
      # Create an assignment with quiz
      @assignment = Assignment.find_by(name:'quiz_test_assignment3')
      @student2 = User.find_by(name:'student5')
      @question=Question.find_by(txt: 'quiz_Question_3')
    end
    # Verify that an instructor can see all quiz questions,
    # answers, and scores on the review questions page.
    it 'can view quiz questions and scores' do
      # Login as instructor
      login_as @instructor.name

      # Go to view quizzes.
      visit "/student_quizzes/review_questions?id=#{@assignment.id}&type=Assignment"

      # Verify that the page lists the student and score
      student = all("tr > td")[0]
      score = all("tr > td")[1]

      expect(student).to have_text(@student2.fullname)
      expect(score).to have_text('100.0')

      # Verify that the page lists the average score for all students
      expect(page).to have_text('Average score for quiz takers: 100.0 ')

      # Verify that the question and answer choices are listed
      expect(page).to have_text(@question.txt)
      expect(page).to have_text("Question Type: MultipleChoiceRadio")
      expect(page).to have_text('Answer 1')
      expect(page).to have_text('Answer 2')
      expect(page).to have_text('Answer 3')
      expect(page).to have_text('Answer 4')

      # Verify that the selected answer is highlighted
      correct = find(".student_quizzes > b:nth-child(11)")
      expect(correct).to have_text('Answer 1')
    end
  end


  describe 'Student reviewers can take the quizzes', js: true do
    before(:each) do
        # Create a student
        @student = User.find_by(name:'student4')
        # Create an assignment with quiz
        @assignment = Assignment.find_by(name:'quiz_test_assignment2')
        @student2 = User.find_by(name:'student5')
        @team=Team.find_by(name:'quiz_team1_2')
        @participant=Participant.where(user_id:@student2.id,parent_id:@assignment.id).first
        @question=Question.find_by(txt: 'quiz_Question_2')
        @questionnaire=Questionnaire.find_by(name:'quiz_test2')
      end
    it 'can take quiz' do
      @response_map=create :review_response_map, assignment: @assignment, reviewee:@team, reviewer_id: @participant.id
      create :review_response_map, reviewed_object_id: @questionnaire.id, reviewee:@team, reviewer_id: @participant.id,type:'QuizResponseMap'

      # Login as student2
      login_as @student2.name

      # Click on the assignment link, and navigate to quizzes view
      click_link @assignment.name
      click_link 'Take quizzes'
      # Verify that there is a quiz can be taken
      expect(page).to have_link('Begin')

      # Click on the Begin link to start quiz
      click_link 'Begin'

      # Verify that the page list the quiz
      expect(page).to have_content('Questions')

      # choose an answer
      find(:css, "input[value='Answer 1']").click

      # Click Submit Quiz botton and navigate to score view
      click_on 'Submit Quiz'

      # Verify that Quiz score is shown on page
      expect(page).to have_content('Quiz score: 100.0%')
      Answer.where(question_id:@question.id).delete_all
      ResponseMap.where(reviewed_object_id: @assignment.id).delete_all
      ResponseMap.where(reviewed_object_id: @questionnaire.id).delete_all

    end
  end

  describe 'Student reviewers can view the quizzes they take', js: true do
    before(:each) do
      # Create an instructor
      # Create a student
      @student = User.find_by(name:'student4')
      # Create an assignment with quiz
      @assignment = Assignment.find_by(name:'quiz_test_assignment3')
      @student2 = User.find_by(name:'student5')
      @question=Question.find_by(txt: 'quiz_Question_3')
    end
  it 'can view quiz' do
    # Login as student2
    login_as @student2.name

    # Click on the assignment link, and navigate to quizzes view
    click_link @assignment.name
    click_link 'Take quizzes'

    # Verify that there is a quiz to view
    expect(page).to have_link('View')

    # Click on the View link, and navigate to quizzes view
    click_link 'View'

    # Verify that there is quiz score on the page
    expect(page).to have_content('Quiz score: 100.0%')
  end
end
