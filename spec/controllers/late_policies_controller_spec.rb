describe LatePoliciesController do

  let(:instructor) { build(:instructor, id: 6) }
  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  context "#request new" do
    it 'renders template' do
      get :new
      expect(response).to render_template(:new)
    end

    it 'shows error on empty submission' do
      get :new
      params = {
        late_policy: {
            policy_name: '',
            penalty_per_unit: '',
            penalty_unit: '',
            max_penalty: 0,
        }
      }
      post :create, params
      expect(flash[:error]).to include("Policy name can't be blank")
      expect(flash[:error]).to include("Penalty per unit can't be blank")
    end

    it 'shows error on penalty per unit being negative' do
      get :new
      params = {
        late_policy: {
            policy_name: 'assignment 1',
            penalty_per_unit: -100,
            penalty_unit: 10,
            max_penalty: 0,
        }
      }
      post :create, params
      expect(flash[:error]).to include("Penalty can't be negative")
      expect(flash[:error]).to include("Penalty per unit can't be negative")
    end

    it 'shows error on max penalty being negative' do
      get :new
      params = {
        late_policy: {
            policy_name: 'assignment 1',
            penalty_per_unit: 1,
            penalty_unit: 10,
            max_penalty: -100,
        }
      }
      post :create, params
      expect(flash[:error]).to include("Max penalty must be greater than 0")
      expect(flash[:error]).to include("Max penalty must be greater than 0")
    end

    it 'shows error on policy name greater than 255 characters' do
      get :new
      params = {
        late_policy: {
            policy_name: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
            penalty_per_unit: 1,
            penalty_unit: 'Minute',
            max_penalty: 50,
        }
      }
      post :create, params
      expect(flash[:error]).to include("Policy name is invalid")
      expect(flash[:error]).to include("Policy name is invalid")
    end
    
    it 'shows error on policy name greater than 255 characters' do
      get :new
      params = {
        late_policy: {
            policy_name: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
            penalty_per_unit: 1,
            penalty_unit: 'Minute',
            max_penalty: 50,
        }
      }
      post :create, params
      expect(flash[:error]).to include("Policy name cannot have more than 255 characters")
      expect(flash[:error]).to include("Policy name cannot have more than 255 characters")
    end
  end
end