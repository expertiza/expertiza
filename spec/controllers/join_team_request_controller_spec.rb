require './spec/support/teams_shared.rb'

describe JoinTeamRequestsController do
  let(:student) {build_stubbed(:student)}
  let(:participant){build_stubbed(:participant,id: 1)}
  include_context 'authorization check'
  context 'not provides access to people with' do
    it 'student credentials' do
      stub_current_user(student, student.role.name, student.role)
      expect(controller.send(:action_allowed?)).to be true
    end
  end

  describe "GET index" do
    #let(:join_team_requests) {create_list :id,1}
    #let(:join_team_request) {JoinTeamRequest.new}
    before do
      get :index
    end
    let(:team1){build(:team, id: 1)}
    let(:team2) {build(:team, id: 2)}
    let(:team3) {build(:team, id: 3)}
    let(:team4) {build(:team, id: 4)}
    let(:student1){build(:student,id:2)}
    let(:participant1){build(:participant, id: 1)}
    let(:join_team_request1) {build(:join_team_request,team_id: team1.id, status: 'P')}
    let(:join_team_request2) {build(:join_team_request,team_id: team2.id, status: 'D')}

    context "when index is called" do
      it "routes to index page" do
        get :index
        expect(get: "join_team_requests/").to route_to("join_team_requests#index")
      end

    end
  end

  describe "Get #show" do
    before(:each) do
      join_team_request3 = JoinTeamRequest.new
      join_team_request3.participant_id = 1
      join_team_request3.team_id = 2
      join_team_request3.comments="Accepted"
      join_team_request3.status="P"
      allow(JoinTeamRequest).to receive(:find).with("1").and_return(join_team_request3)
    end

    context "when show is called" do
      it "routes to show page" do
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
  describe "when a join_team_request is created" do
    before(:each) do
      allow(Participant).to receive(:find).with("1").and_return(participant)
    end
    context "when the join_team_request is not saved!" do
      let(:invalidrequest) {build_stubbed(:join_team_request)}
      it "renders new page" do
        allow(JoinTeamRequest).to receive(:new).and_return(invalidrequest)
        params = {participant_id: participant.id, team_id: -2}
        session = {user: student}
        get :new, params, session
        expect(response).to render_template("new")
      end
    end
  end
end

