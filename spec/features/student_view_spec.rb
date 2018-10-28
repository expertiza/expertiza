require 'rspec'

describe 'My behaviour' do


  it " can display relevant menu items after login as an admin/instructor/TA", js: true do
    create(:instructor)
    login_as 'instructor6'
    visit '/tree_display/list'
    expect(page).to have_current_path('/tree_display/list')
    expect(page).to have_content('Manage content')
    expect(page).to have_content('Survey Deployments')
    expect(page).not_to have_content('Assignments')
    expect(page).not_to have_content('Course Evaluation')
  end
end