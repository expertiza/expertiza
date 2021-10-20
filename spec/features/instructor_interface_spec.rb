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

  describe "View Publishing Rights" do
    it 'should display teams for assignment without topic' do
      login_as("instructor6")
      visit '/participants/view_publishing_rights?id=1'
      expect_page_content_to_have(['Team name'], true)
      expect_page_content_to_have(['Topic name(s)', 'Topic #'], false)
    end
  end

  # E1776 (Fall 2017)
  #
  # The tests below are no longer reflective of the current import process for topics.
  #
  # 1. There is now an additional intermediary page during the import process.
  # 2. There are now checkbox options on the initial import page to specify optional columns.
  # 3. The intermediary data structures for imports have changed (see the pull request notes).
  # 4. The new import process expects all rows in a file to have the same number of columns.
  #    That is, it expects optional columns to be common across all rows within the same file.
  #
  # describe "Import tests for assignment topics" do
  #   it 'should be valid file with 3 columns' do
  #     validate_login_and_page_content("spec/features/assignment_topic_csvs/3-col-valid_topics_import.csv", %w(expertiza mozilla), true)
  #   end
  #
  #   it 'should be a valid file with 3 or more columns' do
  #     validate_login_and_page_content("spec/features/assignment_topic_csvs/3or4-col-valid_topics_import.csv", %w(capybara cucumber), true)
  #   end
  #
  #   it 'should be a invalid csv file' do
  #     validate_login_and_page_content("spec/features/assignment_topic_csvs/invalid_topics_import.csv", %w(airtable devise), false)
  #   end
  #
  #   it 'should be an random text file' do
  #     validate_login_and_page_content("spec/features/assignment_topic_csvs/random.txt", ['this is a random file which should fail'], false)
  #   end
  # end

  describe "View assignment scores" do
    it 'is able to view scores' do
      login_as("instructor6")
      visit '/grades/view?id=1'
      expect(page).to have_content('Summary report')
    end
  end
end
