require 'rails_helper'
include LogInHelper
RSpec.describe ResponseController, type: :controller do

  context "user not logged in" do
  	 let!(:response) { Response.create(:map_id => 1, :additional_comment => 'hello',:round => 1)#,:version_num=>@version)
}
  	#user not logged in 
  describe "GET #new_feedback" do
    it "returns http success" do
        
      get :new_feedback
      expect(response).to redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end
  end


  describe "GET #saving" do
    
    it "returns http success" do
      get :saving
      expect(response).to redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end
  end

  describe "GET #redirection" do
    

    it "returns http success" do
      get :redirection
      expect(response).to redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end
  end

  describe "POST #custom_create" do
    it "returns http success" do
      post :create
      expect(response).to redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end
  end

end

 context 'logged in as student' do
 	let!(:review) { Response.create(:map_id => 1, :additional_comment => 'hello',:round => 1)}
     let!(:map) {FeedbackResponseMap.create(:reviewed_object_id => 1, :reviewer_id => 1, :reviewee_id =>1)}
    let(:assignment){AssignmentParticipant.new} 
    let!(:responsemap){ResponseMap.new}
    before(:each) do
     
      student.save
      @user = User.find_by_name('student')
      @role = double('role', :super_admin? => false)
      ApplicationController.any_instance.stub(:current_user).and_return(@user)
      ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
      ApplicationController.any_instance.stub(:current_role).and_return(@role)
    end
describe "GET #new_feedback" do
	
    it "redirects to new if review object is found" do
      Response.stub(:find).and_return(review)
      session[:user].stub(:id).and_return(1) 
      review.stub_chain(:map,:assignment,:id).and_return(1)
      review.stub_chain(:map,:reviewer,:id).and_return(1)
      AssignmentParticipant.any_instance.stub_chain(:where,:first).and_return(assignment)
      FeedbackResponseMap.any_instance.stub_chain(:where,:first).and_return(map)
      FeedbackResponseMap.any_instance.stub(:create).and_return(map)

      get :new_feedback
      
      expect(response).to redirect_to :action => :new, :id => map.id,:return => "feedback"
    end
    it "redirects to same page if no review is found" do
    Response.stub(:find).and_return(false) 
     expect(response).to have_http_status(200)
     end
  end


  describe "GET #saving" do
    
    it "redirect to redirection" do

    	ResponseMap.stub(:find).and_return(responsemap)
    	ResponseMap.stub(:save).and_return(true)

      get :saving
      
      expect(response).to have_http_status(302)
    end
  end

  describe "GET #redirection" do


    it "returns http success" do

    	Response.stub(:find_by_map_id).and_return(review)
    	review.stub_chain(:reviewer,:id).and_return(1)
    
      get :redirection
      
      expect(response).to have_http_status(302)
    end
  end

  



 end

end
