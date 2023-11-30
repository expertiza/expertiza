require 'rails_helper'
describe ReviewMappingController do
  let(:assignment) { double('Assignment', id: 1) }
  let(:reviewer) { double('Participant', id: 1, name: 'reviewer') }
  let(:review_response_map) do
    double('ReviewResponseMap', id: 1, map_id: 1, assignment: assignment,
                                reviewer: reviewer, reviewee: double('Participant', id: 2, name: 'reviewee'))
  end
  let(:metareview_response_map) do
    double('MetareviewResponseMap', id: 1, map_id: 1, assignment: assignment,
                                    reviewer: reviewer, reviewee: double('Participant', id: 2, name: 'reviewee'))
  end
  let(:participant) { double('AssignmentParticipant', id: 1, can_review: false, user: double('User', id: 1)) }
  let(:participant1) { double('AssignmentParticipant', id: 2, can_review: true, user: double('User', id: 2)) }
  let(:user) { double('User', id: 3) }
  let(:participant2) { double('AssignmentParticipant', id: 3, can_review: true, user: user) }
  let(:team) { double('AssignmentTeam', name: 'no one') }
  let(:team1) { double('AssignmentTeam', name: 'no one1') }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    instructor = build(:instructor)
    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(participant).to receive(:get_reviewer).and_return(participant)
    allow(participant1).to receive(:get_reviewer).and_return(participant1)
    allow(participant2).to receive(:get_reviewer).and_return(participant2)
    allow(reviewer).to receive(:get_reviewer).and_return(reviewer)
  end

  describe '#action_allowed?' do
    context "when the action is 'add_dynamic_reviewer'" do
      it 'returns true' do
        params = { action: 'add_dynamic_reviewer' }
        allow(controller).to receive(:params).and_return(params)
        expect(controller.action_allowed?).to be true
      end
    end

    context "when the action is 'show_available_submissions'" do
      it 'returns true' do
        params = { action: 'show_available_submissions' }
        allow(controller).to receive(:params).and_return(params)
        expect(controller.action_allowed?).to be true
      end
    end

    context "when the action is 'assign_reviewer_dynamically'" do
      it 'returns true' do
        params = { action: 'assign_reviewer_dynamically' }
        allow(controller).to receive(:params).and_return(params)
        expect(controller.action_allowed?).to be true
      end
    end

    context "when the action is 'assign_metareviewer_dynamically'" do
      it 'returns true' do
        params = { action: 'assign_metareviewer_dynamically' }
        allow(controller).to receive(:params).and_return(params)
        expect(controller.action_allowed?).to be true
      end
    end

    context "when the action is 'assign_quiz_dynamically'" do
      it 'returns true' do
        params = { action: 'assign_quiz_dynamically' }
        allow(controller).to receive(:params).and_return(params)
        expect(controller.action_allowed?).to be true
      end
    end

    context "when the action is 'start_self_review'" do
      it 'returns true' do
        params = { action: 'start_self_review' }
        allow(controller).to receive(:params).and_return(params)
        expect(controller.action_allowed?).to be true
      end
    end

    context 'when the action is not one of the allowed actions' do
      it "returns true if the current role is an 'Instructor'" do
        params = { action: 'some_other_action' }
        allow(controller).to receive(:params).and_return(params)
        allow(controller).to receive(:current_role_name).and_return('Instructor')

        expect(controller.action_allowed?).to eq(true)
      end

      it "returns true if the current role is a 'Teaching Assistant'" do
        params = { action: 'some_other_action' }
        allow(controller).to receive(:current_role_name).and_return('Teaching Assistant')
        allow(controller).to receive(:params).and_return(params)

        expect(controller.action_allowed?).to eq(true)
      end

      it "returns true if the current role is an 'Administrator'" do
        allow(controller).to receive(:current_role_name).and_return('Administrator')
        params = { action: 'some_other_action' }
        allow(controller).to receive(:params).and_return(params)
        expect(controller.action_allowed?).to eq(true)
      end
    end
  end

  describe '#add_calibration' do
    context 'when both participant and review_response_map have already existed' do
      it 'does not need to create new objects and redirects to responses#new maps' do
        allow(AssignmentParticipant).to receive_message_chain(:where, :first)
          .with(parent_id: '1', user_id: 1).with(no_args).and_return(participant)
        allow(ReviewResponseMap).to receive_message_chain(:where, :first)
          .with(reviewed_object_id: '1', reviewer_id: 1, reviewee_id: '1', calibrate_to: true).with(no_args).and_return(review_response_map)
        request_params = { id: 1, team_id: 1 }
        user_session = { user: build(:instructor, id: 1) }
        get :add_calibration, params: request_params, session: user_session
        expect(response).to redirect_to '/response/new?assignment_id=1&id=1&return=assignment_edit'
      end
    end

    context 'when both participant and review_response_map have not been created' do
      it 'creates new objects and redirects to responses#new maps' do
        allow(AssignmentParticipant).to receive_message_chain(:where, :first)
          .with(parent_id: '1', user_id: 1).with(no_args).and_return(nil)
        allow(AssignmentParticipant).to receive(:create)
          .with(parent_id: '1', user_id: 1, can_submit: 1, can_review: 1, can_take_quiz: 1, handle: 'handle').and_return(participant)
        allow(ReviewResponseMap).to receive_message_chain(:where, :first)
          .with(reviewed_object_id: '1', reviewer_id: 1, reviewee_id: '1', calibrate_to: true).with(no_args).and_return(nil)
        allow(ReviewResponseMap).to receive(:create)
          .with(reviewed_object_id: '1', reviewer_id: 1, reviewee_id: '1', calibrate_to: true).and_return(review_response_map)
        request_params = { id: 1, team_id: 1 }
        user_session = { user: build(:instructor, id: 1) }
        get :add_calibration, params: request_params, session: user_session
        expect(response).to redirect_to '/response/new?assignment_id=1&id=1&return=assignment_edit'
      end
    end
  end

  describe '#select_reviewer' do
    context 'when called with a valid contributor_id' do
      before(:each) do
        contributor_id = '1'
        allow(AssignmentTeam).to receive(:find).with(contributor_id).and_return(team)
        get :select_reviewer, params: { contributor_id: contributor_id }
      end
      it 'assigns the corresponding AssignmentTeam to @contributor' do
        expect(assigns(:contributor)).to eq(team)
      end

      it 'stores the @contributor in the session' do
        expect(session[:contributor]).to eq(team)
      end
    end

    context 'when called with an invalid contributor_id' do
      before(:each) do
        contributor_id = '-1'
        allow(AssignmentTeam).to receive(:find).with(contributor_id).and_return(nil)
        get :select_reviewer, params: { contributor_id: contributor_id }
      end
      it 'does not assign any value to @contributor' do
        expect(assigns(:contributor)).to be_nil
      end

      it 'does not store anything in the session' do
        expect(session[:contributor]).to be_nil
      end
    end
  end

  describe '#select_metareviewer' do
    context 'when given a valid response map id' do
      it 'should assign the response map to @mapping' do
        # Create a double representing a ResponseMap object
        response_map_value = { id: 1, reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 2, type: '', created_at: Time.now, updated_at: Time.now, calibrate_to: false, team_reviewing_enabled: false }
        response_map = double('ResponseMap', response_map_value)

        allow(ResponseMap).to receive(:find).with('1').and_return(response_map)
        get :select_metareviewer, params: { id: '1' }
        expect(assigns(:mapping)).to eq(response_map)
      end
    end

    context 'when given an invalid response map id' do
      it 'should raise an error' do
        allow(ResponseMap).to receive(:find).with('-1').and_return(nil)
        get :select_metareviewer, params: { id: '-1' }
        expect(assigns(:mapping)).to be_nil
      end
    end
  end

  describe '#add_reviewer and #get_reviewer' do
    before(:each) do
      allow(User).to receive_message_chain(:where, :first).with(name: 'expertiza').with(no_args).and_return(double('User', id: 1))
      @params = {
        id: 1,
        topic_id: 1,
        user: { name: 'expertiza' },
        contributor_id: 1
      }
    end

    context 'when team_user does not exist' do
      it 'shows an error message and redirects to review_mapping#list_mappings page' do
        allow(TeamsUser).to receive(:exists?).with(team_id: '1', user_id: 1).and_return(true)
        post :add_reviewer, params: @params
        expect(response).to redirect_to '/review_mapping/list_mappings?id=1'
      end
    end

    context 'when team_user exists and get_reviewer method returns a reviewer' do
      it 'creates a whole bunch of objects and redirects to review_mapping#list_mappings page' do
        allow(TeamsUser).to receive(:exists?).with(team_id: '1', user_id: 1).and_return(false)
        allow(SignUpSheet).to receive(:signup_team).with(1, 1, '1').and_return(true)
        user = double('User', id: 1)
        allow(User).to receive(:from_params).with(any_args).and_return(user)
        allow(AssignmentParticipant).to receive(:where).with(user_id: 1, parent_id: 1)
                                                       .and_return([reviewer])
        allow(ReviewResponseMap).to receive_message_chain(:where, :first)
          .with(reviewee_id: '1', reviewer_id: 1).with(no_args).and_return(nil)
        allow(ReviewResponseMap).to receive(:create).with(reviewee_id: '1', reviewer_id: 1, reviewed_object_id: 1).and_return(nil)
        post :add_reviewer, params: @params
        expect(response).to redirect_to '/review_mapping/list_mappings?id=1&msg='
      end
    end

    context 'when instructor tries to assign a student their own artifact for reviewing' do
      it 'flashes an error message' do
        allow(TeamsUser).to receive(:exists?).with(team_id: '1', user_id: 1).and_return(true)
        post :add_reviewer, params: @params
        expect(flash[:error]).to eq('You cannot assign this student to review his/her own artifact.')
        expect(response).to redirect_to '/review_mapping/list_mappings?id=1'
      end
    end
  end

  describe '#assign_reviewer_dynamically' do
    before(:each) do
      allow(AssignmentParticipant).to receive_message_chain(:where, :first)
        .with(user_id: '1', parent_id: 1).with(no_args).and_return(participant)
    end

    context 'when assignment has topics and no topic is selected by reviewer' do
      it 'shows an error message and redirects to student_review#list page' do
        allow(assignment).to receive(:topics?).and_return(true)
        allow(assignment).to receive(:can_choose_topic_to_review?).and_return(true)
        request_params = {
          assignment_id: 1,
          reviewer_id: 1
        }
        post :assign_reviewer_dynamically, params: request_params
        expect(flash[:error]).to eq('No topic is selected.  Please go back and select a topic.')
        expect(response).to redirect_to '/student_review/list?id=1'
      end
    end

    context 'when assignment has topics and a topic is selected by reviewer' do
      it 'assigns reviewer dynamically and redirects to student_review#list page' do
        allow(assignment).to receive(:topics?).and_return(true)
        topic = double('SignUpTopic')
        allow(SignUpTopic).to receive(:find).with('1').and_return(topic)
        allow(assignment).to receive(:assign_reviewer_dynamically).with(participant, topic).and_return(true)
        allow(ReviewResponseMap).to receive(:reviewer_id).with(1).and_return(0)
        allow(assignment).to receive(:num_reviews_allowed).and_return(1)
        request_params = {
          assignment_id: 1,
          reviewer_id: 1,
          topic_id: 1
        }
        post :assign_reviewer_dynamically, params: request_params
        expect(response).to redirect_to '/student_review/list?id=1'
      end
    end

    context 'when assignment does not have topics' do
      it 'runs another algorithms and redirects to student_review#list page' do
        allow(assignment).to receive(:topics?).and_return(false)
        allow(participant).to receive(:set_current_user)
        team1 = double('AssignmentTeam')
        team2 = double('AssignmentTeam')
        teams = [team1, team2]
        allow(assignment).to receive(:candidate_assignment_teams_to_review).with(participant).and_return(teams)
        allow(teams).to receive_message_chain(:to_a, :sample).and_return(team2)
        allow(assignment).to receive(:assign_reviewer_dynamically_no_topic).with(participant, team2).and_return(true)
        allow(ReviewResponseMap).to receive(:reviewer_id).with(1).and_return(0)
        allow(assignment).to receive(:num_reviews_allowed).and_return(1)
        request_params = {
          assignment_id: 1,
          reviewer_id: 1,
          topic_id: 1
        }
        post :assign_reviewer_dynamically, params: request_params
        expect(response).to redirect_to '/student_review/list?id=1'
      end
    end

    context 'when number of reviews are less than the assignment policy' do
      it 'redirects to student review page' do
        allow(assignment).to receive(:topics?).and_return(true)
        topic = double('SignUpTopic')
        allow(SignUpTopic).to receive(:find).with('1').and_return(topic)
        allow(ReviewResponseMap).to receive(:where).with(reviewer_id: 1, reviewed_object_id: 1)
                                                   .and_return([])
        allow(assignment).to receive(:assign_reviewer_dynamically).with(participant, topic).and_return(true)
        allow(assignment).to receive(:num_reviews_allowed).and_return(1)
        request_params = {
          assignment_id: 1,
          reviewer_id: 1,
          topic_id: 1
        }
        post :assign_reviewer_dynamically, params: request_params
        expect(response).to redirect_to '/student_review/list?id=1'
      end
    end

    context 'when number of reviews are greater than the assignment policy' do
      it 'shows a flash error and redirects to student review page' do
        allow(assignment).to receive(:topics?).and_return(true)
        topic = double('SignUpTopic')
        allow(SignUpTopic).to receive(:find).with('1').and_return(topic)
        allow(ReviewResponseMap).to receive(:where).with(reviewer_id: 1, reviewed_object_id: 1)
                                                   .and_return([1, 2, 3])
        allow(assignment).to receive(:assign_reviewer_dynamically).with(participant, topic).and_return(true)
        allow(assignment).to receive(:num_reviews_allowed).and_return(1)
        request_params = {
          assignment_id: 1,
          reviewer_id: 1,
          topic_id: 1
        }
        post :assign_reviewer_dynamically, params: request_params
        expect(response).to redirect_to '/student_review/list?id=1'
        expect(flash[:error]).to be_present
      end
    end

    context 'when user has outstanding reviews less than assignment policy' do
      it 'redirects to student review page' do
        allow(assignment).to receive(:topics?).and_return(true)
        topic = double('SignUpTopic')
        allow(SignUpTopic).to receive(:find).with('1').and_return(topic)
        allow(ReviewResponseMap).to receive(:where).with(reviewer_id: 1, reviewed_object_id: 1)
                                                   .and_return(:review_response_map)
        allow(assignment).to receive(:assign_reviewer_dynamically).with(participant, topic).and_return(true)
        allow(assignment).to receive(:num_reviews_allowed).and_return(1)
        allow(assignment).to receive(:max_outstanding_reviews).and_return(0)

        request_params = {
          assignment_id: 1,
          reviewer_id: 1,
          topic_id: 1
        }
        post :assign_reviewer_dynamically, params: request_params
        expect(response).to redirect_to '/student_review/list?id=1'
      end
    end

    context 'when user has outstanding reviews greater than assignment policy' do
      it 'redirects to student review page and shows flash error' do
        allow(assignment).to receive(:topics?).and_return(true)
        topic = double('SignUpTopic')
        allow(SignUpTopic).to receive(:find).with('1').and_return(topic)
        allow(ReviewResponseMap).to receive(:where).with(reviewer_id: 1, reviewed_object_id: 1)
                                                   .and_return(:review_response_map)
        allow(assignment).to receive(:assign_reviewer_dynamically).with(participant, topic).and_return(true)
        allow(assignment).to receive(:num_reviews_allowed).and_return(1)
        allow(assignment).to receive(:max_outstanding_reviews).and_return(3)

        request_params = {
          assignment_id: 1,
          reviewer_id: 1,
          topic_id: 1
        }
        post :assign_reviewer_dynamically, params: request_params
        expect(flash[:error]).to be_present
        expect(response).to redirect_to '/student_review/list?id=1'
      end
    end
  end

  describe 'review_allowed?' do
    let(:assignment) { double('Assignment', id: 1, num_reviews_allowed: 3) }
    let(:reviewer) { double('User', id: 1) }
    context 'when the reviewer has not reached the maximum number of reviews allowed for the assignment' do
      it 'returns true' do
        allow(ReviewResponseMap).to receive(:where).and_return([double, double])
        expect(controller.review_allowed?(assignment, reviewer)).to be_truthy
      end
    end

    context 'when the reviewer has reached the maximum number of reviews allowed for the assignment' do
      it 'returns false' do
        allow(ReviewResponseMap).to receive(:where).and_return([double, double])
        allow(assignment).to receive(:num_reviews_allowed).and_return(2)
        expect(controller.review_allowed?(assignment, reviewer)).to be_falsey
      end
    end
  end

  describe '#check_outstanding_reviews?' do
    let(:reviewer) { double('Participant', id: 1, name: 'reviewer') }
    let(:assignment) { double('Assignment', id: 1, num_reviews_allowed: 3) }
    context 'when there are no review mappings for the assignment and reviewer' do
      it 'returns true' do
        allow(ReviewResponseMap).to receive(:where).with(reviewer_id: reviewer.id, reviewed_object_id: assignment.id).and_return([])
        expect(controller.check_outstanding_reviews?(assignment, reviewer)).to be true
      end
    end

    context 'when there are review mappings for the assignment and reviewer' do
      let(:response) { double('Response', is_submitted: true) }
      let(:in_progress_response) { double('Response', is_submitted: false) }
      let(:review_response_maps_complete) do
        [
          double('ReviewResponseMap', id: 1, response: [response, response]),
          double('ReviewResponseMap', id: 2, response: [response, response])
        ]
      end
      let(:review_response_maps_incomplete) do
        [
          double('ReviewResponseMap', id: 1, response: [response, in_progress_response]),
        ]
      end

      context 'when all reviews are completed' do
        it 'returns false' do
          allow(ReviewResponseMap).to receive(:where).with(reviewer_id: reviewer.id, reviewed_object_id: assignment.id).and_return(review_response_maps_complete)
          expect(controller.check_outstanding_reviews?(assignment, reviewer)).to be false
        end
      end
      context 'when some reviews are in progress' do
        it 'returns true' do
          allow(ReviewResponseMap).to receive(:where).with(reviewer_id: reviewer.id, reviewed_object_id: assignment.id).and_return(review_response_maps_incomplete)
          expect(controller.check_outstanding_reviews?(assignment, reviewer)).to be true
        end
      end
    end
  end

  describe '#assign_quiz_dynamically' do
    before(:each) do
      allow(AssignmentParticipant).to receive_message_chain(:where, :first)
        .with(user_id: '1', parent_id: 1).with(no_args).and_return(participant)
      @params = {
        assignment_id: 1,
        reviewer_id: 1,
        questionnaire_id: 1,
        participant_id: 1
      }
    end

    context 'when corresponding response map exists' do
      it 'shows a flash error and redirects to student_quizzes page' do
        allow(ResponseMap).to receive_message_chain(:where, :first).with(reviewed_object_id: '1', reviewer_id: '1')
          .with(no_args).and_return(double('ResponseMap'))

        post :assign_quiz_dynamically, params: @params
        expect(flash[:error]).to eq('You have already taken that quiz.')
        expect(response).to redirect_to('/student_quizzes?id=1')
      end
    end

    context 'when corresponding response map does not exist' do
      it 'creates a new QuizResponseMap and redirects to student_quizzes page' do
        questionnaire = double('Questionnaire', id: 1, instructor_id: 1)
        allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
        allow(Questionnaire).to receive(:find_by).with(instructor_id: 1).and_return(questionnaire)
        allow_any_instance_of(QuizResponseMap).to receive(:save).and_return(true)
        post :assign_quiz_dynamically, params: @params
        expect(flash[:error]).to be nil
        expect(response).to redirect_to('/student_quizzes?id=1')
      end
		end

    context "when the reviewer has already taken the quiz" do
      it "displays an error message" do
        allow(ResponseMap).to receive_message_chain(:where, :first).with(reviewed_object_id: '1', reviewer_id: '1')
                                                                   .with(no_args).and_return(double('ResponseMap'))

        post :assign_quiz_dynamically, params: @params
        expect(flash[:error]).to eq('You have already taken that quiz.')
        expect(response).to redirect_to('/student_quizzes?id=1')
      end
    end

    context "when the reviewer has not taken the quiz yet" do
      it "creates a new QuizResponseMap" do
        questionnaire = double('Questionnaire', id: 2, instructor_id: 2)

        allow(Questionnaire).to receive(:find).with('2').and_return(questionnaire)
        allow(Questionnaire).to receive(:find_by).with(instructor_id: 2).and_return(questionnaire)
        allow_any_instance_of(QuizResponseMap).to receive(:save).and_return(true)
        @params = {
          assignment_id: 1,
          reviewer_id: 2,
          questionnaire_id: 2,
          participant_id: 2
        }


        post :assign_quiz_dynamically, params: @params
        expect(flash[:error]).to be nil
        expect(response).to redirect_to('/student_quizzes?id=1')
			end
		end

    context "when an error occurs during the assignment process" do
      it "displays an alert message" do
        # Test scenario 3
      end
    end

    context 'when the reviewer has already taken the quiz' do
      it 'displays an error message' do
        allow(ResponseMap).to receive_message_chain(:where, :first).with(reviewed_object_id: '1', reviewer_id: '1').with(no_args).and_return(double('ResponseMap'))

        post :assign_quiz_dynamically, params: @params
        expect(flash[:error]).to eq('You have already taken that quiz.')
        expect(response).to redirect_to('/student_quizzes?id=1')
      end
    end

    context 'when the reviewer has not taken the quiz yet' do
      it 'creates a new QuizResponseMap' do
        questionnaire = double('Questionnaire', id: 2, instructor_id: 2)
        allow(Questionnaire).to receive(:find).with('2').and_return(questionnaire)
        allow(Questionnaire).to receive(:find_by).with(instructor_id: 2).and_return(questionnaire)
        allow_any_instance_of(QuizResponseMap).to receive(:save).and_return(true)
        @params = {
          assignment_id: 1,
          reviewer_id: 2,
          questionnaire_id: 2,
          participant_id: 2
        }

        post :assign_quiz_dynamically, params: @params
        expect(flash[:error]).to be nil
        expect(response).to redirect_to('/student_quizzes?id=1')
      end
    end
  end

  describe '#add_metareviewer' do
    before(:each) do
      allow(ResponseMap).to receive(:find).with('1').and_return(review_response_map)
    end

    it 'redirects to review_mapping#list_mappings page' do
      user = double('User', id: 1, name: 'no one')
      allow(User).to receive(:from_params).with(any_args).and_return(user)
      # allow_any_instance_of(ReviewMappingController).to receive(:url_for).with(action: 'add_user_to_assignment', id: 1, user_id: 1).and_return('')
      allow_any_instance_of(ReviewMappingController).to receive(:get_reviewer)
        .with(user, assignment, 'http://test.host/review_mapping/add_user_to_assignment?id=1&user_id=1')
        .and_return(double('AssignmentParticipant', id: 1, name: 'no one'))
      allow(ReviewResponseMap).to receive(:where).with(reviewed_object_id: 1, reviewer_id: 1).and_return([nil])
      request_params = { id: 1 }
      post :add_metareviewer, params: request_params
      expect(response).to redirect_to('/review_mapping/list_mappings?id=1&msg=')
    end
  end

  describe '#assign_metareviewer_dynamically' do
    context "when there are reviews to Meta review" do
      let(:assignment) { build(:assignment) }
      let(:metareviewer) { build(:participant) }
      it "assigns the metareviewer dynamically to the assignment" do
        allow(Assignment).to receive(:find).with(any_args).and_return(assignment)
        allow(AssignmentParticipant).to receive(:where).with(user_id: "1", parent_id: assignment.id).and_return([metareviewer])
        
        expect(assignment).to receive(:assign_metareviewer_dynamically).with(metareviewer)
        
        post :assign_metareviewer_dynamically, params: { assignment_id: assignment.id, metareviewer_id: 1 }
        
        expect(response).to redirect_to(controller: 'student_review', action: 'list', id: metareviewer.id)
      end
    end

    context "when there are no reviews to Meta review" do
      let(:assignment) { build(:assignment) }
      it "displays a flash warning instead of crashing the page" do
        allow(Assignment).to receive(:find).with(any_args).and_return(assignment)
        allow(AssignmentParticipant).to receive(:where).with(any_args).and_return([]) 

        post :assign_metareviewer_dynamically, params: { assignment_id: assignment.id, metareviewer_id: 1 }
      
        expect(flash[:error]).to eq("There are no reviews to metareview at this time for this assignment.")
        expect(response).to redirect_to(controller: 'student_review', action: 'list', id: nil)
      end
    end

    context "when an error occurs during assignment of metareviewer" do
      let(:assignment) { build(:assignment) }
      let(:metareviewer) { build(:participant) }
      it "displays an error message in the flash" do
        # Test scenario 3
        allow(Assignment).to receive(:find).with(any_args).and_return(assignment)
        allow(AssignmentParticipant).to receive(:where).with(any_args).and_return([metareviewer]) 
        allow(assignment).to receive(:assign_metareviewer_dynamically).and_raise(StandardError, "Assign Metareviewer Error")

        post :assign_metareviewer_dynamically, params: { assignment_id: assignment.id, metareviewer_id: 1 }
      
        expect(flash[:error]).to eq("Assign Metareviewer Error")
        expect(response).to redirect_to(controller: 'student_review', action: 'list', id: metareviewer.id)
      end
    end

    it 'redirects to student_review#list page' do
      metareviewer = double('AssignmentParticipant', id: 1)
      allow(AssignmentParticipant).to receive(:where).with(user_id: '1', parent_id: 1).and_return([metareviewer])
      allow(assignment).to receive(:assign_metareviewer_dynamically).with(metareviewer).and_return(true)
      request_params = {
        assignment_id: 1,
        metareviewer_id: 1
      }
      post :assign_metareviewer_dynamically, params: request_params
      expect(response).to redirect_to('/student_review/list?id=1')
    end
  end

  describe '#delete_outstanding_reviewers' do
    before(:each) do
      allow(AssignmentTeam).to receive(:find).with('1').and_return(team)
      allow(team).to receive(:review_mappings).and_return([double('ReviewResponseMap', id: 1)])
    end

    context 'when review response map has corresponding responses' do
      it 'shows a flash error and redirects to review_mapping#list_mappings page' do
        allow(Response).to receive(:exists?).with(map_id: 1).and_return(true)
        request_params = {
          id: 1,
          contributor_id: 1
        }
        post :delete_outstanding_reviewers, params: request_params
        expect(flash[:success]).to be nil
        expect(flash[:error]).to eq('1 reviewer(s) cannot be deleted because they have already started a review.')
        expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
      end
    end

    context 'when review response map does not have corresponding responses' do
      it 'shows a flash success and redirects to review_mapping#list_mappings page' do
        allow(Response).to receive(:exists?).with(map_id: 1).and_return(false)
        review_response_map = double('ReviewResponseMap')
        allow(ReviewResponseMap).to receive(:find).with(1).and_return(review_response_map)
        allow(review_response_map).to receive(:destroy).and_return(true)
        request_params = {
          id: 1,
          contributor_id: 1
        }
        post :delete_outstanding_reviewers, params: request_params
        expect(flash[:error]).to be nil
        expect(flash[:success]).to eq('All review mappings for "no one" have been deleted.')
        expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
      end
    end
  end

  describe '#delete_all_metareviewers' do
    before(:each) do
      allow(ResponseMap).to receive(:find).with('1').and_return(review_response_map)
      @metareview_response_maps = [metareview_response_map]
      allow(MetareviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return(@metareview_response_maps)
    end

    context 'when failed times are bigger than 0' do
      it 'shows an error flash message and redirects to review_mapping#list_mappings page' do
        @metareview_response_maps.each do |metareview_response_map|
          allow(metareview_response_map).to receive(:delete).with(true).and_raise('Boom')
        end
        request_params = { id: 1, force: true }
        post :delete_all_metareviewers, params: request_params
        expect(flash[:note]).to be nil
        expect(flash[:error]).to eq('A delete action failed:<br/>1 metareviews exist for these mappings. '\
          "Delete these mappings anyway?&nbsp;<a href='http://test.host/review_mapping/delete_all_metareviewers?force=1&id=1'>Yes</a>&nbsp;|&nbsp;"\
          "<a href='http://test.host/review_mapping/delete_all_metareviewers?id=1'>No</a><br/>")
        expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
      end
    end

    context 'when failed time is equal to 0' do
      it 'shows a note flash message and redirects to review_mapping#list_mappings page' do
        @metareview_response_maps.each do |metareview_response_map|
          allow(metareview_response_map).to receive(:delete).with(true)
        end
        request_params = { id: 1, force: true }
        post :delete_all_metareviewers, params: request_params
        expect(flash[:error]).to be nil
        expect(flash[:note]).to eq('All metareview mappings for contributor "reviewee" and reviewer "reviewer" have been deleted.')
        expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
      end
    end
  end

  describe '#unsubmit_review' do
    let(:review_response) { double('Response') }
    before(:each) do
      allow(Response).to receive(:where).with(map_id: '1').and_return([review_response])
      allow(ReviewResponseMap).to receive(:find_by).with(id: '1').and_return(review_response_map)
    end

    context 'when attributes of response are updated successfully' do
      it 'shows a success flash.now message and renders a .js.erb file' do
        allow(review_response).to receive(:update_attribute).with('is_submitted', false).and_return(true)
        params = { id: 1 }
        # xhr - XmlHttpRequest (AJAX)
        get :unsubmit_review, params: { id: 1 }, xhr: true
        expect(flash.now[:error]).to be nil
        expect(flash.now[:success]).to eq('The review by "reviewer" for "reviewee" has been unsubmitted.')
        expect(response).to render_template('unsubmit_review.js.erb')
      end
    end

    context 'when attributes of response are not updated successfully' do
      it 'shows an error flash.now message and renders a .js.erb file' do
        allow(review_response).to receive(:update_attribute).with('is_submitted', false).and_return(false)
        params = { id: 1 }
        # xhr - XmlHttpRequest (AJAX)
        get :unsubmit_review, params: { id: 1 }, xhr: true
        expect(flash.now[:success]).to be nil
        expect(flash.now[:error]).to eq('The review by "reviewer" for "reviewee" could not be unsubmitted.')
        expect(response).to render_template('unsubmit_review.js.erb')
      end
    end
  end

  describe '#delete_reviewer' do
    before(:each) do
      allow(ReviewResponseMap).to receive(:find_by).with(id: '1').and_return(review_response_map)
      request.env['HTTP_REFERER'] = 'www.google.com'
    end

    context 'when corresponding response does not exist to current review response map' do
      it 'shows a success flash message and redirects to previous page' do
        allow(Response).to receive(:exists?).with(map_id: 1).and_return(false)
        allow(review_response_map).to receive(:destroy).and_return(true)
        request_params = { id: 1 }
        post :delete_reviewer, params: request_params
        expect(flash[:success]).to eq('The review mapping for "reviewee" and "reviewer" has been deleted.')
        expect(flash[:error]).to be nil
        expect(response).to redirect_to('www.google.com')
      end
    end

    context 'when corresponding response exists to current review response map' do
      it 'shows an error flash message and redirects to previous page' do
        allow(Response).to receive(:exists?).with(map_id: 1).and_return(true)
        request_params = { id: 1 }
        post :delete_reviewer, params: request_params
        expect(flash[:error]).to eq('This review has already been done. It cannot been deleted.')
        expect(flash[:success]).to be nil
        expect(response).to redirect_to('www.google.com')
      end
    end
  end

  describe '#delete_metareviewer' do
    before(:each) do
      allow(MetareviewResponseMap).to receive(:find).with('1').and_return(metareview_response_map)
    end

    context 'when metareview_response_map can be deleted successfully' do
      it 'show a note flash message and redirects to review_mapping#list_mappings page' do
        allow(metareview_response_map).to receive(:delete).and_return(true)
        request_params = { id: 1 }
        post :delete_metareviewer, params: request_params
        expect(flash[:note]).to eq('The metareview mapping for reviewee and reviewer has been deleted.')
        expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
      end
    end

    context 'when metareview_response_map cannot be deleted successfully' do
      it 'show a note flash message and redirects to review_mapping#list_mappings page' do
        allow(metareview_response_map).to receive(:delete).and_raise('Boom')
        request_params = { id: 1 }
        post :delete_metareviewer, params: request_params
        expect(flash[:error]).to eq("A delete action failed:<br/>Boom<a href='/review_mapping/delete_metareview/1'>Delete this mapping anyway>?")
        expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
      end
    end
  end

  # Tests can be added
  describe '#delete_metareview' do
    it 'redirects to review_mapping#list_mappings page after deletion' do
      allow(MetareviewResponseMap).to receive(:find).with('1').and_return(metareview_response_map)
      allow(metareview_response_map).to receive(:delete).and_return(true)
      request_params = { id: 1 }
      post :delete_metareview, params: request_params
      expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
    end

    it "deletes the metareview mapping" do
      # Test scenario 1
      # Given a valid metareview mapping ID
      # When the delete_metareview method is called
      # Then the metareview mapping should be deleted
      valid_mapping = create(:meta_review_response_map) # You need to implement a method to create a valid metareview mapping
      expect {
        delete :delete_metareview, params: { id: valid_mapping.id }
      }.to change(MetareviewResponseMap, :count).by(-1)  
      # expect(flash[:note]).to eq("The metareview mapping for #{valid_mapping.reviewee.name} and #{valid_mapping.reviewer.name} has been deleted.")
      
      # Test scenario 2
      # Given an invalid metareview mapping ID
      # When the delete_metareview method is called
      # Then no metareview mapping should be deleted
      invalid_mapping_id = -1
      expect {
        delete :delete_metareview, params: { id: invalid_mapping_id }
      }.to raise_error(ActiveRecord::RecordNotFound)
  
      # Test scenario 3
      # Given a metareview mapping ID that does not exist
      # When the delete_metareview method is called
      # Then no metareview mapping should be deleted
      non_existing_mapping_id = 9999
      expect {
        delete :delete_metareview, params: { id: non_existing_mapping_id }
      }.to raise_error(ActiveRecord::RecordNotFound)

      # Test scenario 4
      # Given a metareview mapping ID that is associated with an assignment
      # When the delete_metareview method is called
      # Then the associated assignment should be updated
      mapping_with_assignment = create(:meta_review_response_map, review_mapping: create(:review_response_map))
      assignment_id_before = mapping_with_assignment.assignment.id
      delete :delete_metareview, params: { id: mapping_with_assignment.id }
      assignment_id_after = MetareviewResponseMap.find_by(id: mapping_with_assignment.id)&.assignment&.id
      expect(assignment_id_before).not_to eq(assignment_id_after)
  
      # Test scenario 5
      # Given a metareview mapping ID that is not associated with an assignment
      # When the delete_metareview method is called
      # Then no assignment should be updated
      expect {
        mapping_without_assignment = create(:meta_review_response_map, review_mapping: create(:review_response_map, assignment: nil))
      }.to raise_error(ActiveRecord::NotNullViolation)

  
      # Test scenario 6
      # Given a metareview mapping ID that is associated with a response
      # When the delete_metareview method is called
      # Then the associated response should not be deleted
      mapping_with_response = create(:meta_review_response_map, review_mapping: create(:review_response_map))
      expect {
        delete :delete_metareview, params: { id: mapping_with_response.id }
      }.not_to change(Response, :count)
      end

  end

  describe '#list_mappings' do
    it 'renders review_mapping#list_mappings page' do
      allow(AssignmentTeam).to receive(:where).with(parent_id: 1).and_return([team, team1])
      request_params = {
        id: 1,
        msg: 'No error!'
      }
      get :list_mappings, params: request_params
      expect(flash[:error]).to eq('No error!')
      expect(response).to render_template(:list_mappings)
    end

    context "when there is a flash error message" do
      it "sets the flash error message when id is 0" do
        get :list_mappings, params: { id: "0" }
        expect(flash[:error]).to eq("Assignment needs to be created in order to assign reviewers!")
      end
      it "sets the flash error message when id not equal to 0" do
        error_message = "Test Error Message"
        get :list_mappings, params: { id: "1", msg: error_message }
      expect(flash[:error]).to eq(error_message)
      end
    end
  
    context "when there is no flash error message" do
      it "does not set the flash error message" do
        assignment = create(:assignment)
        get :list_mappings, params: { id: assignment.id }
        expect(flash[:error]).to be_nil
      end
    end
  
    context "when the assignment exists" do
      before do
        @assignment = create(:assignment)
        allow(Assignment).to receive(:find).with('1').and_return(@assignment)
        get :list_mappings, params: { id: @assignment.id }
      end

      it "finds the assignment with the given id" do
        expect(assigns(:assignment)).to eq(@assignment)
      end
  
      it "retrieves all assignment teams associated with the assignment" do
        expect(assigns(:items)).to eq(AssignmentTeam.where(parent_id: @assignment.id))
      end
  
      it "sorts the assignment teams by name" do
        sorted_items = assigns(:items).sort_by(&:name)
        expect(assigns(:items)).to eq(sorted_items)
      end
    end  

  end

  describe '#automatic_review_mapping' do
    before(:each) do
      allow(AssignmentParticipant).to receive(:where).with(parent_id: 1).and_return([participant, participant1, participant2])
    end

    context 'when teams is not empty' do
      before(:each) do
        allow(AssignmentTeam).to receive(:where).with(parent_id: 1).and_return([team, team1])
      end

      context 'when all nums in params are 0' do
        it 'shows an error flash message and redirects to review_mapping#list_mappings page' do
          request_params = {
            id: 1,
            max_team_size: 1,
            num_reviews_per_student: 0,
            num_reviews_per_submission: 0,
            num_calibrated_artifacts: 0,
            num_uncalibrated_artifacts: 0
          }
          post :automatic_review_mapping, params: request_params
          expect(flash[:error]).to eq('Please choose either the number of reviews per student or the number of reviewers per team (student).')
          expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
        end
      end

      context 'when all nums in params are 0 except student_review_num' do
        it 'runs automatic review mapping strategy and redirects to review_mapping#list_mappings page' do
          allow_any_instance_of(ReviewMappingController).to receive(:automatic_review_mapping_strategy).with(any_args).and_return(true)
          request_params = {
            id: 1,
            max_team_size: 1,
            num_reviews_per_student: 1,
            num_reviews_per_submission: 0,
            num_calibrated_artifacts: 0,
            num_uncalibrated_artifacts: 0
          }
          post :automatic_review_mapping, params: request_params
          expect(flash[:error]).to be nil
          expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
        end
      end

      context 'when calibrated request_params are not 0' do
        it 'runs automatic review mapping strategy and redirects to review_mapping#list_mappings page' do
          allow(ReviewResponseMap).to receive(:where).with(reviewed_object_id: 1, calibrate_to: 1)
                                                     .and_return([double('ReviewResponseMap', reviewee_id: 2)])
          allow(AssignmentTeam).to receive(:find).with(2).and_return(team)
          allow_any_instance_of(ReviewMappingController).to receive(:automatic_review_mapping_strategy).with(any_args).and_return(true)
          request_params = {
            id: 1,
            max_team_size: 1,
            num_reviews_per_student: 1,
            num_reviews_per_submission: 0,
            num_calibrated_artifacts: 1,
            num_uncalibrated_artifacts: 1
          }
          post :automatic_review_mapping, params: request_params
          expect(flash[:error]).to be nil
          expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
        end
      end

      context 'when student review num is greater than or equal to team size' do
        it 'throws error stating that student review number cannot be greater than or equal to team size' do
          allow(ReviewResponseMap).to receive(:where)
            .with(reviewed_object_id: 1, calibrate_to: 1)
            .and_return([double('ReviewResponseMap', reviewee_id: 2)])
          allow(AssignmentTeam).to receive(:find).with(2).and_return(team)
          request_params = {
            id: 1,
            max_team_size: 1,
            num_reviews_per_student: 45,
            num_reviews_per_submission: 0,
            num_calibrated_artifacts: 0,
            num_uncalibrated_artifacts: 0
          }
          post :automatic_review_mapping, params: request_params
          expect(flash[:error]).to eq('You cannot set the number of reviews done ' \
                                      'by each student to be greater than or equal to total number of teams ' \
                                      '[or "participants" if it is an individual assignment].')
          expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
        end
      end
    end

    context 'when teams is empty, max team size is 1 and when review params are not 0' do
      it 'shows an error flash message and redirects to review_mapping#list_mappings page' do
        allow(TeamsUser).to receive(:team_id).with(1, 2).and_return(true)
        allow(TeamsUser).to receive(:team_id).with(1, 3).and_return(false)
        allow(AssignmentTeam).to receive(:create_team_and_node).with(1).and_return(double('AssignmentTeam', id: 1))
        allow(ApplicationController).to receive_message_chain(:helpers, :create_team_users).with(no_args).with(user, 1).and_return(true)
        request_params = {
          id: 1,
          max_team_size: 1,
          num_reviews_per_student: 1,
          num_reviews_per_submission: 4,
          num_calibrated_artifacts: 0,
          num_uncalibrated_artifacts: 0
        }
        post :automatic_review_mapping, params: request_params
        expect(flash[:error]).to eq('Please choose either the number of reviews per student or the number of reviewers per team (student), not both.')
        expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
      end
    end
  end

  describe '#automatic_review_mapping_staggered' do
    it 'shows a note flash message and redirects to review_mapping#list_mappings page' do
      allow(assignment).to receive(:assign_reviewers_staggered).with('4', '2').and_return('Awesome!')
      request_params = {
        id: 1,
        assignment: {
          num_reviews: 4,
          num_metareviews: 2
        }
      }
      post :automatic_review_mapping_staggered, params: request_params
      expect(flash[:note]).to eq('Awesome!')
      expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
    end
  end

  describe '#save_grade_and_comment_for_reviewer' do
    it 'redirects to reports#response_report page' do
      # Use factories to create stubs (user must be instructor or above to perform this action)
      review_grade = build(:review_grade)
      instructor = build(:instructor)
      # Stub out other items
      allow(ReviewGrade).to receive(:find_by).with(participant_id: '1').and_return(review_grade)
      allow(review_grade).to receive(:save).and_return(true)
      request_params = {
        review_grade: {
          participant_id: 1,
          grade_for_reviewer: 90,
          comment_for_reviewer: 'keke'
        }
      }

      # Perform test
      session_params = {user: stub_current_user(instructor, instructor.role.name, instructor.role) }
      post :save_grade_and_comment_for_reviewer, params: request_params, session: session_params
      expect(flash[:note]).to be nil
      expect(response).to redirect_to('/reports/response_report')
    end

    context "when the review grade is retrieved" do
      let(:review_grade_object) { build(:review_grade) }
      let(:instructor) { build(:instructor) }
      let(:session_params) do
        { user: stub_current_user(instructor, instructor.role.name, instructor.role) }
      end
    
      let(:request_params) do
        {
          review_grade: {
            participant_id: '1',
            assignment_id: '1',
          }
        }
      end
      before(:each) do
        allow(ReviewGrade).to receive(:find_or_create_by).with(participant_id: '1').and_return(review_grade_object)
        allow(controller).to receive(:review_mapping_params).and_return(
          {
          participant_id: 1,
          grade_for_reviewer: 90,
          comment_for_reviewer: 'Very Good',
          }
        )
        allow(review_grade_object).to receive(:save).and_return(true)

        post :save_grade_and_comment_for_reviewer, params: request_params, session: session_params
      end

      it "creates a new review grade with the given participant_id" do
        expect(ReviewGrade.count).to eq(1)
      end
  
      it "sets the attributes of the review grade with the given review_mapping_params" do
        created_review_grade = ReviewGrade.last
        expect(created_review_grade.grade_for_reviewer).to eq(90)
        expect(created_review_grade.comment_for_reviewer).to eq('Very Good')
      end
  
      it "sets the review_graded_at attribute to the current time" do
        created_review_grade = ReviewGrade.last
        expect(created_review_grade.review_graded_at).to be_within(1.second).of(Time.now)
      end
  
      it "sets the reviewer_id attribute to the current user's id" do
        created_review_grade = ReviewGrade.last
        expect(created_review_grade.reviewer_id).to eq(instructor.id)
      end
  
      it "saves the review grade successfully" do
        # expect(flash[:success]).to eq('Grade and comment for reviewer successfully saved.')
      end
  
      it "sets a success flash message" do
        expect(flash[:success]).to eq('Grade and comment for reviewer successfully saved.')
      end
  
      it "redirects to the 'response_report' action in the 'reports' controller for HTML format" do
        expect(response).to redirect_to(controller: 'reports', action: 'response_report', id: '1')
      end
    end
  end

  describe '#start_self_review' do
    before(:each) do
      allow(Team).to receive(:find_team_for_assignment_and_user).with(1, '1').and_return([double('Team', id: 1)])
    end

    context 'when self review response map does not exist' do
      it 'creates a new record and redirects to submitted_content#edit page' do
        allow(SelfReviewResponseMap).to receive(:where).with(reviewee_id: 1, reviewer_id: '1').and_return([nil])
        allow(SelfReviewResponseMap).to receive(:create).with(reviewee_id: 1, reviewer_id: '1', reviewed_object_id: 1).and_return(true)
        request_params = {
          assignment_id: 1,
          reviewer_userid: 1,
          reviewer_id: 1
        }
        post :start_self_review, params: request_params
        expect(response).to redirect_to('/submitted_content/1/edit')
      end
    end

    context 'when self review response map exists' do
      it 'redirects to submitted_content#edit page' do
        allow(SelfReviewResponseMap).to receive(:where).with(reviewee_id: 1, reviewer_id: '1').and_return([double('SelfReviewResponseMap')])
        request_params = {
          assignment_id: 1,
          reviewer_userid: 1,
          reviewer_id: 1
        }
        post :start_self_review, params: request_params
        expect(response).to redirect_to('/submitted_content/1/edit?msg=Self+review+already+assigned%21')
      end
    end
  end
end
