
include InstructorInterfaceHelperSpec

describe "Integration tests for instructor interface" do
  before(:each) do
    assignment_setup
  end

  describe "Instructor login" do
    it "with valid username and password" do
      login_as("instructor6")
      visit '/tree_display/list'
      expect(page).to have_content("Manage content")
    end

    it "with invalid username and password" do
      visit root_path
      fill_in 'login_name', with: 'instructor6'
      fill_in 'login_password', with: 'something'
      click_button 'Sign in'
      expect(page).to have_text('Your username or password is incorrect.')
    end
  end

  describe "Create a course" do
    it "is able to create a public course or a private course" do
      login_as("instructor6")
      visit '/course/new?private=0'
      fill_in "Course Name", with: 'public course for test'
      click_button "Create"
      expect(Course.where(name: "public course for test")).to exist

      visit '/course/new?private=1'
      fill_in "Course Name", with: 'private course for test'
      click_button "Create"
      expect(Course.where(name: "private course for test")).to exist
    end
  end

  describe "View Submision Grading History" do
    it 'should display submission grading history' do
      login_as("instructor6")
      visit '/grades/view_team?id=31971'
      fill_in "instructor_id", with: ''
      fill_in "assignment_id", with: ''
      fill_in "grading_type", with: ''
      fill_in "grade_receiver_id", with: ''
      fill_in "grade", with: ''
      fill_in "comment", with: 'public submission comment for test'
      click_button "Save"
      expect(GradingHistory.where(comment: "public submission comment for test")).to exist
    end
  end

  describe "View Review Grading History" do
    it 'should display review grading history' do
      login_as("instructor6")
      visit '/grades/view_team?id=31971'
      fill_in "instructor_id", with: ''
      fill_in "assignment_id", with: ''
      fill_in "grading_type", with: ''
      fill_in "grade_receiver_id", with: ''
      fill_in "grade", with: ''
      fill_in "comment", with: 'public review comment for test'
      click_button "Save"
      expect(GradingHistory.where(comment:"public review comment for test")).to exist
    end
  end

  describe "View Publishing Rights" do
    it 'should display teams for assignment without topic' do
      login_as("instructor6")
      visit '/participants/view_publishing_rights?id=1'
      expect_page_content_to_have(['Team name'], true)
      expect_page_content_to_have(['Topic name(s)', 'Topic #'], false)
    end
  end


  describe "View assignment scores" do
    it 'is able to view scores' do
      login_as("instructor6")
      visit '/grades/view?id=1'
      expect(page).to have_content('Summary report')
    end
  end
end