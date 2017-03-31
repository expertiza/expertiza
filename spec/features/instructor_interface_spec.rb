require 'rails_helper'
require 'spec_helper'
require 'helpers/instructor_interface_helper_spec'

def validate_pages(filepath)
  login_as("instructor6")
  visit '/assignments/1/edit'
  click_link "Topics"
  click_link "Import topics"
  file_path = Rails.root + filepath
  attach_file('file', file_path)
  click_button "Import"
  click_link "Topics"
end

def expect_page_content_to_have(content, has_content)
  content.each do |content_element|
    if has_content
      expect(page).to have_content(content_element)
    else
      expect(page).not_to have_content(content_element)
    end
  end
end

def validate_login_and_page_content(filepath, content, has_content)
  validate_pages(filepath)
  expect_page_content_to_have(content, has_content)
end

describe "Integration tests for instructor interface" do
  include InstructorInterfaceHelperSpec
  before(:each) do
    assignment_setup
  end

  describe "Instructor login" do
    it "with valid username and password" do
      instructor_login
    end

    it "with invalid username and password" do
      invalid_user
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

  describe "Import tests for assignment topics" do
    it 'should be valid file with 3 columns' do
      validate_login_and_page_content("spec/features/assignment_topic_csvs/3-col-valid_topics_import.csv", %w(expertiza mozilla), true)
    end

    it 'should be a valid file with 3 or more columns' do
      validate_login_and_page_content("spec/features/assignment_topic_csvs/3or4-col-valid_topics_import.csv", %w(capybara cucumber), true)
    end

    it 'should be a invalid csv file' do
      validate_login_and_page_content("spec/features/assignment_topic_csvs/invalid_topics_import.csv", %w(airtable devise), false)
    end

    it 'should be an random text file' do
      validate_login_and_page_content("spec/features/assignment_topic_csvs/random.txt", ['this is a random file which should fail'], false)
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
