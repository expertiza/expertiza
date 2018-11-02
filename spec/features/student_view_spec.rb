require 'rspec'

describe 'My behaviour' do
  it "can display relevant menu items after login as an admin/instructor/TA", js: true do
    create(:instructor)
    login_as 'instructor6'
    visit '/tree_display/list'
    expect(page).to have_current_path('/tree_display/list')
    expect(page).to have_content('Open Student View')
    click_button "Manage..."
    expect(page).to have_content('Student View')
  end

  it "can display relevant menu items when in student view", js: true do
    create(:instructor)
    login_as 'instructor6'
    visit '/tree_display/list'
    click_link 'Open Student View'
    expect(page).to have_current_path('/student_task/list')
    expect(page).to have_content('Assignments')
    expect(page).to have_content('Close Student View')
  end
end
