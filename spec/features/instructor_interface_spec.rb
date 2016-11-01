require 'rails_helper'

describe "Integration tests for instructor interface" do
  before(:each) do
    create(:assignment)
    create_list(:participant, 3)
    create(:assignment_node)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100 * 24 * 60 * 60))
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
      click_button 'SIGN IN'
      expect(page).to have_content('Your username or password is incorrect.')
    end
  end

  describe "Create a course", type: :controller do
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
      expect(page).to have_content('Team name')
      expect(page).not_to have_content('Topic name(s)')
      expect(page).not_to have_content('Topic #')
    end
  end

  describe "Import tests for assignment topics" do
    it 'should be valid file with 3 columns' do
      login_as("instructor6")
      visit '/assignments/1/edit'
      click_link "Topics"
      click_link "Import topics"
      file_path = Rails.root + "spec/features/assignment_topic_csvs/3-col-valid_topics_import.csv"
      attach_file('file', file_path)
      click_button "Import"
      click_link "Topics"
      expect(page).to have_content('expertiza')
      expect(page).to have_content('mozilla')
    end

    it 'should be a valid file with 3 or more columns' do
      login_as("instructor6")
      visit '/assignments/1/edit'
      click_link "Topics"
      click_link "Import topics"
      file_path = Rails.root + "spec/features/assignment_topic_csvs/3or4-col-valid_topics_import.csv"
      attach_file('file', file_path)
      click_button "Import"
      click_link "Topics"
      expect(page).to have_content('capybara')
      expect(page).to have_content('cucumber')
    end

    it 'should be a invalid csv file' do
      login_as("instructor6")
      visit '/assignments/1/edit'
      click_link "Topics"
      click_link "Import topics"
      file_path = Rails.root + "spec/features/assignment_topic_csvs/invalid_topics_import.csv"
      attach_file('file', file_path)
      click_button "Import"
      click_link "Topics"
      expect(page).not_to have_content('airtable')
      expect(page).not_to have_content('devise')
    end

    it 'should be an random text file' do
      login_as("instructor6")
      visit '/assignments/1/edit'
      click_link "Topics"
      click_link "Import topics"
      file_path = Rails.root + "spec/features/assignment_topic_csvs/random.txt"
      attach_file('file', file_path)
      click_button "Import"
      click_link "Topics"
      expect(page).not_to have_content('this is a random file which should fail')
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
