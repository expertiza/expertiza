include InstructorInterfaceHelperSpec

# Feature test of rubric advice
describe "Edit rubric advice" do
  before(:each) do
    # assignment_setup
    create(:assignment, name: "TestAssignment", directory_path: 'test_assignment')
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
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone + 1.day)
    create(:topic)
    create(:topic, topic_name: "TestReview")
    create(:team_user, user: User.where(role_id: 2).first)
    create(:team_user, user: User.where(role_id: 2).second)
    create(:assignment_team)
    create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.second)
    create(:signed_up_team)
    create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
    create(:assignment_questionnaire)
    create(:question)
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

  def load_questionnaire_public
    login_as("instructor6")
    visit '/questionnaires/new?model=ReviewQuestionnaire&private=0'
    fill_in('questionnaire_name', with: 'DummyReview')
    fill_in('questionnaire_min_question_score', with: '0')
    fill_in('questionnaire_max_question_score', with: '5')
    select('no', from: 'questionnaire_private')
    click_button "Create"
  end

  def load_questionnaire_private
    login_as("instructor6")
    visit '/questionnaires/new?model=ReviewQuestionnaire&private=0'
    fill_in('questionnaire_name', with: 'DummyReview')
    fill_in('questionnaire_min_question_score', with: '0')
    fill_in('questionnaire_max_question_score', with: '5')
    select('yes', from: 'questionnaire_private')
    click_button "Create"
  end

  def load_question_public question_type
    load_questionnaire_public
    fill_in('question_total_num', with: '1')
    select(question_type, from: 'question_type')
    click_button "Add"
  end

  def load_question_private question_type
    load_questionnaire_private
    fill_in('question_total_num', with: '1')
    select(question_type, from: 'question_type')
    click_button "Add"
  end

  describe "Edit a rubric advice" do
    it "is able to edit a public review advice" do
      # creating a new rubric advice
      load_question 'Criterion'
      click_button "Edit/View advice"
      expect(page).to have_content('Edit an existing questionnaire')
      # Setting intital advice in the field
      first(:css, "textarea[id^='horizontal_'][id$='advice']").set("Initial advice")
      click_button "Save and redisplay advice"
      expect(page).to have_content('advice was successfully saved')
      expect(page).to have_content('Initial advice')
      # Editing a review rubric - Setting any element with new data
      first(:css, "textarea[id^='horizontal_'][id$='advice']").set("Edited the advice")
      click_button "Save and redisplay advice"
      expect(page).to have_content('advice was successfully saved')
      expect(page).to have_content('Edited the advice')
    end
  end

  describe "Remove a rubric advice" do
    it "should be able to delete a rubric advice" do
      load_question 'Criterion'
      click_button "Edit/View advice"
      expect(page).to have_content('Edit an existing questionnaire')
      first(:css, "textarea[id^='horizontal_'][id$='advice']").set("Initial advice")
      click_button "Save and redisplay advice"
      expect(page).to have_content('advice was successfully saved')
      expect(page).to have_content('Initial advice')
      # edit review advice to set to blank i.e. delete rubric advice
      first(:css, "textarea[id^='horizontal_'][id$='advice']").set("")
      click_button "Save and redisplay advice"
      expect(page).to have_content('advice was successfully saved')
    end
  end

end
