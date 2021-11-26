require './spec/support/teams_shared.rb'

describe TeamsController do
  include_context 'object initializations'

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
      let(:logmsg) {build_stubbed(:loggermessage, message: "Random teams have been successfully created.")}
      it 'creates teams with random names' do
        allow(Object).to receive_message_chain(:const_get, :find).with(any_args).and_return(team1.type)
        allow(Team).to receive(:randomize_all_by_parent).with(any_args)
        #allow(ApplicationController).to receive(:undo_link).with(message).and_return(nil)
        allow(Version).to receive_message_chain(:where, :last).with(any_args).and_return(5.3)
        allow(LoggerMessage).to receive(:new).with(any_args).and_return(logmsg)

        para = {response_id: 1, team_size: 2}
        session = {user: ta}
        result = get :create_teams, para, session
        #expect(result.status).to eq 200
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
      session = {user: ta}
      result = get :new, para, session
      expect(result.status).to eq 200
      expect(controller.instance_variable_get(:@parent)).to eq team1.type
    end
  end

  describe 'create method' do

  end
=begin
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
=end
  describe 'edit method' do
    it 'passes the test' do
      allow(Team).to receive(:find).and_return(team1)
      para = {response_id: 1, team_id: 1}
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

end
