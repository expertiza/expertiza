require 'rails_helper'
def check_valid_or_invalid_file_with_3_columns(itcondition_string, filepath_string, havecontent_string1, havecontent_string2)
  it itcondition_string do
    login_as("instructor6")
    visit '/assignments/1/edit'
    click_link "Topics"
    click_link "Import topics"
    file_path = Rails.root + filepath_string
    attach_file('file', file_path)
    click_button "Import"
    click_link "Topics"
    expect(page).to have_content(havecontent_string1)
    expect(page).to have_content(havecontent_string2)
  end
end
  
describe "Integration tests for instructor interface" do
  integration_test_instructor_interface
  instructor_login  
  
 

  
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
    itcondition_string = 'should be valid file with 3 columns'
    filepath_string = "spec/features/assignment_topic_csvs/3-col-valid_topics_import.csv"
    havecontent_string1 = 'expertiza'
    havecontent_string2 = 'mozilla'
    check_valid_or_invalid_file_with_3_columns(itcondition_string, filepath_string, havecontent_string1, havecontent_string2)
    itcondition_string = 'should be a valid file with 3 or more columns'
    filepath_string = "spec/features/assignment_topic_csvs/3or4-col-valid_topics_import.csv"
    havecontent_string1 = 'capybara'
    havecontent_string2 = 'cucumber'
    check_valid_or_invalid_file_with_3_columns(itcondition_string, filepath_string, havecontent_string1, havecontent_string2)
    itcondition_string = 'should be a invalid csv file'
    filepath_string = "spec/features/assignment_topic_csvs/invalid_topics_import.csv"
    havecontent_string1 = 'airtable'
    havecontent_string2 = 'devise'
    check_valid_or_invalid_file_with_3_columns(itcondition_string, filepath_string, havecontent_string1, havecontent_string2)

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
