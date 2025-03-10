describe 'displaying inherit teams section' do
  it 'should display inherit teams option while creating an assignment team' do
    create(:assignment)
    create(:assignment_node)
    create(:assignment_team)

    login_as('instructor6')
    visit '/teams/list?id=1&type=Assignment'
    click_link 'Create Team'
    expect(page).to have_content('Inherit Teams From Course')
  end

  it 'should not display inherit teams option while creating a course team' do
    create(:course)
    create(:course_node)
    create(:course_team)

    login_as('instructor6')
    visit '/teams/list?id=1&type=Course'
    click_link 'Create Team'
    expect(page).to have_no_content('Inherit Teams From Course')
  end

  it 'should not display inherit teams option while creating team for an assignment without a course' do
    assignment = create(:assignment)
    create(:assignment_node)
    assignment.update_attributes(course_id: nil)

    login_as('instructor6')
    visit '/teams/list?id=1&type=Assignment'
    click_link 'Create Team'
    expect(page).to have_no_content('Inherit Teams From Course')
  end
end
