describe 'Student adds someone to team', :type => :feature do
  it 'sanity check' do
    visit root_path
    expect(page).to have_content('Expertiza')
  end
end
