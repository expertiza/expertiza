require_relative 'helpers/assignment_creation_helper'
include AssignmentCreationHelper

describe "assignment creation due dates", js: true do
  before(:each) do
    create_deadline_types()
    @assignment = create(:assignment, name: 'public assignment for test')
    @assignment_team = create(:assignment_team, id: 1, name: 'team1', submitted_hyperlinks: ["https://www.github.com/anonymous/expertiza", "https://github.com/expertiza/expertiza/pull/1234"])
    create(:metric)
    allow(metrics_table(@assignment_team)).to receive(:metric)
    login_as("instructor6")
  end
    it "should edit assignment available to students" do
         visit "/assignments/#{@assignment.id}/edit"
    	 find(:css, "#use_github[value='use_github']").set(true)
         visit "/assignments/list_submissions?id={@assignment.id}"
         expect(page).to have_content("Github data")
    end

  # able to set deadlines for a single round of reviews

end
