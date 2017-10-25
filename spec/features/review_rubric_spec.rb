include InstructorInterfaceHelperSpec

# Feature test of rubric advice
describe "Edit rubric advice" do
  before(:each) do
    assignment_setup
  end

  # Login test
  describe "Instructor login" do
    it "with valid username and password" do
      login_as("instructor6")
      visit '/tree_display/list'
      expect(page).to have_content("Manage content")
    end

    it "with invalid username and password" do
      visit root_path
      fill_in 'login_name', with: 'instructor6'
      fill_in 'login_password', with: 'wrongpassword'
      click_button 'SIGN IN'
      expect(page).to have_text('Your username or password is incorrect.')
    end
  end

  def load_questionnaire
    login_as("instructor6")
    visit '/questionnaires/new?model=ReviewQuestionnaire&private=0'
    fill_in('questionnaire_name', with: 'DummyReview')
    fill_in('questionnaire_min_question_score', with: '0')
    fill_in('questionnaire_max_question_score', with: '5')
    select('no', from: 'questionnaire_private')
    click_button "Create"
  end

  def load_question question_type
    load_questionnaire
    fill_in('question_total_num', with: '1')
    select(question_type, from: 'question_type')
    click_button "Add"
  end

  describe "Remove a rubric advice", :js => true do
    it "should be able to delete a rubric advice" do
      load_question 'Criterion'
      click_button "Edit/View advice"
      expect(page).to have_content('Edit an existing questionnaire')
      first(:css, "textarea[id^='horizontal_'][id$='advice']").set("Initial advice")
      click_button "Save and redisplay advice"
      expect(page).to have_content('advice was successfully saved')
      expect(page).to have_content('Initial advice')
      # edit review advice to set to blank
      first(:css, "textarea[id^='horizontal_'][id$='advice']").set("")
      click_button "Save and redisplay advice"
      expect(page).to have_content('advice was successfully saved')

    end
  end







end
