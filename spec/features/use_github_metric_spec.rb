require_relative 'helpers/assignment_creation_helper'
include AssignmentCreationHelper

describe "assignment creation due dates", js: true do

  before(:each) do
    create_deadline_types()
    @assignment = create(:assignment, name: 'public assignment for test')
    login_as("instructor6")
    visit "/assignments/834/edit"


  end
    it "should edit assignment available to students" do
    	 find(:css, "#use_github[value='use_github']").set(true)
         visit "/assignments/list_submissions?id=834"
    end

  # able to set deadlines for a single round of reviews

end
