describe ReviewBidsController do
  # let(:assignment) { double('Assignment', id: 1) }
  # let(:participant) { double('AssignmentParticipant', id: 1, can_review: false, user: double('User', id: 1)) }
  let(:student) { build(:student, id: 1, name: 'name', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:instructor) { build(:instructor, id: 2) }
  let(:teaching_assistant) { build(:teaching_assistant, id: 3) }
  let(:admin) { build(:admin, id: 4) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 2) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student) }

  before :each do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Participant).to receive(:find).with('1').and_return(participant)
    allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
    allow(controller).to receive(:current_user).and_return(student)
  end

  describe '#action_allowed?' do
    context 'when different roles call the controller' do
      it 'does not allow Students to run review bidding algorithm' do
        controller.params = { action: 'assign_bidding' }
        allow(controller).to receive(:current_user).and_return(student)
        expect(controller.action_allowed?).to be false
      end

      it 'does allow Instructors, Teaching Assistants, Administrators to run review bidding algorithm' do
        controller.params = { action: 'assign_bidding' }
        
        allow(controller).to receive(:current_user).and_return(instructor)
        expect(controller.action_allowed?).to be true
        
        allow(controller).to receive(:current_user).and_return(teaching_assistant)
        expect(controller.action_allowed?).to be true
        
        allow(controller).to receive(:current_user).and_return(admin)
        expect(controller.action_allowed?).to be true
      end

      it 'does allow Students to access show, index, set_priority' do
        allow(controller).to receive(:current_user).and_return(student)
        
        controller.params = { action: 'show' }
        expect(controller.action_allowed?).to be true
        
        controller.params = { action: 'index' }
        expect(controller.action_allowed?).to be true
        
        controller.params = { action: 'set_priority' }
        expect(controller.action_allowed?).to be true
      end
    end

    context 'when action is list' do
      it 'checks additional authorizations' do
        allow(controller).to receive(:current_user).and_return(student)
        controller.params = { action: 'list', id: '1' }
        expect(controller).to receive(:are_needed_authorizations_present?)
          .with('1', 'participant', 'reader', 'submitter', 'reviewer')
          .and_return(true)
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
  
    before do
      allow(ReviewResponseMap).to receive(:where).and_return([])
    end
  
    context 'when updating bids' do
      let(:selected_topic_ids) { [1, 2, 3] }
      let(:existing_bids) do
        [
          double('Bid', signuptopic_id: 1),
          double('Bid', signuptopic_id: 4),
          double('Bid', signuptopic_id: 5)
        ]
      end
  
      before do
        allow(ReviewBid).to receive(:where).and_return(existing_bids)
      end
  
      it 'redirects to root path after successful update' do
        get :set_priority, params: { 
          topic: selected_topic_ids, 
          assignment_id: assignment.id, 
          id: participant.id 
        }
        expect(response).to redirect_to(root_path)
      end
    end
  
    context 'when no topics are selected' do
      it 'redirects to root path' do
        get :set_priority, params: { 
          topic: [], 
          assignment_id: assignment.id, 
          id: participant.id 
        }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe '#assign_bidding' do
    render_views

    context 'when bidding assignment fails' do
      it 'redirects with alert' do
        allow(controller).to receive(:redirect_back).and_return(redirect_to(root_path))
        get :assign_bidding, params: { assignment_id: assignment.id }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when bidding assignment succeeds' do
      it 'redirects with notice' do
        allow(controller).to receive(:redirect_back).and_return(redirect_to(root_path))
        get :assign_bidding, params: { assignment_id: assignment.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'authorization failures' do
    context 'when participant not found' do
      it 'redirects with alert' do
        allow(AssignmentParticipant).to receive(:find_by).and_return(nil)
        get :show, params: { id: 1 }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user not authorized' do
      it 'redirects with alert' do
        other_user = build(:student, id: 2)
        allow(controller).to receive(:current_user).and_return(other_user)
        allow(AssignmentParticipant).to receive(:find_by).and_return(participant)
        get :show, params: { id: participant.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end