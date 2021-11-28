require './spec/support/teams_shared.rb'

describe AdvertiseForPartnerController do
  include_context 'object initializations'

  describe 'action allowed method' do
    context 'provides access after' do
      include_context 'authorization check'
    end
    context 'provides access to student' do
      it 'for create if they belong to assignment' do
        allow(AssignmentTeam).to receive (:find_by).and_return(assignment1)
        stub_current_user(student1, student1.role.name, student1.role)
        params = {action: 'create'}
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end
  
  describe 'edit' do
    it 'passes the test' do
      #allow(Team).to receive(:find).and_return(team1)
      para = {team_id: team1.id}
      session = {user: ta}
      result = get :edit, para, session
      expect(result.status).to eq 200
      expect(controller.instance_variable_get(:@team)).to eq team1
    end  
  end  

end
