describe PairProgrammingController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:admin) { build(:admin, id: 3) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:student2) { build(:student, id: 22, role_id: 1) }
  let(:ta) { build(:teaching_assistant, id: 6) }  
  
  let(:team_user1) { build(:team_user, id: 1, team: team, user: student1, pair_programming_status: "Z") }
  let(:team_user2) { build(:team_user, id: 2, team: team, user: student2, pair_programming_status: "Z") }
  let(:team) { build(:assignment_team, id: 1, parent_id: 1, pair_programming_request: 0) }
  
  #load student object with id 21
  before(:each) do
    allow(User).to receive(:find).with(21).and_return(student1)
  end

  describe '#action_allowed?' do
    #check if super-admin is able to perform the actions
    it 'allows super_admin to perform certain action' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end

    #check if instructor is able to perform the actions
    it 'allows instructor to perform certain action' do
      stub_current_user(instructor1, instructor1.role.name, instructor1.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end

    #check if student is able to perform the actions
    it 'allows student to perform certain action' do
      stub_current_user(student1, student1.role.name, student1.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end

    #check if teaching assisstant is able to perform the actions
    it 'allows teaching assisstant to perform certain action' do
      stub_current_user(ta, ta.role.name, ta.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end

    #check if admin is able to perform the actions
    it 'allows admin to perform certain action' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end
  end

  describe '#send_invitations' do
    it 'sends pair programming invitation to all the team members' do
      users = allow(TeamsUser).to receive(:where).and_return([team_user1,team_user2])
      [users].each do |user|
        allow(user).to receive(:update_attributes).and_return(true)
      end
      user1 = allow(TeamsUser).to receive(:find_by).and_return(team_user1)
      allow(user1).to receive(:update_attributes).and_return(true)
      team1 = allow(Team).to receive(:find).and_return(team)
      allow(team1).to receive(:update_attributes).and_return(true)
      user_session = { user: student1 }
      params = {team_id: team.id, user_id: student1.id}
      result = post :send_invitations, params: params, session: user_session
      expect(flash[:success]).to eq('Invitations have been sent successfully!')
      expect(result.status).to eq 302
      expect(result).to redirect_to('/student_teams/view')
    end
  end

  describe '#accept' do
    it 'accepts the pair programming request' do
      user1 = allow(TeamsUser).to receive(:find_by).and_return(team_user1)
      allow(user1).to receive(:update_attributes).and_return(true)
      user_session = { user: student1 }
      params = {team_id: team.id, user_id: student1.id}
      result = post :accept, params: params, session: user_session
      expect(flash[:success]).to eq('Pair Programming Request Accepted Successfully!')
      expect(result.status).to eq 302
      expect(result).to redirect_to('/student_teams/view')
    end
  end

  describe '#decline' do
    it 'declines the pair programming request' do
      user1 = allow(TeamsUser).to receive(:find_by).and_return(team_user1)
      allow(user1).to receive(:update_attributes).and_return(true)
      team1 = allow(Team).to receive(:find).and_return(team)
      allow(team1).to receive(:update_attributes).and_return(true)
      user_session = { user: student1 }
      params = {team_id: team.id, user_id: student1.id}
      result = post :decline, params: params, session: user_session
      expect(flash[:success]).to eq('Pair Programming Request Declined!')
      expect(result.status).to eq 302
      expect(result).to redirect_to('/student_teams/view')
    end
  end

end