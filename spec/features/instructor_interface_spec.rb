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

  describe "Test2: Create a course" do
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
end