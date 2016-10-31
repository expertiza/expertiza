require 'rails_helper'


describe "Questionnaire tests for instructor interface" do
  before(:each) do
    create(:assignment)
    create_list(:participant, 3)
    create(:questionnaire)
    create(:assignment_node)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    @create = create(:deadline_type, name: "metareview")
    @create
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100 * 24 * 60 * 60))
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
      expect(page).to have_content('Your username or password is incorrect.')
    end
  end

  describe "Create a public review questionnaire", type: :controller do
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

  describe "Create a private review questionnaire", type: :controller do
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

  describe "Create a review question", type: :controller do
    it "is able to create a Criterion question" do
      load_questionnaire
      fill_in('question_total_num', with: '1')
      select('Criterion', from: 'question_type')
      click_button "Add"
      expect(page).to have_content('Remove')

      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
    end

    it "is able to create a Scale question" do
      load_questionnaire
      fill_in('question_total_num', with: '1')
      select('Scale', from: 'question_type')
      click_button "Add"
      expect(page).to have_content('Remove')

      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
    end

    it "is able to create a Dropdown question" do
      load_questionnaire
      fill_in('question_total_num', with: '1')
      select('Dropdown', from: 'question_type')
      click_button "Add"
      expect(page).to have_content('Remove')

      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
    end

    it "is able to create a Checkbox question" do
      load_questionnaire
      fill_in('question_total_num', with: '1')
      select('Checkbox', from: 'question_type')
      click_button "Add"
      expect(page).to have_content('Remove')

      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
    end

    it "is able to create a TextArea question" do
      load_questionnaire
      fill_in('question_total_num', with: '1')
      select('TextArea', from: 'question_type')
      click_button "Add"
      expect(page).to have_content('Remove')

      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
    end

    it "is able to create a TextField question" do
      load_questionnaire
      fill_in('question_total_num', with: '1')
      select('TextField', from: 'question_type')
      click_button "Add"
      expect(page).to have_content('Remove')

      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
    end

    it "is able to create a UploadFile question" do
      load_questionnaire
      fill_in('question_total_num', with: '1')
      select('UploadFile', from: 'question_type')
      click_button "Add"
      expect(page).to have_content('Remove')

      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
    end

    it "is able to create a SectionHeader question" do
      load_questionnaire
      fill_in('question_total_num', with: '1')
      select('SectionHeader', from: 'question_type')
      click_button "Add"
      expect(page).to have_content('Remove')

      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
    end

    it "is able to create a TableHeader question" do
      load_questionnaire
      fill_in('question_total_num', with: '1')
      select('TableHeader', from: 'question_type')
      click_button "Add"
      expect(page).to have_content('Remove')

      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
    end

    it "is able to create a ColumnHeader question" do
      load_questionnaire
      fill_in('question_total_num', with: '1')
      select('ColumnHeader', from: 'question_type')
      click_button "Add"
      expect(page).to have_content('Remove')

      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
    end
  end

  def load_question question_type
    load_questionnaire
    fill_in('question_total_num', with: '1')
    select(question_type, from: 'question_type')
    click_button "Add"
    click_button "Save review questionnaire"
  end

  describe "Edit a question", type: :controller do
    it "is able to edit Criterion question" do
      load_question 'Criterion'
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit Scale question" do
      load_question 'Scale'
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit Dropdown question" do
      load_question 'Dropdown'
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit Checkbox question" do
      load_question 'Checkbox'
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit TextArea question" do
      load_question 'TextArea'
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit TextField question" do
      load_question 'TextField'
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit UploadFile question" do
      load_question 'UploadFile'
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit SectionHeader question" do
      load_question 'SectionHeader'
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit TableHeader question" do
      load_question 'TableHeader'
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
      expect(page).to have_content('Question edit')
    end

    it "is able to edit ColumnHeader question" do
      load_question 'ColumnHeader'
      first("textarea[placeholder='Edit question content here']").set "Question edit"
      click_button "Save review questionnaire"
      expect(page).to have_content('All questions have been successfully saved!')
      expect(page).to have_content('Question edit')
    end
  end

  describe "Delete a question", type: :controller do
    it "is able to delete a Criterion question" do
      load_question 'Criterion'

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a Scale question" do
      load_question 'Scale'

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a Dropdown question" do
      load_question 'Dropdown'

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a Checkbox question" do
      load_question 'Checkbox'

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a TextArea question" do
      load_question 'TextArea'

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a TextField question" do
      load_question 'TextField'

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a UploadFile question" do
      load_question 'UploadFile'

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a SectionHeader question" do
      load_question 'SectionHeader'

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a TableHeader question" do
      load_question 'TableHeader'

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end

    it "is able to delete a ColumnHeader question" do
      load_question 'ColumnHeader'

      click_on('Remove')
      expect(page).to have_content('You have successfully deleted the question!')
    end
  end

  describe "Create a review advice", type: :controller do
    it "is able to create a public review advice" do
      load_question 'Criterion'
      click_button "Edit/View advice"
      expect(page).to have_content('Edit an existing questionnaire')

      first(:css, "textarea[id^='horizontal_'][id$='advice']").set("Advice 1")
      click_button "Save and redisplay advice"
      expect(page).to have_content('advice was successfully saved')
      expect(page).to have_content('Advice 1')
    end
  end

  describe "Edit a review advice", type: :controller do
    it "is able to edit a public review advice" do
      load_question 'Criterion'
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

  describe 'Import questions from CSV' do

    it 'should not be an empty file', js: true do
      login_as("instructor6")
      visit '/questionnaires/1/edit'
      file_path=Rails.root+"spec/features/import_export_csv_oss/navjot.csv"
      attach_file('csv',file_path)
      click_button "Import from CSV"
      expect(page).not_to have_content('No such file')
    end



  it 'should be a valid CSV file', js: true do
    login_as("instructor6")
    visit '/questionnaires/1/edit'
    file_path=Rails.root+"spec/features/import_export_csv_oss/navjot.csv"
    attach_file('csv',file_path)
    click_button "Import from CSV"
    expect(page).to have_content('All questions have been successfully imported!')

end


    it 'should have valid column names', js: true do
      login_as("instructor6")
      visit '/questionnaires/1/edit'
      file_path=Rails.root+"spec/features/import_export_csv_oss/navjot (propername).csv"
      attach_file('csv',file_path)
      click_button "Import from CSV"
      expect(page).to have_content('unknown attribute')
    end

  end


end
