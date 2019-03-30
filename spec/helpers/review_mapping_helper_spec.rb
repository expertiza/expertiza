
require 'rspec'

describe 'My Test Cases' do

  it "can display review metrics", js: true do
    create(:instructor)
    create(:role_of_student)
    login_as 'instructor6'
    visit '/tree_display/list'
    click_link 'View reports'
    expect(page).to have_current_path('/reports/response_report')
    click_link 'View'
    expect(page).to have_content('Metrics')
  end

  it "can display review grades of each round", js: true do
    create(:instructor)
    create(:role_of_student)
    login_as 'instructor6'
    visit '/tree_display/list'
    click_link 'View reports'
    expect(page).to have_current_path('/reports/response_report')
    click_link 'View'
    expect(page).to have_content('Score awarded')
  end

  it "can display review summary", js: true do
    create(:instructor)
    create(:role_of_student)
    login_as 'instructor6'
    visit '/tree_display/list'
    click_link 'View reports'
    expect(page).to have_current_path('/reports/response_report')
    click_link 'View'
    expect(page).to have_content('Reviews done')
  end

end
