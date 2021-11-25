require './spec/support/teams_shared.rb'

describe TeamsController do
  let(:student) { build_stubbed(:student) }
  let(:team1) { build_stubbed(:team, id: 1, type: 'Assignment') }
  let(:team2) { build_stubbed(:team, id: 2, type: 'Assignment') }
  let(:ta2) { build_stubbed(:teaching_assistant, id: 1) }

  describe 'action allowed method' do
    context 'not provides access to people with' do
      include_context 'authorization check'
    end
    context 'not provides access to people with' do
      it 'student credentials' do
        stub_current_user(student, student.role.name, student.role)
        expect(controller.send(:action_allowed?)).to be false
      end
    end
  end

  describe 'create teams method' do
    context 'when everything is right' do
      it 'creates teams with random names' do
        allow(Object).to receive_message_chain(:const_get, :find).with(any_args).and_return(team1.type)
        allow(Team).to receive(:randomize_all_by_parent).with(any_args)
        para = {response_id: 1, team_type: 'Assignment', team_size: 2}
        session = {user: ta2}
        result = get :create_teams, para, session
        expect(result.status).to eq 200
        #expect(result).to redirect_to(list)
      end
    end
  end

  describe 'list method' do

  end

  describe 'new method' do
    it 'creates a new team successfully' do
      allow(Object).to receive_message_chain(:const_get, :find).with(any_args).and_return(team1.type)
      para = {response_id: 1, team_id: 1}
      session = {user: ta2}
      result = get :new, para, session
      expect(result.status).to eq 200
      expect(controller.instance_variable_get(:@parent)).to eq team1.type
    end
  end

  describe 'create method' do

  end

  describe 'update method' do
    it 'updates the team name' do
      allow(Team).to receive(:find).and_return(team1)
      allow(Object).to receive_message_chain(:const_get, :find).with(any_args).and_return(team1.parent_id)
      #allow(Team).to receive(:check_for_existing).and_do_nothing#not_raise(TeamExistsError)

      para = {response_id: 1, team_id: 1}
      session = {user: ta2}
      result = get :update, para, session
      expect(Rails.logger).to receive(:error)
      expect(result.status).to eq 404
    end
  end

  describe 'edit method' do
    it 'passes the test' do
      allow(Team).to receive(:find).and_return(team1)
      para = {response_id: 1, team_id: 1}
      session = {user: ta2}
      result = get :edit, para, session
      expect(result.status).to eq 200
      expect(controller.instance_variable_get(:@team)).to eq team1
    end
  end

  describe 'inherit method' do

  end

  describe 'bequeath method' do

  end

end
