describe ParticipantsController do
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student) }
  let(:student1) { build_stubbed(:student, id: 1, username: 'student') }
  let(:course_participant) { build(:course_participant) }
  let(:participant) { build(:participant) }
  let(:assignment_node) { build(:assignment_node) }
  let(:assignment) { build(:assignment) }
  let(:team) { build(:team) }
  let(:topic) { build(:topic) }
  let(:signed_up_team) { build(:signed_up_team) }
  describe '#action_allowed?' do
    context 'when current user is student' do
      it 'allows update_duties action' do
        controller.params = { action: 'update_duties' }
        user = student
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'allows change_handle action' do
        controller.params = { action: 'change_handle' }
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
      request_params = { id: 1 }
      user_session = { user: instructor }
      post :destroy, params: request_params, session: user_session
      expect(response).to redirect_to('/participants/list?id=1&model=Course')
    end
  end

  describe '#delete' do
    it 'deletes the assignment_participant and redirects to #review_mapping/list_mappings page' do
      allow(Participant).to receive(:find).with('1').and_return(participant)
      allow(participant).to receive(:destroy).and_return(true)
      request_params = { id: 1 }
      user_session = { user: instructor }
      get :delete, params: request_params, session: user_session
      expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
    end
  end

  describe '#update_authorizations' do
    it 'updates the authorizations for the participant' do
      allow(Participant).to receive(:find).with('1').and_return(participant)
      request_params = { authorization: 'participant', id: 1 }
      user_session = { user: instructor }
      get :update_authorizations, params: request_params, session: user_session
      expect(response).to redirect_to('/participants/list?id=1&model=Assignment')
    end
  end

  describe '#validate_authorizations' do
    # Test case for successful update of participant to reviewer, expects the success flash message after role is updated.
    it 'updates the authorizations for the participant to make them reviewer' do
      allow(Participant).to receive(:find).with('1').and_return(participant)
      request_params = { authorization: 'reviewer', id: 1 }
      user_session = { user: instructor }
      get :update_authorizations, params: request_params, session: user_session
      expect(flash[:success]).to eq 'The role of the selected participants has been successfully updated.'
      expect(participant.can_review).to eq(true)
      expect(participant.can_submit).to eq(false)
      expect(participant.can_take_quiz).to eq(false)
    end

    # Test for case where we expect to encounter an error in update_attributes method
    it ' throws an exception while validating authorizations' do
      allow(Participant).to receive(:find).with('1').and_return(participant)
      allow(participant).to receive(:update_attributes).and_raise(StandardError)
      request_params = { authorization: 'reviewer', id: 1 }
      user_session = { user: instructor }
      get :update_authorizations, params: request_params, session: user_session
      expect(flash[:error]).to eq 'The update action failed.'
    end
  end

  describe '#list' do
    it 'lists the participants' do
      allow(AssignmentNode).to receive(:find_by).with(node_object_id: '1').and_return(assignment_node)
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      request_params = { model: 'Assignment', authorization: 'participant', id: 1 }
      user_session = { user: instructor }
      get :list, params: request_params, session: user_session
      expect(controller.instance_variable_get(:@participants)).to be_empty
    end
  end

  describe '#add' do
    it 'adds a participant' do
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      allow(User).to receive(:find_by).with(username: student.username).and_return(student)
      request_params = { model: 'Assignment', authorization: 'participant', id: 1, user: { username: student.username } }
      user_session = { user: instructor }
      get :add, params: request_params, session: user_session, xhr: true
      expect(response).to render_template('add.js.erb')
    end
    it 'does not add a participant for a non-existing user' do
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      request_params = { model: 'Assignment', authorization: 'participant', id: 1, user: { username: 'Aaa' } }
      user_session = { user: instructor }
      get :add, params: request_params, session: user_session, xhr: true
      expect(flash[:error]).to eq 'The user <b>Aaa</b> does not exist or has already been added.'
      expect(response).to render_template('add.js.erb')
    end
  end

  describe '#update_authorizations' do
    it 'updates the authorizations for the participant' do
      allow(Participant).to receive(:find).with('1').and_return(participant)
      params = { authorization: 'participant', id: 1 }
      session = { user: instructor }
      get :update_authorizations, params: params, session: session
      expect(response).to redirect_to('/participants/list?id=1&model=Assignment')
    end
    it 'updates the authorizations fails' do
      allow(Participant).to receive(:find).with('1').and_return(participant)
      params = { authorization: 'participant', id: 1 }
      session = { user: student }
      get :update_authorizations, params: params, session: session
      expect(flash[:error]).to eq 'A student is not allowed to update_authorizations this/these participants'
      expect(response).to redirect_to('/')
    end
  end

  describe '#destroy' do
    it 'deletes the participant and redirects to #list page' do
      allow(Participant).to receive(:find).with('1').and_return(course_participant)
      allow(course_participant).to receive(:destroy).and_return(true)
      params = { id: 1 }
      session = { user: instructor }
      post :destroy, params: params, session: session
      expect(response).to redirect_to('/participants/list?id=1&model=Course')
    end
  end

  describe '#inherit' do
    it 'inherits the participant list' do
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      request_params = { id: 1 }
      user_session = { user: instructor }
      get :inherit, params: request_params, session: user_session
      expect(flash[:note]).to eq 'No participants were found to inherit this assignment.'
      expect(response).to redirect_to('/participants/list?model=Assignment')
    end
  end

  describe '#bequeath_all' do
    it 'bequeaths the participant list' do
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      request_params = { id: 1 }
      user_session = { user: instructor }
      get :bequeath_all, params: request_params, session: user_session
      expect(flash[:note]).to eq 'All assignment participants are already part of the course'
      expect(response).to redirect_to('/participants/list?model=Assignment')
    end
  end

  describe '#change_handle' do
    it 'changes the handle of the participant' do
      allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
      params = { id: 1, participant: { handle: 'new_handle' } }
      session = { user: student1 }
      get :change_handle, params: params, session: session
      expect(response).to have_http_status(200)
    end
  end

  describe '#delete' do
    it 'deletes the assignment_participant and redirects to #review_mapping/list_mappings page' do
      allow(Participant).to receive(:find).with('1').and_return(participant)
      allow(participant).to receive(:destroy).and_return(true)
      params = { id: 1 }
      session = { user: instructor }
      get :delete, params: params, session: session
      expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
    end
  end

  describe '#view_copyright_grants' do
    it 'renders the copyright_grants template' do
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      params = { id: 1 }
      session = { user: instructor }
      get :view_copyright_grants, params: params, session: session
      expect(response).to render_template('view_copyright_grants')
    end
  end

  describe '#validate_authorizations' do
    # Test case for successful update of participant to reviewer, expects the success flash message after role is updated.
    it 'updates the authorizations for the participant to make them reviewer' do
      allow(Participant).to receive(:find).with('1').and_return(participant)
      params = { authorization: 'reviewer', id: 1 }
      session = { user: instructor }
      get :update_authorizations, params: params, session: session
      expect(flash[:success]).to eq 'The role of the selected participants has been successfully updated.'
      expect(participant.can_review).to eq(true)
      expect(participant.can_submit).to eq(false)
      expect(participant.can_take_quiz).to eq(false)
    end

    # Test for case where we expect to encounter an error in update_attributes method
    it ' throws an exception while validating authorizations' do
      allow(Participant).to receive(:find).with('1').and_return(participant)
      allow(participant).to receive(:update_attributes).and_raise(StandardError)
      params = { authorization: 'reviewer', id: 1 }
      session = { user: instructor }
      get :update_authorizations, params: params, session: session
      expect(flash[:error]).to eq 'The update action failed.'
    end
  end

  describe '#get_user_info' do
    it 'gives the user information from the the team user' do
      allow(assignment).to receive(:participants).and_return([participant])
      allow(participant).to receive(:permission_granted?).and_return(true)
      allow(participant).to receive(:user).and_return(student)
      allow(student).to receive(:username).and_return('name')
      allow(student).to receive(:fullname).and_return('fullname')
      pc = ParticipantsController.new
      expect(pc.send(:get_user_info, student, assignment)).to eq(username: 'name', fullname: 'fullname', pub_rights: 'Granted', verified: false)
    end
  end

  describe '#get_signup_topics_for_assignment' do
    it 'gives the signup topics for assignment' do
      pc = ParticipantsController.new
      expect(pc.send(:get_signup_topics_for_assignment, topic.assignment.id, topic, signed_up_team.team_id)).to eq(true)
    end
  end

end
