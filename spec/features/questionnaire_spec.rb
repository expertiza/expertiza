require 'rails_helper'

describe "Questionnaire tests for instructor interface" do
  before(:each) do
    create(:assignment)
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
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone + 1.day)
  end

  describe "Instructor login" do
    it "with valid username and password" do
      login_as("instructor6")
      visit '/tree_display/list'
      expect(page).to have_content("Manage content")
    end

    it "with invalid username and password" do
      visit root_path
      fill_in 'login_name', with: 'instructor6'
      fill_in 'login_password', with: 'something'
      click_button 'SIGN IN'
      expect(page).to have_text('Incorrect password')
    end
  end

  describe "Create a public review questionnaire" do
    it "is able to create a public review questionnaire" do
      login_as("instructor6")

      visit '/questionnaires/new?model=ReviewQuestionnaire&private=0'

      fill_in('questionnaire_name', with: 'Review 1')

      fill_in('questionnaire_min_question_score', with: '0')

      fill_in('questionnaire_max_question_score', with: '5')

      select('no', from: 'questionnaire_private')

      click_button "Create"

      expect(Questionnaire.where(name: "Review 1")).to exist
    end
  end

  describe "Create a private review questionnaire" do
    it "is able to create a private review questionnaire" do
      login_as("instructor6")

      visit '/questionnaires/new?model=ReviewQuestionnaire&private=1'

      fill_in('questionnaire_name', with: 'Review 1')

      fill_in('questionnaire_min_question_score', with: '0')

      fill_in('questionnaire_max_question_score', with: '5')

      select('yes', from: 'questionnaire_private')

      click_button "Create"

      expect(Questionnaire.where(name: "Review 1")).to exist
    end
  end

  def load_questionnaire
    login_as("instructor6")
    visit '/questionnaires/new?model=ReviewQuestionnaire&private=0'

    fill_in('questionnaire_name', with: 'Review n')

    fill_in('questionnaire_min_question_score', with: '0')

    fill_in('questionnaire_max_question_score', with: '5')

    select('no', from: 'questionnaire_private')

    click_button "Create"
  end

  def load_question (question_type, verify_button)
    load_questionnaire
    fill_in('question_total_num', with: '1')
    select(question_type, from: 'question_type')
    click_button "Add"

    if verify_button
      expect(page).to have_content('Remove')
    end

    click_button "Save review questionnaire"

    if verify_button
      expect(page).to have_content('All questions has been successfully saved!')
    end

  end

  describe "Create a review question" do
    it "is able to create a Criterion question" do
      load_question 'Criterion', true
    end

    it "is able to create a Scale question" do
      load_question 'Scale', true
    end

    it "is able to create a Dropdown question" do
      load_question 'Dropdown', true
    end

    it "is able to create a Checkbox question" do
      load_question 'Checkbox', true
    end

    it "is able to create a TextArea question" do
      load_question 'TextArea', true
    end

    it "is able to create a TextField question" do
      load_question 'TextField', true
    end

    it "is able to create a UploadFile question" do
      load_question 'UploadFile', true
    end

    it "is able to create a SectionHeader question" do
      load_question 'SectionHeader', true
    end

    it "is able to create a TableHeader question" do
      load_question 'TableHeader', true
    end

    it "is able to create a ColumnHeader question" do
      load_question 'ColumnHeader', true
    end
  end

  describe "Edit a question" do
    it "is able to edit Criterion question" do
      load_question 'Criterion', false
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions has been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit Scale question" do
      load_question 'Scale', false
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions has been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit Dropdown question" do
      load_question 'Dropdown', false
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions has been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit Checkbox question" do
      load_question 'Checkbox', false
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions has been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit TextArea question" do
      load_question 'TextArea', false
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions has been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit TextField question" do
      load_question 'TextField', false
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions has been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit UploadFile question" do
      load_question 'UploadFile', false
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions has been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit SectionHeader question" do
      load_question 'SectionHeader', false
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions has been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit TableHeader question" do
      load_question 'TableHeader', false
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions has been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit ColumnHeader question" do
      load_question 'ColumnHeader', false
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions has been successfully saved!')
      expect(page).to have_content('Question edit')
    end
  end

  describe "Delete a question" do
    it "is able to delete a Criterion question" do
      load_question 'Criterion', false

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a Scale question" do
      load_question 'Scale', false

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a Dropdown question" do
      load_question 'Dropdown', false

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a Checkbox question" do
      load_question 'Checkbox', false

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a TextArea question" do
      load_question 'TextArea', false

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a TextField question" do
      load_question 'TextField', false

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a UploadFile question" do
      load_question 'UploadFile', false

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a SectionHeader question" do
      load_question 'SectionHeader', false

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a TableHeader question" do
      load_question 'TableHeader', false

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a ColumnHeader question" do
      load_question 'ColumnHeader', false

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end
  end

  describe "Create a review advice" do
    it "is able to create a public review advice" do
      load_question 'Criterion', false
      click_button "Edit/View advice"
      expect(page).to have_content('Edit an existing questionnaire')

      first(:css, "textarea[id^='horizontal_'][id$='advice']").set("Advice 1")
      click_button "Save and redisplay advice"
      expect(page).to have_content('advice was successfully saved')
      expect(page).to have_content('Advice 1')
    end
  end

  describe "Edit a review advice" do
    it "is able to edit a public review advice" do
      load_question 'Criterion', false
      click_button "Edit/View advice"
      expect(page).to have_content('Edit an existing questionnaire')

      first(:css, "textarea[id^='horizontal_'][id$='advice']").set("Advice 1")
      click_button "Save and redisplay advice"
      expect(page).to have_content('advice was successfully saved')
      expect(page).to have_content('Advice 1')

      first(:css, "textarea[id^='horizontal_'][id$='advice']").set("Advice edit")
      click_button "Save and redisplay advice"
      expect(page).to have_content('advice was successfully saved')
      expect(page).to have_content('Advice edit')
    end
  end
end
