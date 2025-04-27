require_relative 'helpers/assignment_creation_helper'

# Begin rubric tab
describe 'Assignment creation rubrics tab', js: true do
  include AssignmentCreationHelper
  before(:each) do
    create_deadline_types
    @assignment = create(:assignment)
    create_list(:participant, 3)
    # Create an assignment due date
    create :assignment_due_date, due_at: (DateTime.now.in_time_zone - 1)
    @review_deadline_type = create(:deadline_type, name: 'review')
    create :assignment_due_date, due_at: (DateTime.now.in_time_zone + 1), deadline_type: @review_deadline_type
    create(:assignment_node)
    create(:question)
    create(:questionnaire)
    create(:assignment_questionnaire)
    (1..3).each do |i|
      create(:questionnaire, name: "ReviewQuestionnaire#{i}")
      create(:questionnaire, name: "AuthorFeedbackQuestionnaire#{i}", type: 'AuthorFeedbackQuestionnaire')
      create(:questionnaire, name: "TeammateReviewQuestionnaire#{i}", type: 'TeammateReviewQuestionnaire')
    end
    login_as('instructor6')
    visit "/assignments/#{@assignment.id}/edit"
    click_link 'Rubrics'
  end

  # First row of rubric
  describe 'Edit review rubric' do
    it 'updates review questionnaire' do
      within(:css, 'tr#questionnaire_table_ReviewQuestionnaire') do
        select 'ReviewQuestionnaire2', from: 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        uncheck('dropdown')
        select 'Scale', from: 'assignment_form[assignment_questionnaire][][dropdown]'
        fill_in 'assignment_form[assignment_questionnaire][][notification_limit]', with: '50'
      end
      click_button 'Save'
      sleep 1
      questionnaire = get_questionnaire('ReviewQuestionnaire2').first
      expect(questionnaire).to have_attributes(
        notification_limit: 50
      )
    end

    it 'should update scored question dropdown' do
      within('tr#questionnaire_table_ReviewQuestionnaire') do
        select 'ReviewQuestionnaire2', from: 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        select 'Scale', from: 'assignment_form[assignment_questionnaire][][dropdown]'
      end
      click_button 'Save'
      questionnaire = Questionnaire.where(name: 'ReviewQuestionnaire2').first
      assignment_questionnaire = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: questionnaire.id).first
      expect(assignment_questionnaire.dropdown).to eq(false)
    end

    # Second row of rubric
    it 'updates author feedback questionnaire' do
      within(:css, 'tr#questionnaire_table_AuthorFeedbackQuestionnaire') do
        select 'AuthorFeedbackQuestionnaire2', from: 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        uncheck('dropdown')
        select 'Scale', from: 'assignment_form[assignment_questionnaire][][dropdown]'
        fill_in 'assignment_form[assignment_questionnaire][][notification_limit]', with: '50'
      end
      click_button 'Save'
      questionnaire = get_questionnaire('AuthorFeedbackQuestionnaire2').first
      expect(questionnaire).to have_attributes(
        notification_limit: 50
      )
    end

    ##
    # Third row of rubric
    it 'updates teammate review questionnaire' do
      within('tr#questionnaire_table_TeammateReviewQuestionnaire') do
        select 'TeammateReviewQuestionnaire2', from: 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        uncheck('dropdown')
        select 'Scale', from: 'assignment_form[assignment_questionnaire][][dropdown]'
        fill_in 'assignment_form[assignment_questionnaire][][notification_limit]', with: '50'
      end
      click_button 'Save'
      questionnaire = get_questionnaire('TeammateReviewQuestionnaire2').first
      expect(questionnaire).to have_attributes(
        notification_limit: 50
      )
    end
  end
end
