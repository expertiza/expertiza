describe PopupController do
  let(:superadmin) { build_stubbed(:superadmin)}
  let(:admin) { build_stubbed(:admin)}
  let(:ta) { build_stubbed(:teaching_assistant) }
  let(:questionnaire) { build(:questionnaire, id: 1, max_question_score: 20) }
  let(:question) { build(:question, id: 1, questionnaire_id: questionnaire.id) }
  let(:answer) { build_stubbed(:answer, id: 1, question_id: question.id, response_id: response.id, answer: 15) }
  
  let(:instructor) { build_stubbed(:instructor, id: 6) }
  let(:team) { build_stubbed(:assignment_team, id: 1, name: "team1", assignment: assignment) }
  let(:student) { build_stubbed(:student, id: 1, name: "student") }
  let(:student2) { build_stubbed(:student, id: 2, name: "student2") }
  let(:participant) { build_stubbed(:participant, id: 1, user_id: 1, user: student, assignment: assignment) }
  let(:participant2) { build_stubbed(:participant, id: 2, user: student2, assignment: assignment) }
  let(:response) { build_stubbed(:response, id: 1) }
  let(:assignment) { build_stubbed(:assignment, id: 1) }
  let(:response_map) { build_stubbed(:review_response_map, id: 1, reviewee_id: team.id, reviewer_id: participant2.id, response: [response], assignment: assignment) }
  final_versions = {
    "review round 1": {questionnaire_id: nil, response_ids: []},
    "review round 2": {questionnaire_id: nil, response_ids: []}
  }
  test_url = "http://peerlogic.csc.ncsu.edu/reviewsentiment/viz/478-5hf542"
  mocked_comments_one = OpenStruct.new(comments: "test comment")

  describe '#action_allowed?' do
    context 'when user does not have right privilege, it denies action' do
      it 'for no user' do; expect(controller.send(:action_allowed?)).to be false; end
      it 'for student' do
        stub_current_user(student, student.role.name, student.role)
        expect(controller.send(:action_allowed?)).to be false
      end
    end
    context 'when role has right privilege, it allows action' do
      it 'for Super Admin' do
        stub_current_user(superadmin, superadmin.role.name, superadmin.role)
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'for Admin' do
        stub_current_user(admin, admin.role.name, admin.role)
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'for Instructor' do
        stub_current_user(instructor, instructor.role.name, instructor.role)
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'for TA' do
        stub_current_user(ta, ta.role.name, ta.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end

  describe '#author_feedback_popup' do
    context 'when response_id does not exist' do
      it 'fail to get any info' do; expect(controller.send(:author_feedback_popup)).to be nil; end
    end
    context 'when response_id exists' do
    end
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
  end

  describe '#reviewer_details_popup' do
    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
  end

  describe '#self_review_popup' do
    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
  end
end
