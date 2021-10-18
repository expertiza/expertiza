describe PopupController do
  let(:instructor) { build(:instructor, id: 6) }
  let(:team) { build(:assignment_team, id: 1, name: "team1", assignment: assignment) }
  let(:student) { build(:student, id: 1, name: "student") }
  let(:student2) { build(:student, id: 2, name: "student2") }
  let(:participant) { build(:participant, id: 1, user: student, assignment: assignment) }
  let(:participant2) { build(:participant, id: 2, user: student2, assignment: assignment) }
  let(:response) { build(:response, id: 1) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:response_map) { build(:review_response_map, id: 1, reviewee_id: team.id, reviewer_id: participant2.id, response: [response], assignment: assignment) }
  final_versions = {
    "review round 1": {questionnaire_id: nil, response_ids: []},
    "review round 2": {questionnaire_id: nil, response_ids: []}
  }
  test_url = "http://peerlogic.csc.ncsu.edu/reviewsentiment/viz/478-5hf542"
  mocked_comments_one = OpenStruct.new(comments: "test comment")

  describe '#action_allowed?' do
    context 'when user is valid' do
      it 'user is Super Admin' do
      end
    end
  end

  describe '#author_feedback_popup' do
    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
  end

  describe '#team_users_popup' do
    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
    it "renders the page successfuly as Instructor" do 
      allow(Team).to receive(:find).and_return(team)
      allow(Assignment).to receive(:find).and_return(assignment)
      params = {id: team.id, assignment: assignment, reviewer_id: participant2.id}
      session = {user: instructor}
      result = get :team_users_popup, params, session
      expect(result.status).to eq 200

    end
  end

  describe '#view_review_scores_popup'do
    context 'review tone analysis operation is performed' do
      it 'Prepares scores and review analysis report for rendering purpose' do
        allow(Assignment).to receive(:find).and_return(assignment)
        allow(Participant).to receive(:find).and_return(participant)
        params = {reviewer_id: participant.id, assignment_id: assignment.id}
        session = {user: instructor}
        result = get :view_review_scores_popup, params, session
        expect(controller.instance_variable_get(:@review_final_versions)).to eq final_versions
      end
    end

    context 'when view_review_scores_popup page is not allowed to access' do
      it 'redirects to root path (/)' do
        session[:user] = nil
        allow(Assignment).to receive(:find).and_return(assignment)
        allow(Participant).to receive(:find).and_return(participant)
        params = {reviewer_id: participant.id, assignment_id: assignment.id}
        get :view_review_scores_popup, params
        expect(response).to redirect_to('/')
      end
    end
  end

  describe '#reviewer_details_popup' do
    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
  end

  describe '#self_review_popup' do
    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
  end
end
