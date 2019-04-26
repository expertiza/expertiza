describe ImportFileController do
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 3) }
  let(:instructor2) { build(:instructor, id: 33) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:student) { build(:student) }

  describe '#action_allowed?' do
    context 'when params action is edit or update' do
      before(:each) do
        controller.params = {id: '1', action: 'edit'}
      end

      context 'when the role name of current user is super admin or admin' do
        it 'allows certain action' do
          stub_current_user(admin, admin.role.name, admin.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role name of current user is ta' do
        it 'allows certain action' do
          stub_current_user(ta, ta.role.name, ta.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role name of current user is instructor' do
        it 'allows certain action' do
          stub_current_user(instructor, instructor.role.name, instructor.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role name of current user is student' do
        it 'does not allow certain action' do
          stub_current_user(student, student.role.name, student.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end
    end
  end

  describe '#start' do
    it 'initializes variables to passed parameters' do
      params = {id: 1, model: 'ReviewResponseMap', title: 'Reviewer Mappings'}
      session = {user: instructor}
      get :start, params, session
      expect(controller.instance_variable_get(:@id)).to be 1
      expect(controller.instance_variable_get(:@model)).to be 'ReviewResponseMap'
      expect(controller.instance_variable_get(:@title)).to be 'Reviewer Mappings'
    end
  end

  describe '#show' do
    it 'expects show to render' do
      params = {id: 1,
                model: 'User',
                title: 'User',
                delim_type: 'comma',
                has_header: 'false',
                file: 'user, First Last, email@site.edu'
                }
      session = {user: instructor}
      get :show, params, session
      expect(response).to render_template(:show)
    end
  end
end