describe 'My Test Cases' do
  before(:each) do
    create(:instructor)
    create(:role_of_student)
    login_as("instructor6")
    visit '/tree_display/list'
    click_link 'View reports'
    expect(page).to have_current_path('/reports/response_report')
    click_link 'View'
  end

  it "can display review metrics", js: true do
    expect(page).to have_content('Metrics')
  end

  it "can display review grades of each round", js: true do
    expect(page).to have_content('Score awarded')
  end

  it "can display review summary", js: true do
    expect(page).to have_content('Reviews done')
  end

  it "can display review summary", js: true do
    expect(page).to have_content('Reviewer')
  end

  it "can display review summary", js: true do
    expect(page).to have_content('Team reviewed')
  end
end

