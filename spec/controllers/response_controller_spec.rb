require 'rails_helper'


RSpec.describe ResponseController, type: :controller do
  before(:each)
  response = FactoryGirl.create(:Response)
  feedresposemap=FactoryGirl.create(:FeedbackResponseMap)

  describe "GET #new_feedback" do

    it "returns http success" do
      
      get :new_feedback,{:params => {:id=>1}}
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #view" do
     
    it "returns http success" do
      get :view
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #delete" do
   
    it "returns http success" do

      post :delete
      expect(response).to have_http_status(:success)
    end
  end



  describe "GET #saving" do
    
    it "returns http success" do
      get :saving
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #redirection" do
    

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
