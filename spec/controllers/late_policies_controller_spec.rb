require 'rails_helper'

RSpec.describe LatePoliciesController, :type => :controller do

  let(:instructor) { build(:instructor, id: 6) }

  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  describe "GET #index" do
    it "when index is called" do
      get :index
      expect(get: "late_policies/").to route_to("late_policies#index")
    end
    it "when redirects to index page" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    it "when show is called" do
      params = {
          id: 1
      }
      get :show,params
      expect(get: "late_policies/1").to route_to("late_policies#show",id:"1")
    end
    # it "when show is called" do
    #   params = {
    #       id: 1
    #   }
    #   get :show,params
    #   expect(response).to render_template(:show)
    # end
  end

  # describe "GET #edit" do
  #   it "when edit is called" do
  #     params = {
  #         id: 1
  #     }
  #     get :edit,params
  #     expect(get: "late_policies/1/edit").to route_to("late_policies#edit", id:"1")
  #   end
  # end

  describe "GET #new" do
    it "when new is called" do
      get :new
      expect(get: "late_policies/new").to route_to("late_policies#new")
    end
    it "when new is called" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "delete #destroy" do
    it "when destroy is called" do
      params = {
          id: 1
      }
      delete :new,params
      expect(get: "late_policies/destroy/1").to route_to("late_policies#destroy", id:"1")
    end
  end

  describe "POST #create" do
    # before(:each) do
    #   latePolicy = LatePolicy.new
    #   allow(latePolicy).to receive(:check_policy_with_same_name).with(any_args).and_return(false)
    # end

    context 'when maximum penalty is less than penalty per unit' do
      before(:each) do
        latePolicy = LatePolicy.new
        allow(latePolicy).to receive(:check_policy_with_same_name).with(any_args).and_return(false)
      end
    it "throws a flash error " do
      params = {
          late_policy: {
              max_penalty: 10,
              penalty_per_unit: 30,
              policy_name: "Policy1"
          }
      }
      post :create,params
      expect(flash[:error]).to eq("The maximum penalty cannot be less than penalty per unit.")
      expect(response).to redirect_to('/late_policies/new')
    end
    end

    context 'when policy with same name exists' do
      before(:each) do
        latePolicy = LatePolicy.new
        allow(LatePolicy).to receive(:check_policy_with_same_name).with(any_args).and_return(true)
      end
      it "throws a flash error " do
        params = {
            late_policy: {
                max_penalty: 30,
                penalty_per_unit: 10,
                policy_name: "Policy1"
            }
        }
        post :create,params
        expect(flash[:error]).to eq("A policy with the same name already exists.")
      end
    end

    context 'when everything is fine' do
      before(:each) do

        latePolicy = LatePolicy.new
        latePolicy.policy_name="Policy1"
        latePolicy.max_penalty=100
        latePolicy.penalty_per_unit=30
        latePolicy.instructor_id=6
        allow(latePolicy).to receive(:check_policy_with_same_name).with(any_args).and_return(false)
        allow(latePolicy).to receive(:new).with(any_args).and_return(latePolicy)
        allow(latePolicy).to receive(:save!).and_return(false )
      end
      it "saves " do
        params = {
            late_policy: {
                max_penalty: 100,
                penalty_per_unit: 30,
                policy_name: "Policy1"
            }
        }
        post :create,params
        expect(flash[:error]).to eq("The following error occurred while saving the penalty policy: ")
      end
    end

end

  describe "POST #update" do
      context 'when maximum penalty is less than penalty per unit' do
        before(:each) do
          latePolicy = LatePolicy.new
          latePolicy.policy_name="Policy2"
          latePolicy.max_penalty=100
          latePolicy.penalty_per_unit=30
          latePolicy.instructor_id=6
          allow(LatePolicy).to receive(:find).with("1").and_return(latePolicy)
          allow(LatePolicy).to receive(:check_policy_with_same_name).with(any_args).and_return(true)
        end
        it "throws a flash error " do
          params = {
              late_policy: {
                  max_penalty: 30,
                  penalty_per_unit: 100,
                  policy_name: "Policy1"
              },
              id:1
          }
          post :update,params
          expect(flash[:error]).to eq("Cannot edit the policy. The maximum penalty cannot be less than penalty per unit.")
          expect(response).to redirect_to('/late_policies/1/edit')
        end
      end

      context 'when policy with same name exists' do
        before(:each) do
          latePolicy = LatePolicy.new
          latePolicy.policy_name="Policy3"
          latePolicy.max_penalty=30
          latePolicy.penalty_per_unit=10
          latePolicy.instructor_id=6
          allow(LatePolicy).to receive(:find).with("1").and_return(latePolicy)
          allow(LatePolicy).to receive(:check_policy_with_same_name).with(any_args).and_return(false)
        end
        it "throws a flash error " do
          params = {
              late_policy: {
                  max_penalty: 30,
                  penalty_per_unit: 10,
                  policy_name: "Policy1"
              },
              id:1
          }
          post :update,params
          expect(flash[:error]).to eq("Cannot edit the policy. A policy with the same name Policy1 already exists.")
        end
      end

      context 'when everything is fine' do
        before(:each) do

          latePolicy = LatePolicy.new
          latePolicy.policy_name="Policy1"
          latePolicy.max_penalty=100
          latePolicy.penalty_per_unit=30
          latePolicy.instructor_id=6
          allow(LatePolicy).to receive(:find).with("1").and_return(latePolicy)
          allow(LatePolicy).to receive(:check_policy_with_same_name).with(any_args).and_return(true)
        end
        it "saves " do
          params = {
              late_policy: {
                  max_penalty: 30,
                  penalty_per_unit: 10,
                  policy_name: "Policy1"
              },
              id:1
          }
          post :update,params
          expect(flash[:error]).to eq("The following error occurred while updating the penalty policy: ")
        end
      end
  end

end
