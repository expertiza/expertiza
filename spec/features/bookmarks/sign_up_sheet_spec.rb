describe 'sign_up_sheet/list.html.erb' do
  def create_assignment_bookmarks
    create(:assignment, name: 'TestAssignment', directory_path: 'TestAssignment', use_bookmark: true)
    create_list(:participant, 3)
    create(:topic)
    create(:bookmark)
  end

  def create_assignment_no_bookmarks
    create(:assignment, name: 'TestAssignment', directory_path: 'TestAssignment', use_bookmark: false)
    create_list(:participant, 3)
    create(:topic)
  end

  def view_sign_up_sheet
    login_as('student2064')
    expect(page).to have_content 'User: student2064'
    expect(page).to have_content 'TestAssignment'
    click_link 'TestAssignment'
    expect(page).to have_content 'Signup sheet'
    click_link 'Signup sheet'
  end

  context 'when bookmarks are enabled' do
    it 'should display bookmark links' do
      create_assignment_bookmarks
      view_sign_up_sheet
      expect(page).to_not have_content 'Bookmarks (disabled)'
    end
  end

  context 'when bookmarks are disabled' do
    it 'should not display bookmark links' do
      create_assignment_no_bookmarks
      view_sign_up_sheet
      expect(page).to have_content 'Bookmarks (disabled)'
    end
  end
end
