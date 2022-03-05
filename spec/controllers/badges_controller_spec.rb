describe BadgesController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:admin) { build(:admin, id: 3) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:ta) { build(:teaching_assistant, id: 6) }
  #let(:badge)
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
    it 'creates a new badges form and renders badges#new page' do
      get :new
      expect(get: 'badges/new').to route_to('badges#new')
    end
  end

end
