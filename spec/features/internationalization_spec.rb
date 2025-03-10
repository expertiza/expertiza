describe 'internationalization', js: true do
  before(:each) do
    instructor = create(:instructor, name: 'hindi_instructor')
    student = create(:student)

    course = create(:course, name: 'Hindi Course Intl', instructor: instructor, locale: Course.locales['hi_IN'])
    create(:course_participant, course: course, user: student)
    assignment = create(:assignment, course: course, name: 'Hindi Assignment')
    # create(:assignment_node, assignment: assignment)
    create(:participant, user: student, assignment: assignment)

    eng_course = create(:course, name: 'English Course')
    create(:course_participant, course: eng_course, user: student)
    eng_assignment = create(:assignment, course: course, name: 'English Assignment')
    # create(:assignment_node, assignment: eng_assignment)
    create(:participant, user: student, assignment: eng_assignment)

    course = Course.find_by(name: 'Hindi Course Intl')
    assignment = Assignment.find_by(name: 'Hindi Assignment')

    expect(course.participants.size).to eq(1)
    expect(assignment.participants.size).to eq(1)
    expect(course.participants.first.user).to eq(assignment.participants.first.user)

    eng_course = Course.find_by(name: 'English Course')
    eng_assignment = Assignment.find_by(name: 'English Assignment')

    expect(eng_course.participants.size).to eq(1)
    expect(eng_assignment.participants.size).to eq(1)
    expect(eng_course.participants.first.user).to eq(eng_assignment.participants.first.user)
  end

  let(:hindi_course) { Course.find_by(name: 'Hindi Course Intl') }
  let(:hindi_assignment) { Assignment.find_by(name: 'Hindi Assignment') }
  let(:hindi_course_student) { hindi_course.participants.first }

  describe "changing the user's locale preference" do
    it "should display the profile page in the user's configured language" do
      login_as(hindi_course_student.name)
      visit '/profile/update/edit'

      # Default locale preference is 'No Preference'
      expect(page).to have_select('user_locale', selected: 'No Preference')
      expect(page).to have_content('User Profile Information')

      select 'English', from: 'user_locale'
      click_button 'Save', match: :first
      expect(page).to have_select('user_locale', selected: 'English')
      expect(page).to have_content('User Profile Information')

      select 'Hindi', from: 'user_locale'
      click_button 'Save', match: :first
      expect(page).to have_select('user_locale', selected: 'Hindi')
      expect(page).to have_content('उपयोगकर्ता के जानकारी')
    end

    it 'should be able to persist user locale preference across sessions' do
      login_as(hindi_course_student.name)
      visit '/profile/update/edit'
      expect(page).to have_select('user_locale', selected: 'No Preference')

      select 'Hindi', from: 'user_locale'
      click_button 'Save', match: :first
      Capybara.reset_sessions!

      login_as(hindi_course_student.name)
      visit '/profile/update/edit'
      expect(page).to have_select('user_locale', selected: 'Hindi')
    end
  end

  describe "changing the course's locale preference" do
    let(:instructor) { Instructor.find_by(name: 'hindi_instructor') }
    let(:course) { Course.find_by(name: 'English Course') }

    it "should display the course page in the course's configured language" do
      login_as(instructor.name)
      visit "/course/#{course.id}/edit"

      # English Course locale is 'English'
      expect(page).to have_select('course_locale', selected: 'English')
      expect(page).to have_content('Edit course')

      select 'Hindi', from: 'course_locale'
      click_button 'Update', match: :first

      visit "/course/#{course.id}/edit"
      expect(page).to have_select('course_locale', selected: 'Hindi')
      # Renders in english since translation is currently only enabled for students
      expect(page).to have_content('Edit course')
    end

    it 'should be able to persist course locale preference across sessions' do
      login_as(instructor.name)
      visit "/course/#{course.id}/edit"
      expect(page).to have_select('course_locale', selected: 'English')

      select 'Hindi', from: 'course_locale'
      click_button 'Update', match: :first
      Capybara.reset_sessions!

      login_as(instructor.name)
      visit "/course/#{course.id}/edit"
      expect(page).to have_select('course_locale', selected: 'Hindi')
    end
  end

  describe 'a user with no language preference' do
    it 'views the profile page (and other pages without a locale affinity) in English' do
      login_as(hindi_course_student.name)
      visit '/profile/update/edit'
      expect(page).to have_select('user_locale', selected: 'No Preference')

      visit '/menu/student_task'
      expect(page).to have_content('Assignments')
    end
    it 'views the course page in the course language (and also for other pages with a locale affinity)' do
      login_as(hindi_course_student.name)
      visit '/profile/update/edit'
      expect(page).to have_select('user_locale', selected: 'No Preference')

      visit '/menu/student_task'
      click_link 'Hindi Assignment'
      expect(page).to have_content('सबमिट करें या काम की समीक्षा करें')
    end
  end

  describe "a user with a language preference of 'Hindi'" do
    before(:each) do
      login_as(hindi_course_student.name)
      visit '/profile/update/edit'
      select 'Hindi', from: 'user_locale'
      click_button 'Save', match: :first
    end

    it "views the profile page in 'Hindi'" do
      visit '/profile/update/edit'
      expect(page).to have_content('उपयोगकर्ता के जानकारी')

      visit '/menu/student_task'
      expect(page).to have_content('असाइनमेंट')
    end

    it "should use the user's preferred language over the course's language (similarly for other pages with a locale affinity)" do
      visit '/menu/student_task'
      click_link 'Hindi Assignment'
      expect(page).to have_content('सबमिट करें या काम की समीक्षा करें')

      visit '/menu/student_task'
      click_link 'English Assignment'
      expect(page).to have_content('सबमिट करें या काम की समीक्षा करें')
    end
  end
end
