describe "internationalization", js: true do
  before(:each) do
    instructor = create(:instructor, name: 'instructor7')

    course = create(:course, name: 'Hindi Course Intl', instructor: instructor, locale: Course.locales["hi_IN"])
    course_participant = create(:course_participant)

    create(:assignment, course: course, name: 'Hindi Assignment')
    create(:assignment_node)
    create(:participant, user: course_participant.user)

    course = Course.find_by(name: 'Hindi Course Intl')
    assignment = Assignment.find_by(name: 'Hindi Assignment')

    create(:course, name: 'Default Course', instructor: instructor)

    expect(course.participants.size).to eq(1)
    expect(assignment.participants.size).to eq(1)
    expect(course.participants.first.user).to eq(assignment.participants.first.user)
  end

  let(:instructor) { Instructor.find_by(name: 'instructor7') }
  let(:course) { Course.find_by(name: 'Default Course') }
  let(:hindi_course) { Course.find_by(name: 'Hindi Course Intl') }
  let(:hindi_assignment) { Assignment.find_by(name: 'Hindi Assignment') }
  let(:hindi_student) { hindi_course.participants.first }

  describe "changing the user's locale preference" do
    it "should display the profile page in the user's configured language" do
      login_as(hindi_student.name)
      visit '/profile/update/edit'

      # Default locale preference is 'No preference'
      expect(page).to have_select('user_locale', selected: 'No preference')
      expect(page).to have_content("User Profile Information")

      select "English", :from => "user_locale"
      click_button "Save", match: :first
      expect(page).to have_select('user_locale', selected: 'English')
      expect(page).to have_content("User Profile Information")

      select "Hindi", :from => "user_locale"
      click_button "Save", match: :first
      expect(page).to have_select('user_locale', selected: 'Hindi')
      expect(page).to have_content("उपयोगकर्ता के जानकारी")
    end

    it "should be able to persist user locale preference across sessions" do
      login_as(hindi_student.name)
      visit '/profile/update/edit'
      expect(page).to have_select('user_locale', selected: 'No preference')

      select "Hindi", :from => "user_locale"
      click_button "Save", match: :first
      Capybara.reset_sessions!

      login_as(hindi_student.name)
      visit '/profile/update/edit'
      expect(page).to have_select('user_locale', selected: 'Hindi')
    end
  end

  describe "changing the course's locale preference" do
    it "should display the course page in the course's configured language" do
      login_as(instructor.name)
      visit "/course/#{course.id}/edit"

      # Default course locale is 'English'
      expect(page).to have_select('course_locale', selected: 'English')
      expect(page).to have_content("Edit course")

      select "Hindi", :from => "course_locale"
      click_button "Update", match: :first

      visit "/course/#{course.id}/edit"
      expect(page).to have_select('course_locale', selected: 'Hindi')
      expect(page).to have_content("एडिट कोर्स")
    end

    it "should be able to persist course locale preference across sessions" do
      login_as(instructor.name)
      visit "/course/#{course.id}/edit"
      expect(page).to have_select('course_locale', selected: 'English')

      select "Hindi", :from => "course_locale"
      click_button "Update", match: :first
      Capybara.reset_sessions!

      login_as(instructor.name)
      visit "/course/#{course.id}/edit"
      expect(page).to have_select('course_locale', selected: 'Hindi')
    end
  end
end
