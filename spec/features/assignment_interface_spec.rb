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
end
