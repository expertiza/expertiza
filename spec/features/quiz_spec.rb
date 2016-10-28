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

    fill_in 'quiz_question_choices_1_MultipleChoiceRadio_1_txt', with: 'Test Quiz 1 Edit'

    # Save the edit choice
    click_on 'Save quiz'

    # View the quiz we just edited
    click_on 'View quiz'

    # Verify that the edit choice has been saved
    expect(page).to have_content('Test Quiz 1 Edit')
  end

  it 'should have error message if the name of the quiz is missing' do
    login_as @student.name
