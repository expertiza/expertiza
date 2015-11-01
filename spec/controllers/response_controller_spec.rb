require 'rails_helper'


RSpec.describe ResponseController, type: :controller do
  before(:each)
  response = FactoryGirl.create(:Response)
  feedresposemap=FactoryGirl.create(:FeedbackResponseMap)

  describe "GET #new_feedback" do

    it "Should call find method" do
    Response.should_receive(:find).with("Additional comments").and_return(:response)
    end
    it "should find response in feedresponsemap" do
    FeedbackResponseMap.should_receive(:where).and_return(:feedresponsemap)
    end
    it "returns http success" do
      
      get :new_feedback
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #view" do
     it "Should call find method" do
    Response.should_receive(:find).with("Additional comments")
    end
    it "returns http success" do
      get :view
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #delete" do
    it "Should call find method" do
    Response.should_receive(:find).with("Additional comments").and_return(:response)
    end
    it "returns http success" do

      post :delete
      expect(response).to have_http_status(:success)
    end
  end



  describe "GET #saving" do
     it "Should call find method" do
    Response.should_receive(:find).with("Additional comments").and_return(:response)
    end
    it "returns http success" do
      get :saving
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #redirection" do
     it "Should call find by map method" do
    Response.should_receive(:find_by_map).with("Additional comments").and_return(:response)
    end

    it "returns http success" do
      get :redirection
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #custom_create" do
    it "returns http success" do
      post :create
      expect(response).to have_http_status(:success)
    end
  end

end
