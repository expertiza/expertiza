require './spec/support/teams_shared.rb'

describe JoinTeamRequestsController do
  include_context "object initializations"
  include_context 'authorization check'
  context 'not provides access to people with' do
    it 'student credentials' do
      stub_current_user(student1, student1.role.name, student1.role)
      expect(controller.send(:action_allowed?)).to be true
    end
  end

  describe "GET index" do
    before do
      get :index
    end

    context "when index is called" do
      it "routes to index page" do
        get :index
        expect(get: "join_team_requests/").to route_to("join_team_requests#index")
      end

    end
  end

  describe "GET #show" do
    before(:each) do
      join_team_request3 = JoinTeamRequest.new
      join_team_request3.participant_id = 1
      join_team_request3.team_id = 2
      join_team_request3.comments="Accepted"
      join_team_request3.status="P"
      allow(JoinTeamRequest).to receive(:find).with("1").and_return(join_team_request3)
    end

    context "#show" do
      it "when it is valid" do
        params = { id: 1}
        get :show,params
        expect(get: "join_team_requests/1").to route_to("join_team_requests#show",id:"1")
      end
    end
  end

  describe "GET #new" do
    context "when new is called" do
      it "routes to new page" do
        get :new
        expect(get: "join_team_requests/new").to route_to("join_team_requests#new")
      end
    end
  end

  describe "POST #create" do
    before(:each) do
      allow(Participant).to receive(:find).with("1").and_return(participant)
    end
    context "when resource is not saved!" do
      it "renders new page" do
        allow(JoinTeamRequest).to receive(:new).and_return(invalidrequest)
        params = {participant_id: participant.id, team_id: -2}
        session = {user: student1}
        get :new, params, session
        expect(response).to render_template("new")
      end
    end
    context "when resource is saved" do
      it "valid response" do
        allow(JoinTeamRequest).to receive(:new).and_return(join_team_request2)
        allow(Team).to receive(:find).with("1").and_return(team1)
        allow(Assignment).to receive(:find).with(1).and_return(assignment1)
        allow(Participant).to receive(:where).with(user_id: 1,parent_id: '1').and_return([participant])
        allow(join_team_request2).to receive(:save).and_return(true)

        params = {
          id: 2,
          join_team_request2: {
            status: 'P'
          },
          team_id: 1,
          assignment_id: 1
        }
        session = {user: student1}
        post :create, params, session
        expect(response.status).to eq 302
        expect(join_team_request2.status).to eq('P')
        #expect(join_team_request1[:notice]).to match("JoinTeamRequest was successfully created.")
      end
    end
  end

  describe "PUT #update" do
    before(:each) do
      join_team_request = JoinTeamRequest.new
      join_team_request.id = 1
      join_team_request.participant_id = 1
      join_team_request.team_id = 2
      join_team_request.status="P"
    end
    context "when the join_team_request is not updated" do
      it "renders edit page" do
        #allow(JoinTeamRequest).to receive(:update_attribute).with(any_args).and_return(false)
        allow(JoinTeamRequest).to receive(:find).with("1").and_return(join_team_request1)
        #allow(JoinTeamRequest).to receive(:edit).and_return(:invalidrequest)
        params = {
                  id: 1,
                  join_team_request1: {
                  comments: nil
                  }
        }
        session = {user: student1}
        put :edit, params, session
        expect(response).to render_template("edit")
      end

    end
  end

  describe "#decline" do
    before(:each) do
      allow(Participant).to receive(:find).with("1").and_return(participant)
    end
    it "when request declined" do
      allow(JoinTeamRequest).to receive(:edit).with("D").and_return(join_team_request2)
      allow(JoinTeamRequest).to receive(:save).and_return(true)
      params = {
        id: 2,
        join_team_request1: {
          status: 'D'
        }
      }
      session = {user: student1}
      post :new, params, session
      expect(response.status).to eq 200
    end

  end

end

