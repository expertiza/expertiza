require_relative 'helpers/assignment_creation_helper'
include AssignmentCreationHelper

describe "assignment creation due dates", js: true do

  before(:each) do
     login_as("instructor6")
  end
    it "should edit assignment available to students" do
         visit "/assignments/1/edit"
    	 find(:css, "#use_github[value='use_github']").set(true)
         visit "/assignments/list_submissions?id=1"
         expect(page).to have_content("Github data")
         #expect(page).to have_no_content('Inherit Teams From Course')
    end

  # able to set deadlines for a single round of reviews

end
