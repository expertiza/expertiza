require 'spec_helper'
require 'rails_helper'

describe "E1582. Create integration tests for the instructor interface using capybara and rspec" do

  describe "Test1: login" do
    it "should be able to login" do
      visit 'content_pages/view'

      fill_in "User Name", with: 'instructor6'
      fill_in "Password", with: 'password'
      click_button "SIGN IN"

      expect(page).to have_content("Manage content")
    end
  end

  describe "Test2: create a course" do
    it "should be able to create a public course or a private course" do
      visit 'content_pages/view'

      fill_in "User Name", with: 'instructor6'
      fill_in "Password", with: 'password'
      click_button "SIGN IN"

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

  describe "Test3: view assignment scores" do
    it 'should be able to view scores' do
      #login with instructor and password
      login_with 'instructor6', 'password'
      expect(page).to have_content('Manage content')
      #go to view assignments
      click_link( 'Assignments', match: :first)
      expect(page).to have_content('Assignments')
      #go to assignment chapter 11-12 madeup exercise scores
      visit '/grades/view?id=722'
      expect(page).to have_content('Class Average')
    end
    def login_with(username, password)
      visit root_path
      fill_in 'login_name', with: username
      fill_in 'login_password', with: password
      click_button 'SIGN IN'
    end
  end

  describe "Test4: view review scores" do
    it "should be able to view review scores" do
      # login as instructor6
      visit 'content_pages/view'
      fill_in "User Name", with: "instructor6"
      fill_in "Password", with: "password"
      click_button "SIGN IN"
      expect(page).to have_content('Assignments')

      # view assignments
      visit '/tree_display/list'
      expect(page).to have_content('Assignments')

      # view review reports
      visit '/review_mapping/response_report?id=723'
      expect(page).to have_content('Review report')

      # view review scores
      visit '/popup/view_review_scores_popup?assignment_id=723&reviewer_id=29065'
      expect(page).to have_content('Review scores')

    end
  end

  describe "Test5: view author-feedback scores" do
    it "should be able to view author-feedback scores" do
      # login as instructor6
      visit 'content_pages/view'
      fill_in "User Name", with: "instructor6"
      fill_in "Password", with: "password"
      click_button "SIGN IN"
      expect(page).to have_content('Assignments')

      # view assignments
      visit '/tree_display/list'
      expect(page).to have_content('Assignments')

      # view assignment scores
      visit '/grades/view?id=722'
      expect(page).to have_content('Hide stats')

      # view author-feedback scores
      visit '/grades/view?id=722#user_student5689'
      expect(page).to have_content('Hide stats')

    end
  end



end