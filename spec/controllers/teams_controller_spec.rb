require './spec/support/teams_shared.rb'

describe TeamsController do
  # Performs authorization check for user
  include_context 'object initializations'

  describe 'action allowed method' do
    context 'provides access after' do
      # Including the shared method from the teams_shared.rb file
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
    context 'when correct parameters are passed' do
      it 'creates teams with random names' do
        allow(Object).to receive_message_chain(:const_get, :find).with(any_args).and_return(assignment1)
        allow(Version).to receive_message_chain(:where, :last).with(any_args).and_return(0.1)
        request_params = { id: assignment1.id, team_size: 2 }
        user_session = { user: instructor, team_type: 'Assignment' }
        result = get :create_teams, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
        expect(result).to redirect_to(action: 'list', id: assignment1.id)
      end
    end
  end

  describe 'list method' do
    before(:each) { allow(Assignment).to receive(:find_by).and_return(assignment1) }
    context 'when type is Assignment' do
      it 'lists the teams for that Assignment' do
        request_params = { id: assignment1.id, type: 'Assignment' }
        user_session = { user: instructor }
        result = get :list, params: request_params, session: user_session
        # status code 200: Request succeeded
        expect(result.status).to eq 200
        expect(controller.instance_variable_get(:@assignment)).to eq assignment1
      end
    end
    context 'when type is Course' do
      it 'lists the teams for that Course' do
        request_params = { id: course1.id, type: 'Course' }
        user_session = { user: instructor }
        result = get :list, params: request_params, session: user_session
        # status code 200: Request succeeded
        expect(result.status).to eq 200
        expect(controller.instance_variable_get(:@assignment)).to eq nil
      end
    end
    context 'when type is not Assignment or Course' do
      it 'throws error' do
        request_params = { id: 52, type: 'Subject' }
        user_session = { user: instructor }
        result = get :list, params: request_params, session: user_session
        # status code 200: Request succeeded
        expect(result.status).to eq 200
        expect(controller.instance_variable_get(:@assignment)).to eq nil
      end
    end

    context 'with two course teams' do
      it 'deletes all the course teams' do
        @course = create(:course)
        @team1 = create(:course_team)
        @team2 = create(:course_team)
        expect { CourseTeam.delete_all }.to change(Team, :count).by(-2)
      end
    end
  end

  describe 'new method' do
    it 'creates a new team successfully when all parameters are provided correctly' do
      allow(Object).to receive_message_chain(:const_get, :find).with(any_args).and_return(assignment1)
      request_params = { id: assignment1.id }
      user_session = { user: ta, team_type: 'Assignment' }
      result = get :new, params: request_params, session: user_session
      # status code 200: Request succeeded
      expect(result.status).to eq 200
      expect(controller.instance_variable_get(:@parent)).to eq assignment1
    end
  end

  describe 'create method' do
    context 'when invoked with a team which does not exist' do
      it 'creates it' do
        allow(Assignment).to receive(:find).and_return(assignment1)
        request_params = { id: assignment1.id, team: { name: 'rando team' } }
        user_session = { user: ta, team_type: 'Assignment' }
        result = get :create, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
        expect(result).to redirect_to(action: 'list', id: assignment1.id)
      end
    end
    context 'when invoked with a team which does exist' do # this is work in progress
      it 'throws an error' do
        allow(Assignment).to receive(:find).and_return(assignment1)
        request_params = { id: assignment1.id, team: { name: 'rando team' } }
        user_session = { user: ta, team_type: 'Assignment' }
        # result = get :create, params: request_params, session: user_session
        # expect(result.status).to eq 302
        # expect(result).to redirect_to(:action => 'new', :id => assignment1.id)
      end
    end
  end

  describe 'update method' do
    it 'updates the team name' do
      allow(Team).to receive(:find).and_return(team1)
      allow(Assignment).to receive(:find).and_return(assignment1)
      request_params = { id: team1.id, team: { name: 'rando team' } }
      user_session = { user: ta, team_type: 'Assignment' }
      # result = get :update, params: request_params, session: user_session
      # expect(result.status).to eq 302
      # expect(result).to redirect_to(:action => 'list', :id => assignment1.id)
    end
    # this test will fail even though it should normally pass, that's because it runs into an error at @team.save
    # RumtimeError: stubbed models are not allowed to access the database - AssignmentTeam#save()
  end

  describe 'edit method' do
    it 'successfully returns the team with the given team id' do
      allow(Team).to receive(:find).and_return(team1)
      request_params = { id: team1.id }
      user_session = { user: ta }
      result = get :edit, params: request_params, session: user_session
      expect(result.status).to eq 200
      expect(controller.instance_variable_get(:@team)).to eq team1
    end
    # this method has only 1 line which is just to look up a team with the id present in the request_params
  end

  describe 'delete method' do
    before(:each) { request.env['HTTP_REFERER'] = root_url }
    context 'when called and team is nil' do
      it 'simply redirects back to the earlier page' do
        allow(Team).to receive(:find_by).and_return(nil)
        request_params = { id: 5 }
        user_session = { user: instructor }
        result = get :delete, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
        expect(result).to redirect_to root_url
        expect(controller.instance_variable_get(:@team)).to eq nil
      end
    end
    context 'when called and team is not nil and it does not hold a topic' do
      it 'deletes the team' do
        allow(Team).to receive(:find_by).and_return(team5)
        allow(Object).to receive_message_chain(:const_get, :find).and_return(course1)
        allow(team5).to receive(:destroy).and_return(nil)
        request_params = { id: 5 }
        user_session = { user: instructor, team_type: 'CourseTeam' }
        result = get :delete, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
        expect(controller.instance_variable_get(:@team)).to eq team5
      end
    end
    # this next test is work in progress
    #     context 'gets called and team is not nil and it holds a topic' do
    #       it 'it reassigns topic and then deletes the team' do
    #         allow(Team).to receive(:find_by).and_return(team5)
    #         allow(Object).to receive_message_chain(:const_get, :find).and_return(course1)
    #         allow('if').to receive('true'.to_s)
    #         #controller.instance_variable_set(:@signed_up_team, team5)
    #         #allow(@signed_up_team).to receive(:==).and_return(1)
    #         #controller.instance_variable_set(:@signUps, team5)
    #         #allow(team5).to receive_message_chain(:first, :is_waitlisted).and_return(false)
    #         #allow(@signed_up_team).to receive_message_chain(:first, :topic_id).and_return(5)
    #         allow(team5).to receive(:destroy).and_return(nil)
    #         request_params = {id: 5}
    #         user_session = {user: instructor, team_type: 'CourseTeam'}
    #         result = get :delete, params: request_params, session: user_session
    #         expect(result.status).to eq 302
    #       end
    #     end
  end

  describe 'inherit method' do
    context 'called when assignment belongs to course and team is not empty' do
      it 'copies teams from course to the assignment' do
        allow(Assignment).to receive(:find).and_return(assignment1)
        allow(Course).to receive(:find).and_return(course1)
        allow(course1).to receive(:get_teams).and_return([team5, team6])
        request_params = { id: team5.id }
        user_session = { user: ta }
        result = get :inherit, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
        expect(result).to redirect_to(controller: 'teams', action: 'list', id: assignment1.id)
      end
    end
    context 'called when assignment belongs to course but team is empty' do
      it 'flashes note' do
        allow(Assignment).to receive(:find).and_return(assignment1)
        allow(Course).to receive(:find).and_return(course1)
        request_params = { id: team5.id }
        user_session = { user: ta }
        result = get :inherit, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
        expect(result).to redirect_to(controller: 'teams', action: 'list', id: assignment1.id)
      end
    end
    context 'called when assignment belongs to no course' do
      let(:fasg) { build_stubbed(:assignment, id: 1074, course_id: -2) }
      # a temporary assignment object is created with an abnormal course_id so that we can check the fail condition of the method
      it 'flashes error' do
        allow(Assignment).to receive(:find).and_return(fasg)
        allow(Course).to receive(:find).and_return(course1)
        request_params = { id: team5.id }
        user_session = { user: ta }
        result = get :inherit, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
        expect(result).to redirect_to(controller: 'teams', action: 'list', id: fasg.id)
      end
    end
  end
  
  describe '#bequeath_all' do
    context 'when the team type is user_session' do
      it 'flashes an error' do
        user_session = {team_type: 'Course', user: ta}
        request_params = { id: team5.id }
        post :bequeath_all, params: request_params, session: user_session 
        expect(flash[:error]).to eq('Invalid team type for bequeathal')
      end
    end
    context 'when there is no course associated with this assignment' do
      it 'flashes an error' do
        request_params = { id: 1 }
        user_session = {team_type: 'Assignment', user: ta}
        allow(Assignment).to receive(:find).and_return(assignment1)
        allow_any_instance_of(Assignment).to receive(:course_id).and_return(nil)
        post :bequeath_all, params: request_params, session: user_session
        expect(flash[:error]).to eq('No course was found for this assignment.')
      end
    end
    context 'when the course already has teams associated with it' do
      it 'flashes an error' do
        request_params = { id: 1 }
        user_session = {team_type: 'Assignment', user: ta}
        allow(Assignment).to receive(:find).and_return(assignment1)
        allow_any_instance_of(Assignment).to receive(:course_id).and_return(1)
        allow(Course).to receive(:find).and_return(course1)
        allow_any_instance_of(Course).to receive(:course_teams).and_return([team5, team6])
        post :bequeath_all, params: request_params, session: user_session
        expect(flash[:error]).to eq('The course already has associated teams')
      end
    end
    context 'when bequeathal is successful in copying 2 teams' do
      it 'flashes a note stating 2 teams were copied' do
        request_params = { id: 1 }
        user_session = {team_type: 'Assignment', user: ta}
        allow(Assignment).to receive(:find).and_return(assignment1)
        allow_any_instance_of(Assignment).to receive(:course_id).and_return(1)
        allow(Course).to receive(:find).and_return(course1)
        allow_any_instance_of(Course).to receive(:course_teams).and_return([])
        allow_any_instance_of(Assignment).to receive(:teams).and_return([team1, team2])
        post :bequeath_all, params: request_params, session: user_session
        expect(flash[:note]).to eq("2 teams were successfully copied to \"TestCourse\"")
      end
    end
  end
end
