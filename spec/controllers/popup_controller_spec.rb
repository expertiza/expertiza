describe PopupController do
  let(:superadmin) { build_stubbed(:superadmin) }
  let(:admin) { build_stubbed(:admin) }
  let(:ta) { build_stubbed(:teaching_assistant) }
  let(:questionnaire) { build_stubbed(:questionnaire, id: 1, max_question_score: 20) }
  let(:question) { build_stubbed(:question, id: 1, questionnaire_id: questionnaire.id) }
  let(:answer) { build_stubbed(:answer, id: 1, question_id: question.id, response_id: response.id, answer: 15) }

  let(:instructor) { build_stubbed(:instructor, id: 6) }
  let(:team) { build_stubbed(:assignment_team, id: 1, name: 'team1', assignment: assignment) }
  let(:student) { build_stubbed(:student, id: 1, username: 'student') }
  let(:student2) { build_stubbed(:student, id: 2, username: 'student2') }
  let(:participant) { build_stubbed(:participant, id: 1, user_id: 1, user: student, assignment: assignment) }
  let(:participant2) { build_stubbed(:participant, id: 2, user: student2, assignment: assignment) }
  let(:response) { build_stubbed(:response, id: 1) }
  let(:assignment) { build_stubbed(:assignment, id: 1) }
  let(:response_map) { build_stubbed(:review_response_map, id: 1, reviewee_id: team.id, reviewer_id: participant2.id, response: [response], assignment: assignment) }
  final_versions = {
    "review round 1": { questionnaire_id: nil, response_ids: [] },
    "review round 2": { questionnaire_id: nil, response_ids: [] }
  }
  test_url = 'http://peerlogic.csc.ncsu.edu/reviewsentiment/viz/478-5hf542'
  mocked_comments_one = OpenStruct.new(comments: 'test comment')

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

  # this can be called from "response_report" by clicking student names from instructor end
  describe '#author_feedback_popup' do
    context 'when response_id does not exist' do
      it 'fail to get any info' do; expect(controller.send(:author_feedback_popup)).to be nil; end
    end
    context 'when response_id exists' do
      it 'passes tests in first block' do
        allow(Question).to receive_message_chain(:find, :questionnaire_id).with(answer.question_id).with(no_args).and_return(questionnaire.id)
        allow(Questionnaire).to receive(:find).with(questionnaire.id).and_return(questionnaire)
        allow(questionnaire).to receive(:max_question_score).and_return(20)
        allow(Answer).to receive(:where).with(any_args).and_return([answer])
        allow(Response).to receive(:find).with(any_args).and_return(response)
        allow(response).to receive(:average_score).and_return(16)
        allow(response).to receive(:aggregate_questionnaire_score).and_return(20)
        allow(response).to receive(:maximum_score).and_return(19)
        allow(Participant).to receive(:find).with('1').and_return(participant)
        allow(User).to receive(:find).with(participant.user_id).and_return(participant)

        request_params = { response_id: 1, reviewee_id: 1 }
        user_session = { user: ta }
        result = get :author_feedback_popup, params: request_params, session: user_session
        expect(result.status).to eq 200
        expect(controller.instance_variable_get(:@sum)).to eq 20
        expect(controller.instance_variable_get(:@total_possible)).to eq 19
        expect(controller.instance_variable_get(:@total_percentage)).to eq 16
      end
    end
  end

  # this can be called from "response_report" by clicking team names from instructor end.
  describe '#team_users_popup' do
    it 'renders the page successfully as Instructor' do
      allow(Team).to receive(:find).and_return(team)
      allow(Assignment).to receive(:find).and_return(assignment)

      reviewer = double(:reviewer1, reviewer_id: 1)
      user_id = double(:user_id, user_id: 1)
      response = double('response1', response_id: 1, responses: 'this is test response')
      answer = double('answer', question_id: 1)

      allow(ResponseMap).to receive(:find).with(1).and_return(reviewer)
      allow(Participant).to receive(:find).with(1).and_return(user_id)
      allow(Response).to receive_message_chain(:where, :last).with(map_id: 1, round: 1).with(no_args).and_return(response)
      allow(Answer).to receive(:where).with(response_id: 1).and_return(answer)
      allow(Response).to receive_message_chain(:average_score).and_return(90)
      allow(Response).to receive_message_chain(:aggregate_questionnaire_score).with(no_args).and_return(response)
      allow(Response).to receive_message_chain(:maximum_score).with(no_args).and_return(response)

      request_params = { id: team.id }
      user_session = { user: instructor }
      result = get :team_users_popup, params: request_params, session: user_session
      expect(result.status).to eq 200
    end
  end

  # Views tone analysis report and heatmap
  describe '#view_review_scores_popup' do
    context 'review tone analysis operation is performed' do
      it 'Prepares scores and review analysis report for rendering purpose' do
        allow(Assignment).to receive(:find).and_return(assignment)
        allow(Participant).to receive(:find).and_return(participant)
        request_params = { reviewer_id: participant.id, assignment_id: assignment.id }
        user_session = { user: instructor }
        result = get :view_review_scores_popup, params: request_params, session: user_session
        expect(controller.instance_variable_get(:@review_final_versions)).to eq final_versions
      end
    end
  end

  # this can be called from "response_report" by clicking reviewer names from instructor end.
  describe '#reviewer_details_popup' do
    it 'render reviewer_details_popup page successfully' do
      participant = double(:participant, user_id: 1)
      user = double(:user, fullname: 'Test User', username: 'Test', email: 'test@gmail.com', handle: 1)
      allow(Participant).to receive(:find).with('1').and_return(participant)
      allow(User).to receive(:find).with(participant.user_id).and_return(user)
      request_params = { id: 1, assignment_id: 1 }
      user_session = { user: instructor }
      get :reviewer_details_popup, params: request_params, session: user_session
      expect(@response).to have_http_status(200)
      expect(user.fullname).to eq('Test User')
      expect(user.username).to eq('Test')
      expect(user.email).to eq('test@gmail.com')
      expect(user.handle).to eq(1)
    end
  end

  # this can be called from "response_report" by clicking reviewer names from instructor end.
  describe '#self_review_popup' do
    context 'when current user is the participant' do
      it 'render page successfully as Instructor to get maximum_score ' do
        question1 = double(:question1, questionnaire_id: 1)
        questionnaire1 = double(:questionnaire1, min_question_score: 1, max_question_score: 3, name: 'Test questionnaire')
        answer1 = double('Answer', question_id: 1)
        response1 = double('response1', response_id: 1, responses: 'this is test response')
        allow(Answer).to receive_message_chain(:where, :first).with(response_id: 1).with(no_args).and_return(answer1)
        allow(Question).to receive(:find).with(1).and_return(question1)
        allow(Questionnaire).to receive(:find).and_return(questionnaire1)
        allow(Answer).to receive(:where).with('1').and_return(answer1)
        allow(Response).to receive_message_chain(:find, :average_score).with('1').with(no_args).and_return(response1)
        allow(Response).to receive_message_chain(:find, :aggregate_questionnaire_score).with('1').with(no_args).and_return(response1)
        allow(Response).to receive_message_chain(:find, :maximum_score).with('1').with(no_args).and_return(response1)
        request_params = { response_id: 1, user_fullname: questionnaire1.name }
        user_session = { user: instructor }
        get :self_review_popup, params: request_params, session: user_session
        expect(@response).to have_http_status(200)
      end
    end
  end
end
