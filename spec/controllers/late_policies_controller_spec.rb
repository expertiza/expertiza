require 'byebug'
describe LatePoliciesController do

  # use id:1, since the factory for late_policy uses first generated id
  # for instructor_id
  policy_instructor_id = 1
  let(:instructor) { build(:instructor, id: policy_instructor_id) }
  let!(:late_policy) { create(:late_policy) }

  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  context "#request new" do
    it 'renders template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  context "#request create" do

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

    it "Check for policy with same name" do
      get :new
      params = {
        late_policy: {
            policy_name: late_policy.policy_name,
            penalty_per_unit: 1,
            penalty_unit: 'Minute',
            max_penalty: 9,
        }
      }
      post :create, params
      expect(flash[:error]).to include("A policy with the same name already exists.")
    end 
  end

  context "#request edit/update" do
    let!(:new_policy) {
      create(:late_policy, policy_name: "New policy", instructor_id: policy_instructor_id)
    }
    it "renders edit template" do
      get :edit, id: new_policy.id
      expect(response).to render_template(:edit)
    end

    it "change policy name to different name" do
      puts "all: #{LatePolicy.all}"
      LatePolicy.all.each do |lp|
        puts "id: #{lp.id}"
      end
      # byebug
      # get edit_late_policy_path(late_policy)
      get :edit, id: new_policy.id
      params = {
        id: new_policy.id,
        late_policy: {
          policy_name: late_policy.policy_name,
          penalty_per_unit: 1,
          penalty_unit: 'Minute',
          max_penalty: 9,
        }
      }
      post :update, params

      expect(response).to redirect_to(edit_late_policy_path(new_policy.id))
      expect(flash[:error]).to include("Cannot edit the policy. A policy with the same name")
    end
  end
end