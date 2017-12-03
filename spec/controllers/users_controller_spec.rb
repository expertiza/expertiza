describe UsersController do
  let(:admin) { build(:admin) }
  let(:superadmin) {build(:superadmin)}
  let(:instructor) { build(:instructor, id: 6) }
  let(:instructor2) { build(:instructor, id: 66) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:student) { build(:student) }

  describe '#action_allowed?' do
    context 'when params action is request_new' do
      it 'allows certain action' do
        controller.params = { action: 'request_new'}
        expect(controller.send(:action_allowed?)).to be true
      end
    end

    context 'when params action is request_user_create' do
      it 'allows certain action' do
        controller.params = { action: 'request_user_create'}
        expect(controller.send(:action_allowed?)).to be true
      end
    end

    context 'when params action is request_user_create' do
      it 'allows certain action' do
        controller.params = { action: 'request_user_create'}
        expect(controller.send(:action_allowed?)).to be true
      end
    end

    context 'when params action is review' do
      it 'allows certain action' do
        controller.params = { action: 'review'}
        stub_current_user(superadmin, superadmin.role.name, superadmin.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end
end


