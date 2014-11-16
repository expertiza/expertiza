describe 'Student adds someone to team', :type => :feature do
  it 'sanity check' do
    student = FactoryGirl.create :student

    visit root_path

    fill_in 'User Name', with: student.name
    fill_in 'Password', with: student.password
    click_on 'Login'

    expect(page).to have_content('Assignments')
  end
end
