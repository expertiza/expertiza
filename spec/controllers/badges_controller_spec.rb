describe BadgesController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:admin) { build(:admin, id: 3) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:ta) { build(:teaching_assistant, id: 6) }
  let(:badge) {build(:badge, id:1, name: 'test', description: 'test desc', image_name: 'good-reviewer.png')}
  #let(:student2) {build(:student, id: )}
  describe '#action_allowed?' do
    context 'when the role of current user is Super-Admin' do
      it 'allows certain action' do
        stub_current_user(super_admin, super_admin.role.name, super_admin.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'when the role of current user is Instructor' do
      it 'allows certain action' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'when the role of current user is Student' do
      it 'refuses certain action' do
        stub_current_user(student1, student1.role.name, student1.role)
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
    context 'when the role of current user is Teaching Assisstant' do
      it 'allows certain action' do
        stub_current_user(ta, ta.role.name, ta.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'when the role of current user is Admin' do
      it 'allows certain action' do
        stub_current_user(admin, admin.role.name, admin.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
  end
  
  describe '#new' do
    context 'when user wants to create a new form' do
      it 'renders badges#new page' do
        get :new
        expect(get: 'badges/new').to route_to('badges#new')
      end
    end
    context 'when user tries to create a new badge' do
      it 'renders the create new form' do
        allow(Badge).to receive(:new).and_return(badge)
        #params = { participant_id: participant.id, team_id: -2 }
        params = {}
        session = { user: instructor1 }
        get :new, params, session
        expect(response).to render_template('new')
      end
    end

  end
end
