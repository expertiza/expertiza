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
    create(:item)
    create(:itemnaire)
    create(:assignment_itemnaire)
    (1..3).each do |i|
      create(:itemnaire, name: "ReviewQuestionnaire#{i}")
      create(:itemnaire, name: "AuthorFeedbackQuestionnaire#{i}", type: 'AuthorFeedbackQuestionnaire')
      create(:itemnaire, name: "TeammateReviewQuestionnaire#{i}", type: 'TeammateReviewQuestionnaire')
    end
    login_as('instructor6')
    visit "/assignments/#{@assignment.id}/edit"
    click_link 'Rubrics'
  end

  # First row of rubric
  describe 'Edit review rubric' do
    it 'updates review itemnaire' do
      within(:css, 'tr#itemnaire_table_ReviewQuestionnaire') do
        select 'ReviewQuestionnaire2', from: 'assignment_form[assignment_itemnaire][][itemnaire_id]'
        uncheck('dropdown')
        select 'Scale', from: 'assignment_form[assignment_itemnaire][][dropdown]'
        fill_in 'assignment_form[assignment_itemnaire][][notification_limit]', with: '50'
      end
      click_button 'Save'
      sleep 1
      itemnaire = get_itemnaire('ReviewQuestionnaire2').first
      expect(itemnaire).to have_attributes(
        notification_limit: 50
      )
    end

    it 'should update scored item dropdown' do
      within('tr#itemnaire_table_ReviewQuestionnaire') do
        select 'ReviewQuestionnaire2', from: 'assignment_form[assignment_itemnaire][][itemnaire_id]'
        select 'Scale', from: 'assignment_form[assignment_itemnaire][][dropdown]'
      end
      click_button 'Save'
      itemnaire = Questionnaire.where(name: 'ReviewQuestionnaire2').first
      assignment_itemnaire = AssignmentQuestionnaire.where(assignment_id: @assignment.id, itemnaire_id: itemnaire.id).first
      expect(assignment_itemnaire.dropdown).to eq(false)
    end

    # Second row of rubric
    it 'updates author feedback itemnaire' do
      within(:css, 'tr#itemnaire_table_AuthorFeedbackQuestionnaire') do
        select 'AuthorFeedbackQuestionnaire2', from: 'assignment_form[assignment_itemnaire][][itemnaire_id]'
        uncheck('dropdown')
        select 'Scale', from: 'assignment_form[assignment_itemnaire][][dropdown]'
        fill_in 'assignment_form[assignment_itemnaire][][notification_limit]', with: '50'
      end
      click_button 'Save'
      itemnaire = get_itemnaire('AuthorFeedbackQuestionnaire2').first
      expect(itemnaire).to have_attributes(
        notification_limit: 50
      )
    end

    ##
    # Third row of rubric
    it 'updates teammate review itemnaire' do
      within('tr#itemnaire_table_TeammateReviewQuestionnaire') do
        select 'TeammateReviewQuestionnaire2', from: 'assignment_form[assignment_itemnaire][][itemnaire_id]'
        uncheck('dropdown')
        select 'Scale', from: 'assignment_form[assignment_itemnaire][][dropdown]'
        fill_in 'assignment_form[assignment_itemnaire][][notification_limit]', with: '50'
      end
      click_button 'Save'
      itemnaire = get_itemnaire('TeammateReviewQuestionnaire2').first
      expect(itemnaire).to have_attributes(
        notification_limit: 50
      )
    end
  end
end
