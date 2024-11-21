describe ReviewBidsController do
  # let(:assignment) { double('Assignment', id: 1) }
  # let(:participant) { double('AssignmentParticipant', id: 1, can_review: false, user: double('User', id: 1)) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student, id: 1, name: 'name', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 2) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student) }

  before :each do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Participant).to receive(:find).with('1').and_return(participant)
    allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
    allow(participant).to receive(:assignment).and_return(assignment)
  end

  describe '#action_allowed?' do
    describe 'when different roles call the controller' do
      describe 'as a Student' do
        it 'does not allow running the review bidding algorithm' do
          session[:user] = build(:student)
          controller.params = { id: '1', action: 'assign_bidding' }
          expect(controller.action_allowed?).to be false
        end

        it 'allows access to show, index, and set_priority' do
          session[:user] = build(:student)
          %w[show index set_priority].each do |action|
            controller.params = { id: '1', action: action }
            expect(controller.action_allowed?).to be true
          end
        end
      end

      describe 'as other roles (Instructor, Teaching Assistant, Administrator)' do
        it 'allows running the review bidding algorithm' do
          controller.params = { id: '1', action: 'assign_bidding' }
          %i[instructor teaching_assistant admin].each do |role|
            session[:user] = build(role)
            expect(controller.action_allowed?).to be true
          end
        end
      end
    end

    describe 'when no user is present in the session' do
      it 'does not allow users that are not logged in to perform any action' do
        session[:user] = nil
        %w[assign_bidding show index set_priority].each do |action|
          controller.params = { id: '1', action: action }
          expect(controller.action_allowed?).to be false
        end
      end
    end

    describe 'when the action is empty, nil, or invalid' do
      it 'does not allow access to invalid actions' do
        session[:user] = build(:student)
        [nil, '', 'bad_action'].each do |action|
          controller.params = { id: '1', action: action }
          expect(controller.action_allowed?).to be false
        end
      end
    end

    describe 'when the action is not in lowercase' do
      it 'allows access for case-insensitive actions' do
        session[:user] = build(:student)
        controller.params = { id: '1', action: 'Assign_Bidding' }
        expect(controller.action_allowed?).to be false

        controller.params = { id: '1', action: 'SHOW' }
        expect(controller.action_allowed?).to be true

        controller.params = { id: '1', action: 'indeX' }
        expect(controller.action_allowed?).to be true

        controller.params = { id: '1', action: 'Set_Priority' }
        expect(controller.action_allowed?).to be true
      end
    end
  end

  describe '#index' do
    context 'with render views' do
      render_views
      it 'renders "others_view" page' do
        expect { get :index, format: :html }.to_not raise_error
        expect(response.body) =~ '/sign_up_sheet/others_work'
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
