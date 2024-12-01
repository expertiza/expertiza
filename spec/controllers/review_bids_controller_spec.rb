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

  describe 'action_allowed as a Student' do
    it 'does not allow assign_bidding or run_bidding_algorithm actions' do
      session[:user] = build(:student)
      %w[assign_bidding run_bidding_algorithm].each do |action|
        controller.params = { id: '1', action: action }
        expect(controller.action_allowed?).to be false
      end
    end

    it 'allows show, index, set_priority, and list with participant or reviewer authorizations' do
      session[:user] = build(:student)
      allow(controller).to receive(:are_needed_authorizations_present?).and_return(true)
      %w[show index set_priority list].each do |action|
        controller.params = { id: '1', action: action }
        expect(controller.action_allowed?).to be true
      end
    end

    it 'does not allow list if not authorized as a participant or reviewer' do
      session[:user] = build(:student)
      allow(controller).to receive(:are_needed_authorizations_present?).and_return(false)
      controller.params = { id: '1', action: 'list' }
      expect(controller.action_allowed?).to be false
    end
  end

  describe 'action_allowed as an Instructor, Teaching Assistant, Administrator, or Super-Administrator' do
    it 'allows assign_bidding and run_bidding_algorithm actions' do
      %i[instructor teaching_assistant administrator super-administrator].each do |role|
        session[:user] = build(role)
        %w[assign_bidding run_bidding_algorithm].each do |action|
          controller.params = { id: '1', action: action }
          expect(controller.action_allowed?).to be true
        end
      end
    end

    it 'allows access to show, index, set_priority, and list without additional authorization' do
      %i[instructor teaching_assistant administrator super-administrator].each do |role|
        session[:user] = build(role)
        %w[show index set_priority list].each do |action|
          controller.params = { id: '1', action: action }
          expect(controller.action_allowed?).to be true
        end
      end
    end
  end

  describe 'action_allowed edge cases' do
    it 'does not allow actions for users who are not logged in' do
      session[:user] = nil
      %w[assign_bidding run_bidding_algorithm show index set_priority list].each do |action|
        controller.params = { id: '1', action: action }
        expect(controller.action_allowed?).to be false
      end
    end

    it 'does not allow invalid actions' do
      session[:user] = build(:student)
      [nil, '', 'invalid_action'].each do |action|
        controller.params = { id: '1', action: action }
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
