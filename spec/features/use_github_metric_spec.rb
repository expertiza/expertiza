require_relative 'helpers/assignment_creation_helper'
include AssignmentCreationHelper

describe "assignment creation due dates", js: true do

  before(:each) do
    login_as("instructor6")
        let(:review_response) { build(:response, id: 1, map_id: 1) }
        let(:question) { build(:question) }
        let(:participant) { build(:participant, id: 1, assignment: assignment, user_id: 1) }
        let(:assignment) { build(:assignment, id: 1, max_team_size: 2, questionnaires: [review_questionnaire], is_penalty_calculated: true)}
        let(:review_questionnaire) { build(:questionnaire, id: 1, questions: [question]) }
        let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
        let(:team) { build(:assignment_team, id: 1, name: 'no team') }
        let(:metric) { build(:metric, id: 1, metric_source_id: 1, participant_id: participant.id, github_id:"student@ncsu.edu") }
        let(:assignment_team) {build(:assignment_team, id: 1, name: 'team1', submitted_hyperlinks: ["https://www.github.com/anonymous/expertiza", "https://github.com/expertiza/expertiza/pull/1234"])}
  end
    it "should edit assignment available to students" do
         visit "/assignments/1/edit"
    	 find(:css, "#use_github[value='use_github']").set(true)
         visit "/assignments/list_submissions?id=1"
         expect(page).to have_content("Github data")
    end

  # able to set deadlines for a single round of reviews

end
