def intl_login(user_name)
  user = User.find_by(name: user_name)
  login_as(user.name)
end

describe "internationalization", js: true do
  before(:each) do
    course = create(:course, name: 'Hindi Course Intl', locale: "hi_IN")
    course_participant = create(:course_participant)

    create(:assignment, course: course, name: 'Hindi Assignment')
    create(:assignment_node)
    create(:participant, user: course_participant.user)

    course = Course.find_by(name: 'Hindi Course Intl')
    assignment = Assignment.find_by(name: 'Hindi Assignment')

    expect(course.participants.size).to eq(1)
    expect(assignment.participants.size).to eq(1)
    expect(course.participants.first.user).to eq(assignment.participants.first.user)
  end

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
  end
end
