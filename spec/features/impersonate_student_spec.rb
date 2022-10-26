describe 'Impersonate a student whose assignment has no course attribute' do
  it 'is redirected to "/student_task/list"' do
    # 1. create data for test
    instructor6 = create(:instructor) # create instructor6

    assignment_test = create(:assignment, name: 'E1968', course: nil) # create an assignment without course
    expect(assignment_test.instructor_id).to eql(instructor6.id)
    expect(assignment_test.course_id).to eql(nil)
    student_test = create(:student, name: 'student6666', email: 'stu6666@ncsu.edu') # create a student for test

    # 2. log in as instructor6
    visit(root_path)
    fill_in('login_name', with: 'instructor6')
    fill_in('login_password', with: 'password')
    click_button('Sign in')
    expect(current_path).to eql('/tree_display/list')
    expect(page).to have_content('Manage content')

    # 3. assign the assignment without course to the test student
    visit("/participants/list?id=#{assignment_test.id}&model=Assignment")
    expect(page).to have_content('E1968')
    fill_in('user_name', match: :first, with: student_test.name)
    click_button('Add', match: :first)
    expect(page).to have_content(student_test.name)
    expect(page).to have_content(student_test.email)

    # 3. impersonate the student with the assignment which is not subject to any course
    visit('/impersonate/start')
    expect(page).to have_content('Enter user account')
    fill_in('user_name', with: student_test.name)
    click_button('Impersonate')
    expect(current_path).to eql('/student_task/list')
    expect(page).to have_content("User: #{student_test.name}")
    expect(page).to have_content('E1968')
  end
end
