describe 'Student adds someone to team', :type => :feature do
  it 'sanity check' do
    student = FactoryGirl.create :student

    assignment = FactoryGirl.create :assignment
    assignment.add_participant(student.name)

    visit root_path

    fill_in 'User Name', with: student.name
    fill_in 'Password', with: student.password
    click_on 'Login'

    click_link assignment.name

    expect(page).to have_content('Submit or Review work for')
  end
end
