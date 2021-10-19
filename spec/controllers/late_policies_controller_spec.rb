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

    it 'shows error on penalty per unit being negative' do
      get :new
      params = {
        late_policy: {
            policy_name: 'assignment 1',
            penalty_per_unit: 'Minute',
            penalty_unit: 10,
            max_penalty: 0,
        }
      }
      post :create, params
      expect(flash[:error]).to include("Max penalty must be greater than 0")
    end

    it 'shows error on max penalty being less than penalty per unit' do
      get :new
      params = {
        late_policy: {
            policy_name: 'assignment 1',
            penalty_per_unit: 'Minute',
            penalty_unit: -10,
            max_penalty: -100,
        }
      }
      post :create, params
      expect(flash[:error]).to include("The maximum penalty cannot be less than penalty per unit.")
    end

    # shows error
    it 'shows error on policy name greater than 255 characters' do
      get :new
      params = {
        late_policy: {
            policy_name: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
            penalty_per_unit: 1,
            penalty_unit: 'Minute',
            max_penalty: 10,
        }
      }
      post :create, params
      expect(flash[:error]).to include("Policy name is invalid")
    end
    
    # error
    it 'shows error on policy per unit is random string' do
      get :new
      params = {
        late_policy: {
            policy_name: 'assignment 1',
            penalty_per_unit: 10,
            penalty_unit: 'xyz',
            max_penalty: 50,
        }
      }
      post :create, params
      expect(flash[:error]).to include("Policy per unit should be days/hours/minutes")
      expect(flash[:error]).to include("Policy per unit should be days/hours/minutes")
    end

    # it 'basic happy flow test' do
    #   get :new
    #   params = {
    #     late_policy: {
    #         policy_name: 'assignment 1',
    #         penalty_per_unit: 10,
    #         penalty_unit: 'Minute',
    #         max_penalty: 50,
    #     }
    #   }
    #   # byebug
    #   post :create, params
    #   expect(flash[:error]).to include("Successfully saved")
    # end

    # it 'basic test to test all limits' do
    #   get :new
    #   params = {
    #     late_policy: {
    #         policy_name: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    #         penalty_per_unit: 50,
    #         penalty_unit: 'Minute',
    #         max_penalty: 50,
    #     }
    #   }
    #   byebug
    #   post :create, params
    #   expect(flash[:error]).to include("Successfully saved")
    # end
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
    let!(:edit_policy) {
      create(:late_policy, policy_name: "New policy", instructor_id: policy_instructor_id)
    }
    it "renders edit template" do
      get :edit, id: edit_policy.id
      expect(response).to render_template(:edit)
    end

    it "change policy name to an existing policy's name" do
      get :edit, id: edit_policy.id
      params = {
        id: edit_policy.id,
        late_policy: {
          # Change name to an existing policy name
          policy_name: late_policy.policy_name,
          penalty_per_unit: edit_policy.penalty_per_unit,
          penalty_unit: edit_policy.penalty_unit,
          max_penalty: edit_policy.max_penalty,
        }
      }
      post :update, params

      expect(response).to redirect_to(edit_late_policy_path(edit_policy.id))
      expect(flash[:error]).to include("Cannot edit the policy. A policy with the same name")
    end
  end
end