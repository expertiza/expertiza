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
end