require './spec/support/teams_shared.rb'

describe TeamsController do
  include_context 'object initializations'
  #let(:logmsg) { build_stubbed(:loggermessage) }

=begin
  describe 'action allowed method' do
    context 'provides access after' do
      include_context 'authorization check'
    end
    context 'not provides access to people with' do
      it 'student credentials' do
        stub_current_user(student1, student1.role.name, student1.role)
        expect(controller.send(:action_allowed?)).to be false
      end
    end
  end

  describe 'create teams method' do
    context 'when everything is right' do
      it 'creates teams with random names' do
        allow(Object).to receive_message_chain(:const_get, :find).with(any_args).and_return(assignment1)
        allow(Team).to receive(:randomize_all_by_parent).with(any_args)
        allow(Version).to receive_message_chain(:where, :last).with(any_args).and_return(0.1)
        #ExpertizaLogger.info.should eq(1)
        #allow(ExpertizaLogger).to receive(:info).and_return(1)
        #expect(ExpertizaLogger.info).to be_nil

        para = {response_id: 1, id: 1, team_size: 2}
        session = {user: instructor, team_type: "Assignment"}
        result = get :create_teams, para, session
        expect(result.status).to eq 302
        expect(result).to redirect_to(:action => 'list', :id => assignment1.id)
      end
    end
  end
=end
  describe 'list method' do
    context 'when everything is right' do
      it 'lists the teams' do
        params = {response_id: 1, id: 1, type: 'Assignment'}
        session = {user: instructor}
        result = get :list, params, session
        expect(result.status).to eq 200
      end
    end
    context 'when type is wrong' do
      it 'lists the teams' do
        params = {response_id: 1, id: 1, type: 'Course'}
        session = {user: instructor}
        result = get :list, params, session
        expect(result.status).to eq 200
      end
    end
    context 'when type is wrong' do
      it 'lists the teams' do
        params = {response_id: 1, id: 1, type: 'Subject'}
        session = {user: instructor}
        result = get :list, params, session
        expect(result.status).to eq 200
      end
    end
  end
=begin
  describe 'new method' do
    it 'creates a new team successfully' do
      allow(Object).to receive_message_chain(:const_get, :find).with(any_args).and_return(assignment1)
      para = {response_id: 1, team_id: team1.id}
      session = {user: ta}
      result = get :new, para, session
      expect(result.status).to eq 200
      expect(controller.instance_variable_get(:@parent)).to eq assignment1
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
      para = {response_id: 1, team_id: team1.id}
      session = {user: ta}
      result = get :edit, para, session
      expect(result.status).to eq 200
      expect(controller.instance_variable_get(:@team)).to eq team1
    end
  end

  describe 'inherit method' do

  end

  describe 'bequeath method' do

  end
=end

end
