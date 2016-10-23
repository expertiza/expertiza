require 'rails_helper'
common
instructorlogin
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
def checkvalidorinvalidfilewith3columns(a,b,c,d)
  it a do
    login_as("instructor6")
    visit '/assignments/1/edit'
    click_link "Topics"
    click_link "Import topics"
    file_path = Rails.root + b
    attach_file('file', file_path)
    click_button "Import"
    click_link "Topics"
    expect(page).to have_content(c)
    expect(page).to have_content(d)
  end
  

describe "Import tests for assignment topics" do
  a1='should be valid file with 3 columns'
  a2="spec/features/assignment_topic_csvs/3-col-valid_topics_import.csv"
  a3='expertiza'
  a4='mozilla'
  checkvalidorinvalidfilewith3columns(a1,a2,a3,a4)
  b1='should be a valid file with 3 or more columns'
  b2="spec/features/assignment_topic_csvs/3or4-col-valid_topics_import.csv"
  b3='capybara'
  b4='cucumber'
  checkvalidorinvalidfilewith3columns(b1,b2,b3,b4)
  c1='should be a invalid csv file'
  c2="spec/features/assignment_topic_csvs/invalid_topics_import.csv"
  c3='airtable'
  c4='devise'
  checkvalidorinvalidfilewith3coulmns(c1,c2,c3,c4)
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
