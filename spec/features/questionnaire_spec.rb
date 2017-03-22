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

  def make_questionnaire private
    login_as("instructor6")

    visit '/questionnaires/new?model=ReviewQuestionnaire&private=' + private ? '1' : '0'

    fill_in('questionnaire_name', with: 'Review 1')

    fill_in('questionnaire_min_question_score', with: '0')

    fill_in('questionnaire_max_question_score', with: '5')

    select(private ? 'yes' : 'no', from: 'questionnaire_private')

    click_button "Create"

    expect(Questionnaire.where(name: "Review 1")).to exist
  end

  describe "Create a public review questionnaire" do
    it "is able to create a public review questionnaire" do
      make_questionnaire false
    end
  end

  describe "Create a private review questionnaire" do
    it "is able to create a private review questionnaire" do
      make_questionnaire true
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

  def load_question question_type, verify_button
    load_questionnaire
    fill_in('question_total_num', with: '1')
    select(question_type, from: 'question_type')
    click_button "Add"

    expect(page).to have_content('Remove') if verify_button

    click_button "Save review questionnaire"

    expect(page).to have_content('All questions has been successfully saved!') if verify_button
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

  def edit_created_question
    first("textarea[placeholder='Edit question content here']").set "Question edit"
    click_button "Save review questionnaire"
    expect(page).to have_content('All questions has been successfully saved!')
    expect(page).to have_content('Question edit')
  end

  def check_deleted_question
    click_on('Remove')
    expect(page).to have_content('You have successfully deleted the question!')
  end

  def choose_check_type command_type
    if command_type == 'edit'
      edit_created_question
    else
      check_deleted_question
    end
  end

  describe "Edit a question" do
    it "is able to edit Criterion question" do
      load_question 'Criterion', false
      choose_check_type 'edit'
    end

    it "is able to edit Scale question" do
      load_question 'Scale', false
      choose_check_type 'edit'
    end

    it "is able to edit Dropdown question" do
      load_question 'Dropdown', false
      choose_check_type 'edit'
    end

    it "is able to edit Checkbox question" do
      load_question 'Checkbox', false
      choose_check_type 'edit'
    end

    it "is able to edit TextArea question" do
      load_question 'TextArea', false
      choose_check_type 'edit'
    end

    it "is able to edit TextField question" do
      load_question 'TextField', false
      choose_check_type 'edit'
    end

    it "is able to edit UploadFile question" do
      load_question 'UploadFile', false
      choose_check_type 'edit'
    end

    it "is able to edit SectionHeader question" do
      load_question 'SectionHeader', false
      choose_check_type 'edit'
    end

    it "is able to edit TableHeader question" do
      load_question 'TableHeader', false
      choose_check_type 'edit'
    end

    it "is able to edit ColumnHeader question" do
      load_question 'ColumnHeader', false
      choose_check_type 'edit'
    end
  end

  describe "Delete a question" do
    it "is able to delete Criterion question" do
      load_question 'Criterion', false
      choose_check_type 'delete'
    end

    it "is able to delete Scale question" do
      load_question 'Scale', false
      choose_check_type 'delete'
    end

    it "is able to delete Dropdown question" do
      load_question 'Dropdown', false
      choose_check_type 'delete'
    end

    it "is able to delete Checkbox question" do
      load_question 'Checkbox', false
      choose_check_type 'delete'
    end

    it "is able to delete TextArea question" do
      load_question 'TextArea', false
      choose_check_type 'delete'
    end

    it "is able to delete TextField question" do
      load_question 'TextField', false
      choose_check_type 'delete'
    end

    it "is able to delete UploadFile question" do
      load_question 'UploadFile', false
      choose_check_type 'delete'
    end

    it "is able to delete SectionHeader question" do
      load_question 'SectionHeader', false
      choose_check_type 'delete'
    end

    it "is able to delete TableHeader question" do
      load_question 'TableHeader', false
      choose_check_type 'delete'
    end

    it "is able to delete ColumnHeader question" do
      load_question 'ColumnHeader', false
      choose_check_type 'delete'
    end
  end

  def load_and_edit_check
    load_question 'Criterion', false
    click_button "Edit/View advice"
    expect(page).to have_content('Edit an existing questionnaire')
  end

  def edit_and_save_check
    first(:css, "textarea[id^='horizontal_'][id$='advice']").set("Advice 1")
    click_button "Save and redisplay advice"
    expect(page).to have_content('advice was successfully saved')
    expect(page).to have_content('Advice 1')
  end

  def create_review_advice
    load_and_edit_check
    edit_and_save_check
  end

  describe "Create a review advice" do
    it "is able to create a public review advice" do
      create_review_advice
    end
  end

  describe "Edit a review advice" do
    it "is able to edit a public review advice" do
      create_review_advice

      first(:css, "textarea[id^='horizontal_'][id$='advice']").set("Advice edit")
      click_button "Save and redisplay advice"
      expect(page).to have_content('advice was successfully saved')
      expect(page).to have_content('Advice edit')
    end
  end
end
