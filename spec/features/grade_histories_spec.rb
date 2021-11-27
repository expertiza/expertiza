
include GradeHistoriesHelperSpec

describe "Feature Tests to check the grade audit trail: " do
  before(:each) do
    assignment_setup
    make_submission
  end

  describe 'The grade history' do
    it 'should be visible' do
      user = User.find_by(name: "instructor6")
      stub_current_user(user, user.role.name, user.role)
      visit '/assignments/list_submissions?id=1'
      click_link 'Assign Grade'
      fill_in "grade_for_submission", with: '80'
      fill_in "comment_for_submission", with: 'first comment'
      click_button 'Save'
      visit '/grading_histories?grade_receiver_id=1&grade_type=Submission'
      expect_page_content_to_have('first comment')
    end

    it 'should be shown in chronological order' do
      user = User.find_by(name: "instructor6")
      stub_current_user(user, user.role.name, user.role)
      visit '/assignments/list_submissions?id=1'
      click_link 'Assign Grade'
      fill_in "grade_for_submission", with: '80'
      fill_in "comment_for_submission", with: 'first comment'
      visit '/assignments/list_submissions?id=1'
      click_button 'Save'
      click_link 'Assign Grade'
      fill_in "grade_for_submission", with: '50'
      fill_in "comment_for_submission", with: 'second comment'
      click_button 'Save'
      visit '/grading_histories?grade_receiver_id=1&grade_type=Submission'
      table = page.all('table tr')
      expect(table[0]).to have_content?("second comment")
      expect(table[1]).to_have_content?("first comment")
    end

  end
end