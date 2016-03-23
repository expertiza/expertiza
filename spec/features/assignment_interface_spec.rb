require 'rails_helper'


describe "Integration tests for assignment interface" do

  before(:each) do
    @assignment = create(:assignment)
    create_list(:participant, 3)
    create(:assignment_node)
    create(:question)
    create(:questionnaire)
    create(:assignment_questionnaire)
    (1..3).each do |i|
      create(:questionnaire, name: "ReviewQuestionnaire#{i}")
      create(:author_feedback_questionnaire, name: "AuthorFeedbackQuestionnaire#{i}")
      create(:teammate_review_questionnaire, name: "TeammateReviewQuestionnaire#{i}")
    end
  end

  describe "Create assignments" do
    pubAssignment = nil; privAssignment = nil

    it "is able to create a public assignment" do
      login_as("instructor6")
      visit '/assignments/new?private=0'
      fill_in 'assignment_form_assignment_name', with: 'public assignment for test'
      select('5', :from => 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
      click_button 'Create'
      pubAssignment = Assignment.where(name: 'public assignment for test')
      expect(pubAssignment).to exist
    end

    it "is able to create a private assignment" do
      login_as("instructor6")
      visit '/assignments/new?private=1'
      fill_in 'assignment_form_assignment_name', with: 'private assignment for test'
      select('5', :from => 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
      click_button 'Create'
      privAssignment = Assignment.where(name: 'private assignment for test')
      expect(privAssignment).to exist
    end
  end

  describe "Edit assignments" do
    it "is able to edit assignment" do
      login_as("instructor6")
      visit '/assignments/1/edit'
      expect(page).to have_content("Editing Assignment:")
    end
  end

  describe "Edit rubric" do
    it "is able to edit assignment" do
      login_as("instructor6")
      visit '/assignments/1/edit#tabs-3'

      expect(page).to have_content("Review rubric varies by round?")
      # expect
    end
  end

  describe "Edit Topics" do
    it "is able to see edit topics content correctly" do
      login_as("instructor6")
      visit 'assignments/1/edit#tab-2'
      expect(page).to have_content("Allow topic suggestions from students?")
      expect(page).to have_content("Enable bidding for topics?")
      expect(page).to have_content("Enable authors to review others working on same topic?")
      expect(page).to have_content("Allow reviewer to choose which topic to review?")
      expect(page).to have_content("Allow participants to create bookmarks? ")
      expect(page).to have_content("Hide all teams")
      expect(page).to have_content("New topic")
      expect(page).to have_content("Import Topics")
      expect(page).to have_content("Back")
      expect(page).to have_content("Save")
    end

    it "is able to select checkboxes" do
      login_as("instructor6")
      visit 'assignments/1/edit#tab-2'

      check('assignment_form_assignment_allow_suggestions')
      check('assignment_form_assignment_is_intelligent')
      check('assignment_form_assignment_can_review_same_topic')
      check('assignment_form_assignment_can_choose_topic_to_review')
      check('assignment_form_assignment_use_bookmark')

      expect('assignment_form_assignment_allow_suggestions').to  be_checked
      expect('assignment_form_assignment_is_intelligent').to  be_checked
      expect('assignment_form_assignment_can_review_same_topic').to  be_checked
      expect('assignment_form_assignment_can_choose_topic_to_review').to  be_checked
      expect('assignment_form_assignment_use_bookmark').to  be_checked

      # click_button("Save")

      # pubAssignment = Assignment.find_by_id(1)
      # expect(pubAssignment).to exist
      # expect(pubAssignment).to have_content()
    end

    it "is able to unselect boxes" do
      login_as("instructor6")
      visit 'assignments/1/edit#tab-2'
      uncheck('assignment_form_assignment_allow_suggestions')
      uncheck('assignment_form_assignment_is_intelligent')
      uncheck('assignment_form_assignment_can_review_same_topic')
      uncheck('assignment_form_assignment_can_choose_topic_to_review')
      uncheck('assignment_form_assignment_use_bookmark')

      expect('assignment_form_assignment_allow_suggestions').to  be_unchecked
      expect('assignment_form_assignment_is_intelligent').to  be_unchecked
      expect('assignment_form_assignment_can_review_same_topic').to  be_unchecked
      expect('assignment_form_assignment_can_choose_topic_to_review').to  be_unchecked
      expect('assignment_form_assignment_use_bookmark').to  be_unchecked
    end

    it "is able to show/hide teams" do
      login_as("instructor6")
      visit 'assignments/1/edit#tab-2'

      click_link('Hide all teams')

      expect(page).to have_content("Show all teams")

      click_link("Show all teams")
      expect(page).to have_content("Hide all teams")
    end

    it "should be able to redirect to create new topic" do
      login_as("instructor6")
      visit 'assignments/1/edit#tab-2'

      click_link('New topic')

      expect(page).to have_content('You are adding a topic to this assignment. Students will now have to select a topic before they submit their work.')

      click_button('OK')
      expect(page).to have_content('New topic')
    end

    it "should be able to Import topics" do
      login_as("instructor6")
      visit 'assignments/1/edit#tab-2'

      click_link('Import topics')

      expect(page).to have_content('You are adding topics to this assignment. Students will now have to select a topic before they submit their work.')

      click_button('OK')
      expect(page).to have_content('Import')
    end
  end

 #RUBRIC
  #Load edit page
  describe "Load rubric questionnaire" do
    it "is able to edit assignment" do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      #might find a better acceptance criteria here
      expect(page).to have_content("Review rubric varies by round")
    end
  end

  #First table row
  describe "Edit review rubric" do
    it "should update questionnaire", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_ReviewQuestionnaire") do
        select "ReviewQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
      end
      click_button 'Save'
      expect(get_questionnaire("ReviewQuestionnaire2")).to exist
    end
    it "should update use dropdown", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_ReviewQuestionnaire") do
        select "ReviewQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        uncheck('dropdown')
      end
      click_button 'Save'
      pending("can't find where this value is used")
      expect(get_questionnaire("ReviewQuestionnaire2").first).to have_attributes(:dropdown => false)
    end
    it "should update scored question dropdown", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_ReviewQuestionnaire") do
        select "ReviewQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        select "Scale", :from => 'assignment_form[assignment_questionnaire][][dropdown]'
      end
      click_button 'Save'
      pending("can't find where this value is used")
      expect(get_questionnaire("ReviewQuestionnaire2").first).to have_attributes(:scored_question_display_type => false)
    end
    it "should update weight", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_ReviewQuestionnaire") do
        select "ReviewQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        fill_in 'assignment_form[assignment_questionnaire][][questionnaire_weight]', :with => '50'
      end
      click_button 'Save'
      expect(get_questionnaire).to have_attributes(:questionnaire_weight => 50)
    end
    it "should update notification limit", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_ReviewQuestionnaire") do
        select "ReviewQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        fill_in 'assignment_form[assignment_questionnaire][][notification_limit]', :with => '50'
      end
      click_button 'Save'
      expect(get_questionnaire("ReviewQuestionnaire2").first).to have_attributes(:notification_limit => 50)
    end
  end

  describe "Edit author feedback in rubric" do
    it "should update questionnaire", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_AuthorFeedbackQuestionnaire") do
        select "AuthorFeedbackQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
      end
      click_button 'Save'
      expect(get_questionnaire "AuthorFeedbackQuestionnaire2").to exist
    end
    it "should update use dropdown", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_AuthorFeedbackQuestionnaire") do
        select "AuthorFeedbackQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        uncheck('dropdown')
      end
      click_button 'Save'
      pending("can't find where this value is used")
      expect(get_questionnaire("AuthorFeedbackQuestionnaire2").first).to have_attributes(:dropdown => false)
    end
    it "should update scored question dropdown", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_AuthorFeedbackQuestionnaire") do
        select "AuthorFeedbackQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        select "Scale", :from => 'assignment_form[assignment_questionnaire][][dropdown]'
      end
      click_button 'Save'
      pending("can't find where this value is used")
      expect(get_questionnaire("AuthorFeedbackQuestionnaire2").first).to have_attributes(:scored_question_display_type => false)
    end
    it "should update weight", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_AuthorFeedbackQuestionnaire") do
        select "AuthorFeedbackQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        fill_in 'assignment_form[assignment_questionnaire][][questionnaire_weight]', :with => '50'
      end
      click_button 'Save'
      expect(get_questionnaire("AuthorFeedbackQuestionnaire2").first).to have_attributes(:questionnaire_weight => 50)
    end
    it "should update notification limit", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_AuthorFeedbackQuestionnaire") do
        select "AuthorFeedbackQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        fill_in 'assignment_form[assignment_questionnaire][][notification_limit]', :with => '50'
      end
      click_button 'Save'
      expect(get_questionnaire("AuthorFeedbackQuestionnaire2").first).to have_attributes(:notification_limit => 50)
    end
  end

    #TeammateReviewQuestionnaire
    describe "Edit teammate review in rubric" do
    it "should update questionnaire", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_TeammateReviewQuestionnaire") do
        select "TeammateReviewQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
      end
      click_button 'Save'
      expect(get_questionnaire("TeammateReviewQuestionnaire2")).to exist
    end
    it "should update use dropdown", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_TeammateReviewQuestionnaire") do
        select "TeammateReviewQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        uncheck('dropdown')
      end
      click_button 'Save'
      pending("can't find where this value is used")
      expect(get_questionnaire("TeammateReviewQuestionnaire2").first).to have_attributes(:dropdown => false)
    end
    it "should update scored question dropdown", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_TeammateReviewQuestionnaire") do
        select "TeammateReviewQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        select "Scale", :from => 'assignment_form[assignment_questionnaire][][dropdown]'
      end
      click_button 'Save'
      pending("can't find where this value is used")
      expect(get_questionnaire("TeammateReviewQuestionnaire2").first).to have_attributes(:scored_question_display_type => false)
    end
    it "should update weight", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_TeammateReviewQuestionnaire") do
        select "TeammateReviewQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        fill_in 'assignment_form[assignment_questionnaire][][questionnaire_weight]', :with => '50'
      end
      click_button 'Save'
      expect(get_questionnaire("TeammateReviewQuestionnaire2").first).to have_attributes(:questionnaire_weight => 50)
    end
    it "should update notification limit", js: true do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('Rubrics').click
      within("tr#questionnaire_table_TeammateReviewQuestionnaire") do
        select "TeammateReviewQuestionnaire2", :from => 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        fill_in 'assignment_form[assignment_questionnaire][][notification_limit]', :with => '50'
      end
      click_button 'Save'
      expect(get_questionnaire("TeammateReviewQuestionnaire2").first).to have_attributes(:notification_limit => 50)
    end

  end

end
