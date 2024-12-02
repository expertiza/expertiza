describe ReviewBidsController do
  let(:student) { create(:student) }
  let(:another_student) { create(:student) }
  let(:instructor) { create(:instructor) }
  let(:teaching_assistant) { create(:teaching_assistant) }
  let(:admin) { create(:admin) }
  let(:superadmin) { create(:superadmin) }
  let(:assignment) { create(:assignment) }
  let(:participant) { create(:participant, assignment: assignment, user: student) }
  let(:participant_authorized) { create(:participant, can_review: true) }
  let(:participant_unauthorized) { create(:participant, can_review: false, can_mentor: true) }

  before do
    controller.session[:user] = student
  end

  describe 'action_allowed as a Student' do
    it 'does not allow assign_bidding or run_bidding_algorithm actions' do
      %w[assign_bidding run_bidding_algorithm].each do |action|
        controller.params = { id: '1', action: action }
        expect(controller.action_allowed?).to be false
      end
    end

    it 'allows show, index, set_priority, and list with participant authorization' do
      participant_authorized = create(:participant, can_review: true, user: student)
      allow(Participant).to receive(:find_by)
        .with(id: participant_authorized.id.to_s)
        .and_return(participant_authorized)

      %w[show index set_priority list].each do |action|
        controller.params = { id: participant_authorized.id.to_s, action: action }
        expect(controller.action_allowed?).to be true
      end
    end

    it 'does not allow list action when participant lacks necessary authorization' do
      participant_unauthorized = create(
        :participant,
        can_review: false,
        can_submit: false,
        can_mentor: true,
        user: student
      )

      controller.params = { id: participant_unauthorized.id.to_s, action: 'list' }
      allow(controller).to receive(:action_name).and_return('list')

      expect(participant_unauthorized.authorization).to eq('mentor')
      expect(controller.send(:list_authorization_check)).to be false
      expect(controller.action_allowed?).to be false
    end
  end

  describe 'action_allowed as an Instructor, Teaching Assistant, Administrator, or Super-Administrator' do
    it 'allows assign_bidding and run_bidding_algorithm actions' do
      %i[instructor teaching_assistant admin superadmin].each do |role|
        user = send(role)
        controller.session[:user] = user

        %w[assign_bidding run_bidding_algorithm].each do |action|
          controller.params = { id: '1', action: action }
          expect(controller.action_allowed?).to be true
        end
      end
    end

    it 'allows access to show, index, set_priority, and list without additional authorization' do
      %i[instructor teaching_assistant admin superadmin].each do |role|
        user = send(role)
        controller.session[:user] = user

        %w[show index set_priority list].each do |action|
          controller.params = { id: '1', action: action }
          expect(controller.action_allowed?).to be true
        end
      end
    end
  end

  describe 'action_allowed edge cases' do
    it 'does not allow actions for users who are not logged in' do
      controller.session[:user] = nil
      allow(controller).to receive(:current_user).and_return(nil)

      %w[assign_bidding run_bidding_algorithm show index set_priority list].each do |action|
        controller.params = { id: '1', action: action }
        expect(controller.action_allowed?).to be false
      end
    end

    it 'does not allow invalid actions' do
      controller.session[:user] = student
      allow(controller).to receive(:current_user).and_return(student)

      [nil, '', 'invalid_action'].each do |action|
        controller.params = { id: '1', action: action }
        expect(controller.action_allowed?).to be false
      end
    end
  end

  describe '#index' do
    # TC01: Valid Participant Access
    context 'when participant is valid and has access' do
      before do
        allow_any_instance_of(ParticipantService).to receive(:valid_participant?).and_return(true)
        allow_any_instance_of(ParticipantService).to receive(:participant).and_return(participant)
        allow_any_instance_of(ParticipantService).to receive(:assignment).and_return(assignment)
        allow_any_instance_of(ReviewService).to receive(:review_mappings).and_return([])
        allow_any_instance_of(ReviewService).to receive(:review_counts).and_return({ completed: 0 })
      end

      it 'assigns @assignment and renders the correct view' do
        get :index, params: { participant_id: participant.id }
        expect(assigns(:assignment)).to eq(assignment)
        expect(assigns(:review_mappings)).to eq([])
        expect(assigns(:num_reviews_completed)).to eq(0)
        expect(response).to render_template('sign_up_sheet/review_bids_others_work')
      end
    end

    # TC02: Invalid Participant Access (Participant does not exist)
    context 'when participant does not exist' do
      before do
        allow_any_instance_of(ParticipantService).to receive(:valid_participant?).and_return(false)
      end

      it 'redirects back with an error message' do
        get :index, params: { participant_id: -1 }
        expect(flash[:error]).to eq('Invalid participant access.')
        expect(response).to redirect_to(root_path)
      end
    end

    # TC03: Invalid Participant Access (Incorrect User ID)
    context 'when participant exists but user IDs do not match' do
      let(:other_participant) { create(:participant, assignment: assignment, user: another_student) }

      before do
        allow_any_instance_of(ParticipantService).to receive(:valid_participant?).and_return(false)
      end

      it 'redirects back with an error message' do
        get :index, params: { participant_id: other_participant.id }
        expect(flash[:error]).to eq('Invalid participant access.')
        expect(response).to redirect_to(root_path)
      end
    end

    # TC04: Participant With No Assignment
    context 'when participant exists but assignment is nil' do
      before do
        allow_any_instance_of(ParticipantService).to receive(:valid_participant?).and_return(true)
        allow_any_instance_of(ParticipantService).to receive(:assignment).and_return(nil)
      end

      it 'redirects back with an error message' do
        get :index, params: { participant_id: participant.id }
        expect(flash[:error]).to eq('Assignment not found.')
        expect(response).to redirect_to(root_path)
      end
    end

    # TC05: Review Mappings Without Reviewer
    context 'when reviewer is nil' do
      before do
        allow_any_instance_of(ParticipantService).to receive(:valid_participant?).and_return(true)
        allow_any_instance_of(ParticipantService).to receive(:participant).and_return(participant)
        allow_any_instance_of(ParticipantService).to receive(:assignment).and_return(assignment)
        allow_any_instance_of(ReviewService).to receive(:review_mappings).and_return([])
        allow_any_instance_of(ReviewService).to receive(:review_counts).and_return({ completed: 0 })
      end

      it 'assigns empty review mappings and num_reviews_completed as zero' do
        get :index, params: { participant_id: participant.id }
        expect(assigns(:review_mappings)).to eq([])
        expect(assigns(:num_reviews_completed)).to eq(0)
        expect(response).to render_template('sign_up_sheet/review_bids_others_work')
      end
    end

    # TC06: Correct View Renders
    context 'when services are setup correctly' do
      before do
        allow_any_instance_of(ParticipantService).to receive(:valid_participant?).and_return(true)
        allow_any_instance_of(ParticipantService).to receive(:participant).and_return(participant)
        allow_any_instance_of(ParticipantService).to receive(:assignment).and_return(assignment)
        allow_any_instance_of(ReviewService).to receive(:review_mappings).and_return([])
        allow_any_instance_of(ReviewService).to receive(:review_counts).and_return({ completed: 0 })
      end

      it 'renders the correct view without errors' do
        get :index, params: { participant_id: participant.id }
        expect(response).to render_template('sign_up_sheet/review_bids_others_work')
      end
    end

    # TC07: Edge Case - Participant is nil
    context 'when participant is nil' do
      before do
        allow_any_instance_of(ParticipantService).to receive(:participant).and_return(nil)
        allow_any_instance_of(ParticipantService).to receive(:valid_participant?).and_return(false)
      end

      it 'redirects back with an error message' do
        get :index, params: { participant_id: participant.id }
        expect(flash[:error]).to eq('Invalid participant access.')
        expect(response).to redirect_to(root_path)
      end
    end

    # TC08: Edge Case - Assignment Is Invalid
    context 'when assignment is invalid' do
      before do
        allow_any_instance_of(ParticipantService).to receive(:valid_participant?).and_return(true)
        allow_any_instance_of(ParticipantService).to receive(:participant).and_return(participant)
        allow_any_instance_of(ParticipantService).to receive(:assignment).and_return('assignment_not_found')
      end

      it 'redirects back with an error message' do
        get :index, params: { participant_id: participant.id }
        expect(flash[:error]).to eq('Assignment not found.')
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe '#show' do
    render_views
    it 'renders the bidding page' do
      get :show
      expect { get :show, format: :html }.to_not raise_error
      expect(response.body) =~ '/sign_up_sheet/review_bid_show'
    end
  end

  describe '#set_priority' do
    render_views
    it 'updates bids in bidding page' do
      get :set_priority
      expect { get :set_priority, format: :html }.to_not raise_error
      expect(response.body) =~ '/sign_up_sheet/review_bid_show'
    end
  end

  describe '#assign_bidding' do
    render_views
    it 'assigns bids' do
      get :assign_bidding
      expect(response).to have_http_status(302) # a redirect to :back
    end
  end

  describe '#run_bidding_algorithm' do
    render_views
    it 'connects to the webservice to run bidding algorithm' do
      post :run_bidding_algorithm
      expect(response).to have_http_status(302)
    end
  end
end
