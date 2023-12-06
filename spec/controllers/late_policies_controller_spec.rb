describe LatePoliciesController do
  let(:instructor) { build(:instructor, id: 6) }

  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  # Creates a late policy for various tests. Was duplicated at multiple locations, so the duplicate code was taken out
  # and placed here for more readability and to satisfy DRY
  def create_late_policy(policy_name, max_penalty, penalty_per_unit, instructor_id)
    late_policy = LatePolicy.new
    late_policy.policy_name = policy_name
    late_policy.max_penalty = max_penalty
    late_policy.penalty_per_unit = penalty_per_unit
    late_policy.instructor_id = instructor_id
    late_policy
  end

  # This helper method was also created to reduce repeated code
  def request_params(policy_name, max_penalty, penalty_per_unit)
    {
      late_policy: {
        max_penalty: max_penalty,
        penalty_per_unit: penalty_per_unit,
        policy_name: policy_name
      }
    }
  end

  # This helper method was created to reduce repeated code as well. This is similar to the previous method
  # but adds a unique id to it on top of the other things
  def request_params_with_id(policy_name, max_penalty, penalty_per_unit, id)
    {
      late_policy: {
        max_penalty: max_penalty,
        penalty_per_unit: penalty_per_unit,
        policy_name: policy_name
      },
      id: id
    }
  end

  describe 'GET #index' do
    context 'when index is called' do
      it 'routes to index page' do
        get :index
        expect(get: 'late_policies/').to route_to('late_policies#index')
      end
      it 'renders the new page' do
        get :index
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET #show' do
    before(:each) do
      latePolicy = create_late_policy('Policy2', 40, 30, 6)
      allow(LatePolicy).to receive(:find).with('1').and_return(latePolicy)
    end
    context 'when show is called' do
      it 'routes to show page' do
        request_params = {
          id: 1
        }
        get :show, params: request_params
        expect(get: 'late_policies/1').to route_to('late_policies#show', id: '1')
      end
    end
  end

  describe 'GET #edit' do
    before(:each) do
      latePolicy = create_late_policy('Policy2', 40, 30, 6)
      allow(LatePolicy).to receive(:find).with('1').and_return(latePolicy)
    end
    context 'when edit is called' do
      it 'returns Late policy object' do
        request_params = {
          id: 1
        }
        get :edit, params: request_params
        expect(assigns(:penalty_policy).policy_name).to eq('Policy2')
      end
    end
  end

  describe 'GET #new' do
    context 'when new is called' do
      it 'routes to new page' do
        get :new
        expect(get: 'late_policies/new').to route_to('late_policies#new')
      end
      it 'renders the new page' do
        get :new
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'delete #destroy' do
    it 'when destroy is called' do
      request_params = {
        id: 1
      }
      delete :new, params: request_params
      expect(response).to be_success
    end
  end

  # Create an RSpec example to reduce code duplication in the following tests
  RSpec.shared_examples 'late policy creation with error' do |policy_name, max_penalty, penalty_per_unit, expected_error|
    before(:each) do
      latePolicy = LatePolicy.new
      allow(latePolicy).to receive(:check_policy_with_same_name).with(any_args).and_return(false)
    end

    it 'throws a flash error' do
      post :create, params: request_params(policy_name, max_penalty, penalty_per_unit)
      expect(flash[:error]).to eq(expected_error)
      expect(response).to redirect_to('/late_policies/new')
    end
  end

  describe 'POST #create' do
    context 'when maximum penalty is less than penalty per unit' do
      include_examples 'late policy creation with error', 'Policy1', 10, 30, 'The maximum penalty must be between the penalty per unit and 100.'
    end

    context 'when maximum penalty is greater than 100' do
      include_examples 'late policy creation with error', 'Policy1', 101, 30, 'The maximum penalty must be between the penalty per unit and 100.'
    end

    context 'when penalty per unit is negative while creating late policy' do
      before(:each) do
        allow(LatePolicy).to receive(:check_policy_with_same_name).with(any_args).and_return(false)
      end
      it 'throws a flash error ' do
        post :create, params: request_params('Invalid_Policy', 30, -10)
        expect(flash[:error]).to eq('Penalty per unit cannot be negative.')
      end
    end

    context 'when policy with same name exists' do
      before(:each) do
        latePolicy = LatePolicy.new
        allow(LatePolicy).to receive(:check_policy_with_same_name).with(any_args).and_return(true)
      end
      it 'throws a flash error ' do
        post :create, params: request_params('Policy1', 30, 10)
        expect(flash[:error]).to eq('A policy with the same name Policy1 already exists.')
      end
    end

    context 'when the late_policy is not saved' do
      before(:each) do
        latePolicy = create_late_policy('Policy1', 40, 30, 6)
        allow(latePolicy).to receive(:check_policy_with_same_name).with(any_args).and_return(false)
        allow(latePolicy).to receive(:new).with(any_args).and_return(latePolicy)
        allow(latePolicy).to receive(:save!).and_return(false)
      end
      it 'throws a flash error ' do
        post :create, params: request_params('Policy1', 40, 30)
        expect(flash[:error]).to eq('The following error occurred while saving the late policy: ')
      end
    end
  end

  describe 'POST #update' do
    before(:each) do
      latePolicy = create_late_policy('Policy2', 40, 30, 6)
      allow(LatePolicy).to receive(:find).with('1').and_return(latePolicy)
      allow(LatePolicy).to receive(:check_policy_with_same_name).with(any_args).and_return(true)
    end
    context 'when maximum penalty is less than penalty per unit' do
      it 'throws a flash error ' do
        post :update, params: request_params_with_id('Policy2', 30, 100, 1)
        expect(flash[:error]).to eq('Cannot edit the policy. The maximum penalty must be between the penalty per unit and 100.')
        expect(response).to redirect_to('/late_policies/1/edit')
      end
    end

    context 'when policy with same name exists' do
      before(:each) do
        allow(LatePolicy).to receive(:check_policy_with_same_name).with(any_args).and_return(true)
      end
      it 'throws a flash error ' do
        post :update, params: request_params_with_id('Policy1', 30, 10, 1)
        expect(flash[:error]).to eq('Cannot edit the policy. A policy with the same name Policy1 already exists.')
      end
    end

    context 'when penalty per unit is negative while updating of late policy' do
      before(:each) do
        allow(LatePolicy).to receive(:check_policy_with_same_name).with(any_args).and_return(false)
      end
      it 'throws a flash error ' do
        post :update, params: request_params_with_id('Invalid_Policy', 30, 10, 1)
        expect(flash[:error]).to eq('The following error occurred while saving the late policy: ')
      end
    end
  end
end
