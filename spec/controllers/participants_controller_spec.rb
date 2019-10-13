describe ParticipantsController do
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student) }
  let(:course_participant) { build(:course_participant) }
  let(:participant) { build(:participant) }
  let(:assignment_node) { build(:assignment_node) }
  let(:assignment) { build(:assignment) }
  describe '#action_allowed?' do
    context 'when current user is student' do
      it 'allows update_duties action' do
        controller.params = {action: 'update_duties'}
        user = student
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'allows change_handle action' do
        controller.params = {action: 'change_handle'}
        user = student
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'disallows all other actions' do
        user = student
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be false
      end
    end
    context 'when current user is instructor and above' do
      it 'allows all actions' do
        user = instructor
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end

  describe '#destroy' do
    it 'deletes the participant and redirects to #list page' do
      allow(Participant).to receive(:find).with('1').and_return(course_participant)
      allow(course_participant).to receive(:destroy).and_return(true)
      params = {id: 1}
      session = {user: instructor}
      post :destroy, params, session
      expect(response).to redirect_to('/participants/list?id=1&model=Course')
    end
  end

  describe '#delete_assignment_participant' do
    it 'deletes the assignment_participant and redirects to #review_mapping/list_mappings page' do
      allow(Participant).to receive(:find).with('1').and_return(participant)
      allow(participant).to receive(:destroy).and_return(true)
      params = {id: 1}
      session = {user: instructor}
      get :delete_assignment_participant, params, session
      expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
    end
  end

  describe '#update_duties' do
    it 'updates the duties for the participant' do
      allow(Participant).to receive(:find).with('1').and_return(participant)
      params = {student_id: 1}
      session = {user: instructor}
      get :update_duties, params, session
      expect(response).to redirect_to('/student_teams/view?student_id=1')
    end
  end

  describe '#update_authorizations' do
    it 'updates the authorizations for the participant' do
      allow(Participant).to receive(:find).with('1').and_return(participant)
      params = {authorization: 'participant', id: 1}
      session = {user: instructor}
      get :update_authorizations, params, session
      expect(response).to redirect_to('/participants/list?id=1&model=Assignment')
    end
  end

  describe '#list' do
    it 'lists the participants' do
      allow(AssignmentNode).to receive(:find_by).with(node_object_id: '1').and_return(assignment_node)
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      params = {model: 'Assignment', authorization: 'participant', id: 1}
      session = {user: instructor}
      get :list, params, session
      expect(controller.instance_variable_get(:@participants)).to be_empty
    end
  end

  describe '#add' do
    it 'adds a participant' do
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      allow(User).to receive(:find_by).with(name: student.name).and_return(student)
      params = {model: 'Assignment', authorization: 'participant', id: 1, user: {name: student.name}}
      session = {user: instructor}
      xhr :get, :add, params, session
      expect(response).to render_template('add.js.erb')
    end
    it 'does not add a participant for a non-existing user' do
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      params = {model: 'Assignment', authorization: 'participant', id: 1, user: {name: 'Aaa'}}
      session = {user: instructor}
      xhr :get, :add, params, session
      expect(flash[:error]).to eq 'The user <b>Aaa</b> does not exist or has already been added.'
      expect(response).to render_template('add.js.erb')
    end
  end

  describe '#inherit' do
    it 'inherits the participant list' do
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      params = {id: 1}
      session = {user: instructor}
      get :inherit, params, session
      expect(flash[:note]).to eq 'No participants were found to inherit this assignment.'
      expect(response).to redirect_to('/participants/list?model=Assignment')
    end
  end

  describe '#bequeath_all' do
    it 'bequeaths the participant list' do
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      params = {id: 1}
      session = {user: instructor}
      get :bequeath_all, params, session
      expect(flash[:note]).to eq 'All assignment participants are already part of the course'
      expect(response).to redirect_to('/participants/list?model=Assignment')
    end
  end
end
