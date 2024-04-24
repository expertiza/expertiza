describe ReviewBidsController do
  let(:student) { build(:student, id: 1, name: 'name', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 2) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student, assignment: assignment) }

  before :each do
    allow(controller).to receive(:current_user_id?).and_return(true)
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Participant).to receive(:find).with('1').and_return(participant)
    allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
  end

  describe '#action_allowed?' do
    context 'when different roles call the controller' do
      it 'does not allow Students to run review bidding algorithm' do
        session[:user] = build(:student)
        controller.params = { action: 'assign_bid_review' }
        expect(controller.action_allowed?).to be false
      end
      it 'does allow Instructors, Teaching Assistants, Administrators to run review bidding algorithm' do
        controller.params = { action: 'assign_bid_review' }
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
      it 'does not allow Students to access assign_bid_review' do
        session[:user] = build(:student)
        controller.params = { action: 'assign_bid_review' }
        expect(controller.action_allowed?).to be false
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
    it 'sets necessary instance variables for valid participants' do
      session[:user] = student
      get :index, params: { id: participant.id.to_i }
      expect(assigns(:participant)).to eq(participant)
      expect(assigns(:assignment)).to eq(assignment)
    end

    it 'redirects unauthorized users' do
      allow(controller).to receive(:current_user_id?).and_return(false)
      get :index, params: { id: '1' }
      expect(response).to redirect_to(root_path)  # replace `some_path` with your actual redirect path
    end
  end

  describe '#show' do
    render_views
    it 'renders the bidding page' do
      get :show
      expect { get :show, format: :html }.to_not raise_error
      expect(response.body) =~ '/sign_up_sheet/review_bid_show'
    end
    it 'sets necessary instance variables for show action' do
      session[:user] = student
      get :show, params: { id: participant.id.to_i }
      expect(assigns(:participant)).to eq(participant)
      expect(assigns(:assignment)).to eq(assignment)
      # Add more asserts for other instance variables as necessary
    end
  end
end
