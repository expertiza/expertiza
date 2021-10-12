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

    it "Max penalty should be less than penalty per unit" do
      get :new
      params = {
        late_policy: {
            policy_name: '',
            penalty_per_unit: 1,
            penalty_unit: '',
            max_penalty: 0,
        }
      }
      post :create, params
      expect(flash[:error]).to include("The maximum penalty cannot be less than penalty per unit.")
    end

  end
end