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

    let(:mock_input) do
      {
        'tid' => [3969, 3970, 3971, 3972, 3973, 3974, 3975, 3976, 3977],
        'users' => {
          '36239' => {
            'tid' => [3970, 3972],
            'otid' => 3977,
            'priority' => [2, 1],
            'time' => [
              'Thu, 12 Nov 2020 12:01:06 EST -05:00',
              'Thu, 12 Nov 2020 12:01:07 EST -05:00'
            ]
          },
          '36240' => {
            'tid' => [],
            'otid' => 3976,
            'priority' => [],
            'time' => []
          },
          '36241' => {
            'tid' => [3969, 3971, 3972],
            'otid' => 3975,
            'priority' => [1, 3, 2],
            'time' => [
              'Thu, 12 Nov 2020 12:00:22 EST -05:00',
              'Thu, 12 Nov 2020 12:00:25 EST -05:00',
              'Thu, 12 Nov 2020 12:00:27 EST -05:00'
            ]
          },
          '36242' => {
            'tid' => [3969, 3971, 3973],
            'otid' => 3974,
            'priority' => [3, 2, 1],
            'time' => [
              'Wed, 11 Nov 2020 12:15:43 EST -05:00',
              'Thu, 12 Nov 2020 11:59:40 EST -05:00',
              'Thu, 12 Nov 2020 13:07:53 EST -05:00'
            ]
          },
          '36243' => {
            'tid' => [3971, 3969, 3970, 3976],
            'otid' => 3972,
            'priority' => [4, 3, 2, 1, 5],
            'time' => [
              'Wed, 11 Nov 2020 11:34:50 EST -05:00',
              'Wed, 11 Nov 2020 12:30:16 EST -05:00',
              'Wed, 11 Nov 2020 12:30:19 EST -05:00',
              'Thu, 12 Nov 2020 13:02:02 EST -05:00'
            ]
          }
        },
        'max_accepted_proposals' => 3
      }
    end

    context 'as a teaching_assistant' do
      before do
        controller.session[:user] = teaching_assistant
      end

      # TC01: Successful Assignment with Mock Data
      context 'When assignment is successful' do
        let!(:reviewers) { create_list(:participant, 5, assignment: assignment) }
        let!(:topics) { create_list(:sign_up_topic, 5, assignment: assignment) }

        let(:mock_output) do
          reviewer_topics = reviewers.index_by(&:id)
          reviewer_topics.transform_values { topics.sample(3).map(&:id) }
        end

        it 'assigns reviewers to topics and redirects with success' do
          allow(Assignment).to receive(:find_by).with(id: assignment.id).and_return(assignment)
          allow_any_instance_of(ReviewBidsController).to receive(:bidding_data).and_return(mock_input)
          allow_any_instance_of(ReviewBidsController).to receive(:run_bidding_algorithm).and_return(mock_output)
          allow_any_instance_of(ReviewBid).to receive(:assign_review_topics).with(mock_output).and_return(true)
          allow(assignment).to receive(:update!).with(can_choose_topic_to_review: false).and_return(true)

          # Trigger the POST action
          post :assign_bidding, params: { assignment_id: assignment.id }

          # Assert the response
          expect(response).to have_http_status(302) # Redirection
          expect(response).to redirect_to(root_path) # Fallback location
          expect(flash[:notice]).to eq('Reviewers were successfully assigned to topics.') # Flash notice
        end
      end

      # TC02: Invalid assignment_id
      context 'when assignment_id is unsuccessful' do
        it 'redirects back with an alert' do
          invalid_assignment_id = -1
          expect(ReviewBid).not_to receive(:assign_review_topics)
          post :assign_bidding, params: { assignment_id: invalid_assignment_id }

          expect(response).to have_http_status(302)
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq('Invalid assignment. Please check and try again.')
        end
      end

      # TC03: No Reviewers for Assignment
      context 'when there are no reviewers for assignment' do
        it 'redirects back with an alert' do
          AssignmentParticipant.where(parent_id: assignment.id).destroy_all # Simulate no reviewers

          expect(ReviewBid).not_to receive(:assign_review_topics)
          post :assign_bidding, params: { assignment_id: assignment.id }

          expect(response).to have_http_status(302)
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq('No reviewers available for the assignment.')
        end
      end

      # TC04: BiddingAlgorithmService Returns Invalid Data
      context 'when service returns invalid data' do
        let!(:reviewers) { create_list(:participant, 3, assignment: assignment) }
        let(:invalid_mock_output) { { 'bad_key' => 'bad_value' } }

        it 'redirects back with an alert due to invalid matched_topics' do
          allow_any_instance_of(ReviewBidsController).to receive(:bidding_data).and_return(mock_input)
          allow_any_instance_of(ReviewBidsController).to receive(:run_bidding_algorithm).and_return(invalid_mock_output)
          allow_any_instance_of(ReviewBid).to receive(:assign_review_topics).with(invalid_mock_output).and_raise(StandardError)

          post :assign_bidding, params: { assignment_id: assignment.id }

          expect(response).to have_http_status(302)
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq('Failed to assign reviewers. Please try again later.')
        end
      end

      # TC05: ReviewBid.assign_review_topics Fails
      context 'when topic or assignment is missing in assign_review_topics' do
        let!(:reviewers) { create_list(:participant, 3, assignment: assignment) }

        it 'redirects back with an alert for missing topic/assignment' do
          # Mock to trigger `ArgumentError` for missing topic/assignment
          allow_any_instance_of(ReviewBid).to receive(:assign_review_topics).and_raise(ArgumentError, 'Topic or assignment is missing')

          post :assign_bidding, params: { assignment_id: assignment.id }

          expect(response).to have_http_status(302)
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq('Topic or assignment is missing')
        end
      end

      # TC06: ReviewBid.assign_review_topics raises ActiveRecordError
      context 'when ReviewBid.assign_review_topics raises ActiveRecordError' do
        let!(:reviewers) { create_list(:participant, 3, assignment: assignment) }

        it 'redirects back with an alert for database error' do
          allow_any_instance_of(ReviewBid).to receive(:assign_review_topics).and_raise(ActiveRecord::ActiveRecordError)

          post :assign_bidding, params: { assignment_id: assignment.id }

          expect(response).to have_http_status(302)
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq('Failed to assign reviewers due to database error. Please try again later.')
        end
      end

      # TC07: ReviewBid.assign_review_topics raises an unexpected error
      context 'when ReviewBid.assign_review_topics raises an unexpected error' do
        let!(:reviewers) { create_list(:participant, 3, assignment: assignment) }

        it 'redirects back with a generic alert' do
          allow_any_instance_of(ReviewBid).to receive(:assign_review_topics).and_raise(StandardError)

          post :assign_bidding, params: { assignment_id: assignment.id }

          expect(response).to have_http_status(302)
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq('Failed to assign reviewers. Please try again later.')
        end
      end

    # TC08: Assignment.update Fails
    context 'when assignment.update fails' do
      let!(:reviewers) { create_list(:participant, 5, assignment: assignment) }
      let!(:topics) { create_list(:sign_up_topic, 3, assignment: assignment) }

      let(:mock_output) do
        reviewers.index_by(&:id).transform_values { |_reviewer| topics.sample(3).map(&:id) }
      end

      it 'handles the exception and redirects back with an alert' do
        allow(Assignment).to receive(:find).with(assignment.id.to_s).and_return(assignment)
        allow_any_instance_of(ReviewBidsController).to receive(:bidding_data).and_return(mock_input)
        allow_any_instance_of(ReviewBidsController).to receive(:run_bidding_algorithm).and_return(mock_output)
        allow_any_instance_of(ReviewBid).to receive(:assign_review_topics).and_return(true)
        expect(assignment).to receive(:update!).with(can_choose_topic_to_review: false).and_raise(ActiveRecord::RecordInvalid.new(assignment))

        post :assign_bidding, params: { assignment_id: assignment.id }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Failed to assign reviewers due to database error. Please try again later.')
      end
    end


      # TC09: Empty bidding_data
      context 'When bidding_data is empty' do
        let!(:reviewers) { create_list(:participant, 5, assignment: assignment) }

        it 'redirects back with an alert due to empty bidding_data' do
          review_bid = instance_double('ReviewBid')
          allow(ReviewBid).to receive(:new).and_return(review_bid)
          allow(review_bid).to receive(:assign_review_topics).and_return(true)
          allow(Assignment).to receive(:find).with(assignment.id.to_s).and_return(assignment)
          allow_any_instance_of(ReviewBidsController).to receive(:bidding_data).and_return({})
          allow_any_instance_of(ReviewBidsController).to receive(:run_bidding_algorithm).and_return(nil)

          post :assign_bidding, params: { assignment_id: assignment.id }

          expect(response).to have_http_status(302)
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq('Topic or assignment is missing')
        end
      end
    end
  end
end
