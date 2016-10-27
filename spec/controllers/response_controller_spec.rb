require 'rails_helper'
include LogInHelper

RSpec.describe ResponseController, type: :controller do
  context "user not logged in" do
    let(:response) do
      Response.create(map_id: 1, additional_comment: 'hello', round: 1)
    end
    # user not logged in

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
    let(:review) { Response.create(map_id: 1, additional_comment: 'hello', round: 1) }
    let(:map) { FeedbackResponseMap.create(reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }
    let(:assignment) { AssignmentParticipant.new }
    let(:responsemap) { ResponseMap.new }
    before(:each) do
      student.save
      @user = User.find_by_name('student')
      @role = double('role', super_admin?: false)
      stub_current_user(@user, 'Student', @role)
    end

    describe "GET #saving" do
      it "redirect to redirection" do
        allow(ResponseMap).to receive(:find).and_return(responsemap)
        allow(ResponseMap).to receive(:save).and_return(true)

        get :saving
        expect(response).to have_http_status(302)
      end
    end

    describe "GET #redirection" do
      it "returns http success" do
        allow(Response).to receive(:find_by_map_id).and_return(review)
        allow(review).to receive_message_chain(:reviewer, :id).and_return(1)
        get :redirection
        expect(response).to have_http_status(302)
      end
    end
  end
end
