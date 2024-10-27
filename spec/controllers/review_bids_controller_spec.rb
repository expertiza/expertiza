describe ReviewBidsController do
  # let(:assignment) { double('Assignment', id: 1) }
  # let(:participant) { double('AssignmentParticipant', id: 1, can_review: false, user: double('User', id: 1)) }
  let(:student) { build(:student, id: 1, username: 'name', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 2) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student) }

  before :each do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Participant).to receive(:find).with('1').and_return(participant)
    allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
  end

  describe '#action_allowed?' do
    context 'when different roles call the controller' do
      it 'does not allow Students to run review bidding algorithm' do
        session[:user] = build(:student)
        controller.params = { action: 'assign_bidding' }
        expect(controller.action_allowed?).to be false
      end
      it 'does allow Instructors, Teaching Assistants, Administrators to run review bidding algorithm' do
        controller.params = { action: 'assign_bidding' }
        session[:user] = build(:instructor)
        expect(controller.action_allowed?).to be true
        session[:user] = build(:teaching_assistant)
        expect(controller.action_allowed?).to be true
        session[:user] = build(:admin)
        expect(controller.action_allowed?).to be true
      end
      it 'does allow Students to access show, index, set_priority' do
        session[:user] = build(:student)
        controller.params = { action: 'show' }
        expect(controller.action_allowed?).to be true
        controller.params = { action: 'index' }
        expect(controller.action_allowed?).to be true
        controller.params = { action: 'set_priority' }
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
