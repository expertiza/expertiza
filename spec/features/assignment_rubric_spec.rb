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