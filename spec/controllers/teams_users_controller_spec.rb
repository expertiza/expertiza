require './spec/support/teams_shared.rb'

describe TeamsUsersController do
  let(:team) { build(:assignment_team, id: 1, assignment: assignment) }
  let(:student) {build_stubbed(:student, id:1, name: :lily)}
  let(:assignment) { build(:assignment, instructor_id: 6, id: 1) }
  #let(:team) {build_stubbed(:team)}
  #let(:Object) {build_stubbed(:Object)}

  include_context 'authorization check'
  context 'not provides access to people with' do
    it 'student credentials' do
      stub_current_user(student, student.role.name, student.role)
      expect(controller.send(:action_allowed?)).to be false
    end
  end

  context '#list' do
    it 'renders list of users under Assignment team' do
      allow(Team).to receive(:find).with('1').and_return(team)
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      @params = {id:1}
      session = {user: instructor}
      get :list, @params, session
      expect(response).to render_template(:list)
    end
  end

  context '#create' do
    it 'flash error when user is not defined' do
      allow(User).to receive(:find_by).with(name: 'instructor6').and_return(nil)
      allow(Team).to receive(:find).with('1').and_return(team)
      session = {user: admin}
      params = {
          user: {name: 'instructor6'}, id: 1
      }
      post :create, params, session
      expect(flash[:error]).to eq "\"instructor6\" is not defined. Please <a href=\"http://test.host/users/new\">create</a> this user before continuing."
      expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end

    it 'flash error when assignmentParticipant is not defined' do
      allow(User).to receive(:find_by).with(name: 'lily').and_return(student)
      allow(Team).to receive(:find).with('1').and_return(team)
      allow(AssignmentTeam).to receive(:find).with('1').and_return(team)
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(nil)
      session = {user: admin}
      params = {
          user: {name: 'lily'}, id: 1
      }
      post :create, params, session
      expect(flash[:error]).to eq "\"lily\" is not a participant of the current assignment. Please <a href=\"http://test.host/participants/list?authorization=participant&id=1&model=Assignment\">add</a> this user before continuing."
      #expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end
  end

end


