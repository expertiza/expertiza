require './spec/support/teams_shared.rb'

describe StudentTeamsController do
  include_context 'object initializations'
  include_context 'authorization check'
  context 'provides access to people with' do
    it 'student credentials' do
      stub_current_user(student1, student1.role.name, student1.role)
      expect(controller.send(:action_allowed?)).to be true
    end
  end

  let(:student_teams_controller) { StudentTeamsController.new }
  let(:student) { double "student" }
  describe '#view' do
    it 'sets the student' do
      allow(AssignmentParticipant).to receive(:find).with('12345').and_return student
      allow(student_teams_controller).to receive(:current_user_id?)
      allow(student_teams_controller).to receive(:params).and_return(student_id: '12345')
      allow(student).to receive(:user_id)
      student_teams_controller.view
    end
  end

  describe '#create' do
    context "name is empty" do
      it "flash notice" do
        allow(AssignmentTeam).to receive(:where).with(name: '', parent_id: 1).and_return(nil)
        allow(student_teams_controller).to receive(:params).and_return(team: nil)
        expect(flash[:notice]).to eq nil
      end
    end
    context "create team" do
      it "saves the team" do
        allow(AssignmentNode).to receive(:find_by).with(node_object_id: 1).and_return(node1)
        allow(AssignmentTeam).to receive(:new).with(name: 'test', parent_id: 1).and_return(team7)
        allow(team7).to receive(:save).and_return(true)
        expect(response.status).to eq(200)

      end
    end
    context "name already in use" do
      it "flash notice" do
        allow(AssignmentTeam).to receive(:where).with(name: 'test', parent_id: 1).and_return(team7)
        expect(flash[:notice]).to eq nil
      end
    end
  end

  describe '#update' do
    context 'update team name' do
      it 'update name' do
        controller = StudentTeamsController.new
        allow(AssignmentTeam).to receive(:where).with(name: 'test', parent_id: 1).and_return(team7)
        team = {
          name: 'test'
        }
        expect(flash[:notice]).to eq(nil)
      end
    end
  end


  # describe '#remove_participant' do
  #  context 'remove team user' do
  #    it 'remove user' do
  #      controller = StudentTeamsController.new
  #    allow(TeamsUser).to receive(:where).with(team_id: 1, user_id: 1).and_return(team_user1)
  #    expect(controller).to receive(:remove_team_user)
  #    end
  #  end
  #  context 'delete team' do
  #    it 'if team has no members delete team' do
  #      controller = StudentTeamsController.new
  #      allow(TeamsUser).to receive(:where).with(team_id: 1, user_id: 1).and_return(team_user1)
  #      expect(controller).to receive(:remove_team_user)
  #      allow(TeamsUser).to receive(:where).with(team_id: '').and_return(nil)
  #      allow(AssignmentTeam).to receive(:find).with(team_id: 1).and_return(team7)
  #      allow(team7).to receive(:destroy)
  #      expect(Waitlist).to receive(:remove_from_waitlists)
  #    end
  #  end
  #
  # end



end
