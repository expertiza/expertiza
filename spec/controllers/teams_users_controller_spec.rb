require './spec/support/teams_shared.rb'

describe TeamsParticipantController do
  # Including the stubbed objects from the teams_shared.rb file
  include_context 'object initializations'
  # Objects initialization for team participants
  let(:teamParticipant) { build(:teams_participant, id: 1, team_id: 1, participant_id: 1) }
  let(:teamParticipant2) { build(:teams_participant, id: 2, team_id: 1, participant_id: 2) }
  let(:assignment) do
    build(:assignment, id: 1, name: 'test assignment', instructor_id: 6, staggered_deadline: true, directory_path: 'same path',
                       participants: [build(:participant)], teams: [build(:assignment_team)], course_id: 1)
  end
  let(:assignment_form) { double('AssignmentForm', assignment: assignment) }
  let(:student) { build(:student) }
  let(:duty) { build(:duty, id: 1, name: 'Role', max_members_for_duty: 2, assignment_id: 1) }
  let(:teams_participant1) { TeamsParticipant.new id: 1, duty_id: 1 }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    stub_current_user(student, student.role.name, student.role)
  end

  describe '#action_allowed?' do
    context 'when request_params action is update duties' do
      before(:each) do
        controller.params = { id: '1', action: 'update_duties' }
      end

      context 'when the role current user is student' do
        it 'allows certain action' do
          stub_current_user(student, student.role.name, student.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end
    end
  end

  describe '#update_duties' do
    it 'updates the duties for the participant' do
      allow(TeamsParticipant).to receive(:find).with('1').and_return(teams_participant1)
      allow(teams_participant1).to receive(:update_attribute).with(any_args).and_return('OK')
      request_params = {
        teams_participant_id: '1',
        teams_participant: { duty_id: '1' },
        participant_id: '1'
      }
      user_session = { user: stub_current_user(student, student.role.name, student.role) }
      get :update_duties, params: request_params, session: user_session
      expect(response).to redirect_to('/student_teams/view?student_id=1')
    end
  end

  # Including the shared method from the teams_shared.rb file
  include_context 'authorization check'
  context 'not provides access to people with' do
    it 'student credentials' do
      stub_current_user(student1, student1.role.name, student1.role)
      expect(controller.send(:action_allowed?)).to be false
    end
  end

  # Test team participants list functionality
  describe '#list' do
    context 'when list is clicked' do
      it 'renders list of participants under Assignment team teams#participants' do
        allow(Team).to receive(:find).with('1').and_return(team1)
        allow(Assignment).to receive(:find).with(1).and_return(assignment1)
        request_params = { id: 1 }
        user_session = { user: instructor }
        get :list, params: request_params, session: user_session
        expect(response).to render_template(:list)
      end
    end
  end

  # Test team participants controller new method
  describe '#new' do
    it 'sets the Team object to instance variable' do
      allow(Team).to receive(:find).with('1').and_return(team1)
      request_params = { id: 1 }
      user_session = { user: instructor }
      get :new, params: request_params, session: user_session
      expect(controller.instance_variable_get(:@team)).to eq(team1)
    end
  end

  # Test adding new participant to assignment or course team
  describe '#create' do
    context 'when participant is added to assignment or course team' do
      it 'it throws error when participant is not defined' do
        allow(User).to receive(:find_by).with(name: 'instructor6').and_return(nil)
        allow(Team).to receive(:find).with('1').and_return(team1)
        user_session = { user: admin }
        request_params = {
          user: { name: 'instructor6' }, id: 1
        }
        post :create, params: request_params, session: user_session
        expect(flash[:error]).to eq '"instructor6" is not defined. Please <a href="http://test.host/users/new">create</a> this user before continuing.'
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end

    context 'when participant is added to assignment team' do
      it 'it throws error when participant added is not a participant of the current assignment' do
        allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to receive(:find).with('1').and_return(team1)
        allow(AssignmentTeam).to receive(:find).with('1').and_return(team1)
        allow(Assignment).to receive(:find).with(1).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(nil)
        user_session = { user: admin }
        request_params = {
          user: { name: 'student2065' }, id: 1
        }
        post :create, params: request_params, session: user_session
        expect(flash[:error]).to eq '"student2065" is not a participant of the current assignment. Please <a href="http://test.host/participants/list?authorization=participant&id=1&model=Assignment">add</a> this user before continuing.'
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end

    context 'when participant is added to assignment team' do
      it 'it throws error when assignmentTeam has maximum number of participants' do
        allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to receive(:find).with('1').and_return(team1)
        allow(AssignmentTeam).to receive(:find).with('1').and_return(team1)
        allow(Assignment).to receive(:find).with(1).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
        allow_any_instance_of(Team).to receive(:add_member).with(any_args).and_return(false)
        user_session = { user: admin }
        request_params = {
          user: { name: 'student2065' }, id: 1
        }
        post :create, params: request_params, session: user_session
        expect(flash[:error]).to eq 'This team already has the maximum number of members.'
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end

    context 'when participant is added to assignment team' do
      it 'new participant gets successfully added to the assignment' do
        allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to receive(:find).with(any_args).and_return(team1)
        allow(AssignmentTeam).to receive(:find).with('1').and_return(team1)
        allow(Assignment).to receive(:find).with(1).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
        allow_any_instance_of(Team).to receive(:add_member).with(any_args).and_return(true)
        allow(TeamsParticipant).to receive(:last).with(any_args).and_return(student1)
        allow(TeamsParticipant).to receive(:last).with(any_args).and_return(student1)
        user_session = { user: admin }
        request_params = {
          user: { name: 'student2065' }, id: 1
        }
        post :create, params: request_params, session: user_session
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end

    context 'when participant is added to course team' do
      it 'it throws error when participant added to course Team is not defined' do
        allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to receive(:find).with('5').and_return(team5)
        allow(CourseTeam).to receive(:find).with('5').and_return(team5)
        allow(Course).to receive(:find).with(1).and_return(course1)
        allow(CourseParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(nil)
        user_session = { user: admin }
        request_params = {
          user: { name: 'student2065' }, id: 5
        }
        post :create, params: request_params, session: user_session
        expect(flash[:error]).to eq '"student2065" is not a participant of the current course. Please <a href="http://test.host/participants/list?authorization=participant&id=1&model=Course">add</a> this user before continuing.'
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end

    context 'when participant is added to course team' do
      it 'it throws error when courseTeam has maximum number of participants' do
        allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to receive(:find).with('5').and_return(team5)
        allow(CourseTeam).to receive(:find).with('5').and_return(team5)
        allow(Course).to receive(:find).with(1).and_return(course1)
        allow(CourseParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
        allow_any_instance_of(CourseTeam).to receive(:add_member).with(any_args).and_return(false)
        user_session = { user: admin }
        request_params = {
          user: { name: 'student2065' }, id: 5
        }
        post :create, params: request_params, session: user_session
        expect(flash[:error]).to eq 'This team already has the maximum number of members.'
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end

    context 'when participant is added to course team' do
      it 'new participant gets successfully added to course' do
        allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to receive(:find).with('5').and_return(team5)
        allow(CourseTeam).to receive(:find).with('5').and_return(team5)
        allow(TeamsParticipant).to receive(:create).with(participant_id: 1, team_id: 5).and_return(double('TeamsParticipant', id: 1))
        allow(TeamNode).to receive(:find_by).with(node_object_id: 5).and_return(double('TeamNode', id: 1))
        allow(TeamUserNode).to receive(:create).with(parent_id: 1, node_object_id: 1).and_return(double('TeamUserNode', id: 1))
        allow(Course).to receive(:find).with(1).and_return(course1)
        allow(CourseParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
        allow_any_instance_of(CourseTeam).to receive(:add_member).with(any_args).and_return(true)
        user_session = { user: admin }
        request_params = {
          user: { name: 'student2065' }, id: 5
        }
        post :create, params: request_params, session: user_session
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end

    context 'when participant is already on an assignment team' do
      it 'returns redirect_back' do
        allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to receive(:find).with(any_args).and_return(team1)
        allow(AssignmentTeam).to receive(:find).with('1').and_return(team1)
        allow(Assignment).to receive(:find).with(1).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
        allow_any_instance_of(Team).to receive(:add_member).with(any_args).and_return(true)
        allow(TeamsParticipant).to receive(:last).with(any_args).and_return(student1)
        allow(TeamsParticipant).to receive(:last).with(any_args).and_return(student1)
        allow(assignment1).to receive(:user_on_team?).with(student1).and_return(true)
        user_session = { user: admin }
        request_params = {
          user: { name: 'student2065' }, id: 1
        }
        post :create, params: request_params, session: user_session
        expect(flash[:error]).to eq 'This user is already assigned to a team for this assignment'
        expect(response).to redirect_to('http://test.host/')
      end
    end

    context 'when participant is added to assignment team while on a team already' do
      it 'it throws error that they are already on a team' do
        allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to receive(:find).with('1').and_return(team1)
        allow(AssignmentTeam).to receive(:find).with('1').and_return(team1)
        allow(Assignment).to receive(:find).with(1).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
        allow_any_instance_of(Team).to receive(:add_member).with(any_args).and_raise("Member on existing team error")
        user_session = { user: admin }
        request_params = {
          user: { name: 'student2065' }, id: 1
        }
        post :create, params: request_params, session: user_session
        expect(flash[:error]).to eq 'The user student2065 is already a member of the team wolfers'
        expect(response).to redirect_to('http://test.host/')
      end
    end

    context 'when participant is already on a course team' do
      it 'returns redirect_back' do
        allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to receive(:find).with('5').and_return(team5)
        allow(CourseTeam).to receive(:find).with('5').and_return(team5)
        allow(TeamsParticipant).to receive(:create).with(participant_id: 1, team_id: 5).and_return(double('TeamsParticipant', id: 1))
        allow(TeamNode).to receive(:find_by).with(node_object_id: 5).and_return(double('TeamNode', id: 1))
        allow(TeamUserNode).to receive(:create).with(parent_id: 1, node_object_id: 1).and_return(double('TeamUserNode', id: 1))
        allow(Course).to receive(:find).with(1).and_return(course1)
        allow(CourseParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
        allow_any_instance_of(CourseTeam).to receive(:add_member).with(any_args).and_return(true)
        allow(course1).to receive(:user_on_team?).with(student1).and_return(true)
        user_session = { user: admin }
        request_params = {
          user: { name: 'student2065' }, id: 5
        }
        post :create, params: request_params, session: user_session
        expect(flash[:error]).to eq 'This user is already assigned to a team for this course'
        expect(response).to redirect_to('http://test.host/')
      end
    end

    context 'when participant is added to course team while on a team already' do
      it 'it throws error that they are already on a team' do
        allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to receive(:find).with('5').and_return(team5)
        allow(CourseTeam).to receive(:find).with('5').and_return(team5)
        allow(Course).to receive(:find).with(1).and_return(course1)
        allow(CourseParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
        allow_any_instance_of(CourseTeam).to receive(:add_member).with(any_args).and_raise("Member on existing team error")
        user_session = { user: admin }
        request_params = {
          user: { name: 'student2065' }, id: 5
        }
        post :create, params: request_params, session: user_session
        expect(flash[:error]).to eq 'The user student2065 is already a member of the team team5'
        expect(response).to redirect_to('http://test.host/')
      end
    end
  end

  # Test delete participant from team
  describe '#delete' do
    context 'when participant is deleted' do
      it 'it deletes the participant and redirects to Teams#list page' do
        allow(TeamsParticipant).to receive(:find).with('1').and_return(teamParticipant)
        allow(Team).to receive(:find).with(teamParticipant.team_id).and_return(team1)
        allow(User).to receive(:find).with(teamParticipant.participant.user_id).and_return(student1)
        request_params = { id: 1 }
        user_session = { user: instructor }
        post :delete, params: request_params, session: user_session
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end
  end

  # Test delete selected participants from team
  describe '#delete_selected' do
    context 'when selected participants are deleted' do
      it 'it deletes the selected participants and redirects to Teams#list page' do
        allow(TeamsParticipant).to receive(:find).with('1').and_return([teamParticipant])
        allow(TeamsParticipant).to receive(:find).with('2').and_return([teamParticipant2])
        request_params = { item: [1, 2] }
        user_session = { user: instructor }
        post :delete_selected, params: request_params, session: user_session
        expect(response).to redirect_to('http://test.host/teams_participants/list')
      end
    end
  end
end
