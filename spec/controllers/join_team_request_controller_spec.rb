require './spec/support/teams_shared.rb'

describe JoinTeamRequestsController do
  let(:student) {build_stubbed(:student)}

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

    let(:team1){build(:team, id: 1)}
    let(:team2) {build(:team, id: 2)}
    let(:team3) {build(:team, id: 3)}
    let(:team4) {build(:team, id: 4)}

    let(:join_team_request1) {build(:join_team_request,team_id: team1.id, status: 'P')}
    let(:join_team_request2) {build(:join_team_request,team_id: team2.id, status: 'D')}
    it "assigns a team request" do
      JoinTeamRequest.new
      JoinTeamRequest.new
      get :index
      allow(JoinTeamRequest).to receive(:all).and_return(join_team_request1)
      expect(controller.instance_variable_get(:@join_team_request)).to eq join_team_request1
    end
  end
end

