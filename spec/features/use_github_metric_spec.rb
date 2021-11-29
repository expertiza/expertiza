require_relative 'helpers/assignment_creation_helper'
include AssignmentCreationHelper

describe "assignment creation due dates", js: true do
     let(:review_response) { build(:response) }
     let(:assignment) { build(:assignment, id: 1, max_team_size: 2, questionnaires: [review_questionnaire], is_penalty_calculated: true)}
     let(:assignment_questionnaire) { build(:assignment_questionnaire, used_in_round: 1, assignment: assignment) }
     let(:participant) { build(:participant, id: 1, assignment: assignment, user_id: 1) }
     let(:participant2) { build(:participant, id: 2, assignment: assignment, user_id: 1) }
     let(:review_questionnaire) { build(:questionnaire, id: 1, questions: [question]) }
     let(:admin) { build(:admin) }
     let(:instructor) { build(:instructor, id: 6) }
     let(:question) { build(:question) }
     let(:team) { build(:assignment_team, id: 1, assignment: assignment, users: [instructor]) }
     let(:student) { build(:student) }
     let(:review_response_map) { build(:review_response_map, id: 1) }
     let(:assignment_due_date) { build(:assignment_due_date) }
     let(:ta) { build(:teaching_assistant, id: 8) }
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
