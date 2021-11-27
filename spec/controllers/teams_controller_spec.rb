require './spec/support/teams_shared.rb'

describe TeamsController do
  include_context 'object initializations'
  let(:topic1) { build_stubbed(:topic, id: 11, assignment_id: 1) }
  let(:signedupteam) { build_stubbed(:signed_up_team, id: 1002) }#, topic: topic1, team_id: 205) }
  let(:teamusers) { build_stubbed(:team_user, id: 1004) }#, team: team5, user: student1) }

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

        para = {id: assignment1.id, team_size: 2}
        session = {user: instructor, team_type: "Assignment"}
        result = get :create_teams, para, session
        expect(result.status).to eq 302
        expect(result).to redirect_to(:action => 'list', :id => assignment1.id)
      end
    end
  end

  describe 'list method' do
    before(:each) {
      allow(Assignment).to receive(:find_by).and_return(assignment1)
    }
    context 'when type is Assignment' do
      it 'lists the teams' do
        params = {id: assignment1.id, type: 'Assignment'}
        session = {user: instructor}
        result = get :list, params, session
        expect(result.status).to eq 200
        expect(controller.instance_variable_get(:@assignment)).to eq assignment1
      end
    end
    context 'when type is Course' do
      it 'lists the teams' do
        params = {id: course1.id, type: 'Course'}
        session = {user: instructor}
        result = get :list, params, session
        expect(result.status).to eq 200
        expect(controller.instance_variable_get(:@assignment)).to eq nil
      end
    end
    context 'when type is wrong' do
      it 'throws error' do
        params = {id: 52, type: 'Subject'}
        session = {user: instructor}
        result = get :list, params, session
        expect(result.status).to eq 200
        expect(controller.instance_variable_get(:@assignment)).to eq nil
      end
    end
  end

  describe 'new method' do
    it 'creates a new team successfully' do
      allow(Object).to receive_message_chain(:const_get, :find).with(any_args).and_return(assignment1)
      para = {id: assignment1.id}
      session = {user: ta, team_type: 'Assignment'}
      result = get :new, para, session
      expect(result.status).to eq 200
      expect(controller.instance_variable_get(:@parent)).to eq assignment1
    end
  end

  describe 'create method' do
    context 'called with right conditions' do
      it 'executes successfully' do
        bypass_rescue
        allow(Object).to receive_message_chain(:const_get, :find).and_return(assignment1)
        allow(Team).to receive(:check_for_existing).and_return(nil)#.with(name: 'SomeName', team_type: 'Assignment')
        allow(Object).to receive_message_chain(:const_get, :create).and_return(team1)
        allow(TeamNode).to receive(:create).and_return(nil)
        #allow(Object).to receive_message_chain(:const_get, :where).and_return(nil)
        para = {id: 1}
        session = {user: ta, team_type: 'Assignment'}
        #result = get :create, para, session
        #expect(result.status).to eq 302
        #expect(result).to redirect_to(:action => 'list', :id => assignment1.id)
      end
    end
    context 'called with existing team name' do
      it 'fails' do
        bypass_rescue
        allow(Object).to receive_message_chain(:const_get, :find).and_raise(StandardError.new("error"))
        #allow(Object).to receive_message_chain(:const_get, :find).and_return(assignment1)
        #allow(Team).to receive(:check_for_existing).and_raise(StandardError.new("error"))
        para = {id: 1}
        session = {user: ta}
        #result = get :create, para, session
        #expect(result.status).to eq 302
        #expect(result).to redirect_to(:action => 'new', :id => assignment1.id)
      end
    end
  end

  describe 'update method' do
    it 'updates the team name' do
      allow(Team).to receive(:find).and_return(team1)
      allow(Object).to receive_message_chain(:const_get, :find).with(any_args).and_return(team1.parent_id)
      #allow(Team).to receive(:check_for_existing).and_do_nothing#not_raise(TeamExistsError)

      para = {response_id: 1, team_id: 1}
      session = {user: ta}
      #result = get :update, para, session
      #expect(Rails.logger).to receive(:error)
      #expect(result.status).to eq 404
    end
  end

  describe 'edit method' do
    it 'passes the test' do
      allow(Team).to receive(:find).and_return(team1)
      para = {id: team1.id}
      session = {user: ta}
      result = get :edit, para, session
      expect(result.status).to eq 200
      expect(controller.instance_variable_get(:@team)).to eq team1
    end
  end

  describe 'delete method' do
    it 'passes the test' do
      request.env['HTTP_REFERER'] = root_url
      allow(Team).to receive(:find_by).with(any_args).and_return(team5)
      #allow(Object).to receive(:const_get).and_return(course1)
      allow(Object).to receive_message_chain(:const_get, :find).and_return(course1)
      allow(SignedUpTeam).to receive(:where).and_return(signedupteam)#.with(any_args).and_return(signedupteam)
      #allow(TeamsUser).to receive(:where).and_return(nil)#.with(any_args).and_return(teamusers)
      #allow(@signUps).to receive_message_chain(:first, :is_waitlisted).with(any_args).and_return(0)
      allow(team5).to receive(:destroy).and_return(nil)

      para = {id: 5}
      session = {user: instructor, team_type: 'CourseTeam'}
      #result = get :delete, para, session
      #expect(controller.instance_variable_get(:@signedupteam)).to eq nil
      #expect(controller.instance_variable_get(:@team)).to eq nil
      #expect(result.status).to eq 302
      #expect(result).to redirect_to :back
    end
  end

  describe 'inherit method' do
    context 'when assignment belongs to course and team is not empty' do
      it 'it runs successfully' do
        allow(Assignment).to receive(:find).and_return(assignment1)
        allow(Course).to receive(:find).and_return(course1)
        allow(course1).to receive(:get_teams).and_return([team5, team6])
        para = {id: team5.id}
        session = {user: ta}
        result = get :inherit, para, session
        expect(result.status).to eq 302
        expect(result).to redirect_to(:controller => 'teams', :action => 'list', :id => assignment1.id)
      end
    end
    context 'when assignment belongs to course but team is empty' do
      it 'it flashes note' do
        allow(Assignment).to receive(:find).and_return(assignment1)
        allow(Course).to receive(:find).and_return(course1)
        para = {id: team5.id}
        session = {user: ta}
        result = get :inherit, para, session
        expect(result.status).to eq 302
        expect(result).to redirect_to(:controller => 'teams', :action => 'list', :id => assignment1.id)
      end
    end
    context 'when assignment belongs to no course' do
      let(:fasg) { build_stubbed(:assignment, id: 1074, course_id: -2) }
      it 'it flashes error' do
        allow(Assignment).to receive(:find).and_return(fasg)
        allow(Course).to receive(:find).and_return(course1)
        para = {id: team5.id}
        session = {user: ta}
        result = get :inherit, para, session
        expect(result.status).to eq 302
        expect(result).to redirect_to(:controller => 'teams', :action => 'list', :id => fasg.id)
      end
    end
  end

  describe 'bequeath method' do
    context 'when assignment has a course' do
      it 'it runs successfully' do
        allow(AssignmentTeam).to receive(:find).and_return(team2)
        allow(Assignment).to receive(:find).and_return(assignment1)
        allow(Course).to receive(:find).and_return(course1)
        para = {id: team2.id}
        session = {user: ta}
        result = get :bequeath, para, session
        expect(result.status).to eq 302
        expect(result).to redirect_to(:controller => 'teams', :action => 'list', :id => assignment1.id)
      end
    end
    context 'when assignment does not have a course' do
      let(:fasg) { build_stubbed(:assignment, id: 1074, course_id: -2) }
      it 'it fails' do
        allow(AssignmentTeam).to receive(:find).and_return(team2)
        allow(Assignment).to receive(:find).and_return(fasg)
        para = {id: team2.id}
        session = {user: ta}
        result = get :bequeath, para, session
        expect(result.status).to eq 302
        expect(result).to redirect_to(:controller => 'teams', :action => 'list', :id => fasg.id)
      end
    end
  end

end
