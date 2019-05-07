def intl_login(user_name)
  user = User.find_by(name: user_name)

  visit root_path
  fill_in 'login_name', with: user_name
  fill_in 'login_password', with: 'password'
  click_button 'Sign in'
end

def add_student_to_course(student, course)
  intl_login('instructor6')
  visit "/participants/list?id=#{course.id}&model=Course"
  fill_in 'user_name', with: student.name, match: :first
  choose 'user_role_participant', match: :first
  expect { click_button 'Add', match: :first; sleep(1) }.to change { Participant.count }.by 1
  click_link "Logout", match: :first
end

def add_student_to_assignment(student, assignment)
  intl_login('instructor6')
  visit "/participants/list?id=#{assignment.id}&model=Assignment"
  fill_in 'user_name', with: student.name, match: :first
  choose 'user_role_participant', match: :first
  expect { click_button 'Add', match: :first; sleep(1) }.to change { Participant.count }.by 1
  click_link "Logout", match: :first
end

# Begin internationalization testing
describe "internationalization", js: true do
  before(:each) do
    course = create(:course, name: 'Hindi Course Intl', locale: "hi_IN")
    create(:assignment, course: course, name: 'Hindi Assignment')
    create(:assignment_node)
  end

  it "should be able to handle back link click after language change" do
    student = create(:student)
    course = Course.where(name: 'Hindi Course Intl')[0]
    add_student_to_course(student,course)
    assignment = Assignment.where(name: 'Hindi Assignment')[0]
    add_student_to_assignment(student,assignment)
    intl_login(student.name)
    #sleep(300)
    click_link "Hindi Assignment", match: :first
    click_link "Select language", match: :first
    click_link "English", match: :first
    expect(page).to have_content("Submit or Review work for")
    click_link "Back", match: :first
    expect(page).to have_content("Students who have teamed with you")
  end

  it "should be able to persist user selection" do
    student = create(:student)
    course = Course.where(name: 'Hindi Course Intl')[0]
    add_student_to_course(student,course)
    assignment = Assignment.where(name: 'Hindi Assignment')[0]
    add_student_to_assignment(student,assignment)
    intl_login(student.name)
    click_link "Select language", match: :first
    click_link "English", match: :first
    expect(page).to have_content("Students who have teamed with you")
    #sleep(300)
    click_link "Hindi Assignment", match: :first
    expect(page).to have_content("Submit or Review work for")
  end

  it "should show different language for assignments based on their course" do
    student = create(:student)
    hindiCourse = Course.where(name: 'Hindi Course Intl')[0]
    add_student_to_course(student,hindiCourse)
    hindiAssignment = Assignment.where(name: 'Hindi Assignment')[0]
    add_student_to_assignment(student,hindiAssignment)
    englishCourse = create(:course, name: 'English Course Intl', locale: "en")
    englishAssignment = create(:assignment, course: englishCourse, name: 'English Assignment')
    add_student_to_course(student,englishCourse)
    intl_login(student.name)
    expect(page).to have_content("Students who have teamed with you")
    click_link "Hindi Assignment", match: :first
    expect(page).to have_content("सबमिट करें या काम की समीक्षा करें")
    click_link "वापस पीछे", match: :first
    expect(page).to have_content("Students who have teamed with you")
  end

  it "should be able to change languange for user" do
    student = create(:student)
    course = Course.where(name: 'Hindi Course Intl')[0]
    add_student_to_course(student,course)
    intl_login(student.name)
    expect(page).to have_content("असाइनमेंट")
    click_link "Select language", match: :first
    click_link "English", match: :first
    expect(page).to have_content("Students who have teamed with you")
  end
end