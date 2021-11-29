require './spec/support/teams_shared.rb'

describe AdvertiseForPartnerController do
  include_context 'object initializations'
  let(:team1user1) { build_stubbed(:team_user, id: 1, team: team1, user: student1)}
  let(:team1user2) { build_stubbed(:team_user, id: 2, team: team1, user: student2)}

  describe 'action allowed method' do
    context 'provides access when called directly' do
      include_context 'authorization check'
      it 'for student' do
        stub_current_user(student1, student1.role.name, student1.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
    context 'performs access check when called before' do
      #we expect it to redirect us because we are only calling the create method to check the authorization that happens before controller enters the method itself
      it 'create method' do
        allow(AssignmentTeam).to receive_message_chain(:find_by, :assignment).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:exists?).and_return(true)
        session = {user: student1}
        result = get :create, session
        expect(result.status).to eq 302
      end
      it 'update method' do
        allow(AssignmentTeam).to receive_message_chain(:find_by, :assignment).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:exists?).and_return(true)
        session = {user: student1}
        result = get :update, session
        expect(result.status).to eq 302
      end
      it 'edit method' do
        allow(AssignmentTeam).to receive_message_chain(:find_by, :assignment).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:exists?).and_return(true)
        session = {user: student1}
        result = get :edit, session
        expect(result.status).to eq 302
      end
      it 'remove method' do
        allow(AssignmentTeam).to receive_message_chain(:find_by, :assignment).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:exists?).and_return(true)
        session = {user: student1}
        result = get :remove, session
        expect(result.status).to eq 302
      end
    end
  end

  describe 'edit method' do
    it 'passes the test' do
      allow(AssignmentTeam).to receive(:find_by).and_return(team1)
      allow(AssignmentTeam).to receive_message_chain(:find_by, :assignment).and_return(assignment1)
      allow(AssignmentParticipant).to receive(:exists?).and_return(true)
      para = {id: team1.id, team_id: team1.id}
      session = {user: student1}
      result = get :edit, para, session
      expect(result.status).to eq 200
      expect(controller.instance_variable_get(:@team)).to eq team1
    end
  end

  describe "POST #create" do

    context "when it is valid" do
      it "will create an advertisement" do
        allow(AssignmentTeam).to receive(:find_by).and_return(team1)
        allow(AssignmentParticipant).to receive(:exists?).and_return(true)
        allow(team1).to receive(:assignment).and_return(assignment1)
        allow(team1).to receive(:update_attributes).and_return(true)
        allow(AssignmentParticipant).to receive(:find_by).and_return(participant)

        params  = {
          id: team1.id,
          team_id: team1.id,
        }
        session = {user: ta}
        result = get :create, params, session
        expect(result.status).to eq 302
        expect(result).to redirect_to(view_student_teams_path(:student_id => 1))
      end
    end
  end
end
