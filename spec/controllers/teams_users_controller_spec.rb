require './spec/support/teams_shared.rb'

describe TeamsUsersController do
  include_context 'object initializations'
  let(:teamUser) { build(:team_user, id:1, team_id:1, user_id:1) }
  #let(:team) { build(:assignment_team, id: 1, assignment: assignment1) }
  #let(:student) {build_stubbed(:student, id:1, name: :lily)}
  #let(:assignment) { build(:assignment, instructor_id: 6, id: 1) }

  include_context 'authorization check'
  context 'not provides access to people with' do
    it 'student credentials' do
      stub_current_user(student1, student1.role.name, student1.role)
      expect(controller.send(:action_allowed?)).to be false
    end
  end

  describe '#list' do
    context 'when list is clicked' do
    it 'renders list of users under Assignment team' do
      allow(Team).to receive(:find).with('1').and_return(team1)
      allow(Assignment).to receive(:find).with(1).and_return(assignment1)
      @params = {id:1}
      session = {user: instructor}
      get :list, @params, session
      expect(response).to render_template(:list)
    end
    end
  end

  describe '#create' do
    context 'when create user' do
    it 'flash error when user is not defined' do
      allow(User).to receive(:find_by).with(name: 'instructor6').and_return(nil)
      allow(Team).to receive(:find).with('1').and_return(team1)
      session = {user: admin}
      params = {
          user: {name: 'instructor6'}, id: 1
      }
      post :create, params, session
      expect(flash[:error]).to eq "\"instructor6\" is not defined. Please <a href=\"http://test.host/users/new\">create</a> this user before continuing."
      expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end
    end

    context 'when create user' do
    it 'flash error when user added to assignment Team is not defined' do
      allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
      allow(Team).to receive(:find).with('1').and_return(team1)
      allow(AssignmentTeam).to receive(:find).with('1').and_return(team1)
      allow(Assignment).to receive(:find).with(1).and_return(assignment1)
      allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(nil)
      session = {user: admin}
      params = {
          user: {name: 'student2065'}, id: 1
      }
      post :create, params, session
      expect(flash[:error]).to eq "\"student2065\" is not a participant of the current assignment. Please <a href=\"http://test.host/participants/list?authorization=participant&id=1&model=Assignment\">add</a> this user before continuing."
      expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end
    end

    context 'when create user' do
    it 'flash error when assignmentTeam has maximum number of participants' do
      allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
      allow(Team).to receive(:find).with('1').and_return(team1)
      allow(AssignmentTeam).to receive(:find).with('1').and_return(team1)
      allow(Assignment).to receive(:find).with(1).and_return(assignment1)
      allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
      allow_any_instance_of(Team).to receive(:add_member).with(any_args).and_return(false)
      session = {user: admin}
      params = {
          user: {name: 'student2065'}, id: 1
      }
      post :create, params, session
      expect(flash[:error]).to eq "This team already has the maximum number of members."
      expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end
    end

    context 'when create user' do
      it 'new user gets successfully added to assignment' do
        allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to receive(:find).with('1').and_return(team1)
        allow(AssignmentTeam).to receive(:find).with('1').and_return(team1)
        allow(Assignment).to receive(:find).with(1).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
        allow_any_instance_of(Team).to receive(:add_member).with(any_args).and_return(true)
        session = {user: admin}
        params = {
            user: {name: 'student2065'}, id: 1
        }
        post :create, params, session
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end

    context 'when create user' do
    it 'flash error when user added to course Team is not defined' do
      allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
      allow(Team).to receive(:find).with('5').and_return(team5)
      allow(CourseTeam).to receive(:find).with('5').and_return(team5)
      allow(Course).to receive(:find).with(1).and_return(course1)
      allow(CourseParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(nil)
      session = {user: admin}
      params = {
          user: {name: 'student2065'}, id: 5
      }
      post :create, params, session
      expect(flash[:error]).to eq "\"student2065\" is not a participant of the current course. Please <a href=\"http://test.host/participants/list?authorization=participant&id=1&model=Course\">add</a> this user before continuing."
      expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end
    end

    context 'when create user' do
    it 'flash error when courseTeam has maximum number of participants' do
      allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
      allow(Team).to receive(:find).with('5').and_return(team5)
      allow(CourseTeam).to receive(:find).with('5').and_return(team5)
      allow(Course).to receive(:find).with(1).and_return(course1)
      allow(CourseParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
      allow_any_instance_of(Team).to receive(:add_member).with(any_args).and_return(false)
      session = {user: admin}
      params = {
          user: {name: 'student2065'}, id: 5
      }
      post :create, params, session
      expect(flash[:error]).to eq "This team already has the maximum number of members."
      expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end
    end

    context 'when create user' do
      it 'new user gets successfully added to course' do
        allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to receive(:find).with('5').and_return(team5)
        allow(CourseTeam).to receive(:find).with('5').and_return(team5)
        allow(Course).to receive(:find).with(1).and_return(course1)
        allow(CourseParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
        allow_any_instance_of(Team).to receive(:add_member).with(any_args).and_return(true)
        session = {user: admin}
        params = {
            user: {name: 'student2065'}, id: 5
        }
        post :create, params, session
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end
  end

  context '#delete' do
    context 'when user is deleted' do
    it 'deletes the user and redirects to Teams#list page' do
      allow(TeamsUser).to receive(:find).with("1").and_return(teamUser)
      allow(Team).to receive(:find).with(teamUser.team_id).and_return(team1)
      allow(User).to receive(:find).with(teamUser.user_id).and_return(student1)
      @params = {id:1}
      session = {user: instructor}
      post :delete, @params, session
      expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end
    end
  end
end


