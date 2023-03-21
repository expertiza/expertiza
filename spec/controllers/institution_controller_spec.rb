require 'rails_helper'
describe InstitutionController do
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:instructor2) { build(:instructor, id: 66) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:student) { build(:student) }

  # create fake data
  let(:institution) do
    build(:institution, id: 1, name: 'test institution')
  end

  let(:course) do
    build(:course, instructor_id: 6, institutions_id: 1, name: 'abc')
  end

  # set default testing user
  before(:each) do
    allow(Institution).to receive(:find).with('1').and_return(institution)
    allow(Course).to receive(:where).with(institution_id: '1').and_return(course)
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end
  describe '#action_allowed?' do
    context 'when params action is edit or update' do
      before(:each) do
        controller.params = { id: '1', action: 'edit' }
      end

      context 'when the role name of current user is super admin or admin' do
        it 'allows certain action' do
          stub_current_user(admin, admin.role.name, admin.role)
          controller.send(:action_allowed?).should be true
        end
      end

      context 'when current user is the instructor' do
        it 'allows certain action' do
          stub_current_user(instructor, instructor.role.name, instructor.role)
          controller.send(:action_allowed?).should be true
        end
      end

      context 'when current user is the TAs or the students' do
        it 'deny certain action if current user is the TA' do
          stub_current_user(ta, ta.role.name, ta.role)
          controller.send(:action_allowed?).should be false
        end
        it 'deny certain action if current user is the student' do
          stub_current_user(student, student.role.name, student.role)
          controller.send(:action_allowed?).should be false
        end
      end
    end
  end

  describe '#new' do
    it 'creates a new Institution object and renders institution#new page' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe '#create' do
    context 'when institution is saved successfully' do
      it 'redirects to institution#list page' do
        allow(institution).to receive(:name).and_return('test institution')
        request_params = {
          institution: {
            name: 'test institution'
          }
        }
        post :create, params: request_params
        expect(response).to redirect_to('/institution/list')
      end
    end

    context 'when institution is not saved successfully' do
      it 'renders institution#new page' do
        allow(institution).to receive(:save).and_return(false)
        request_params = {
          institution: {
            name: ''
          }
        }
        post :create, params: request_params
        expect(flash.now[:error]).to eq('The creation of the institution failed.')
        expect(response).to render_template(:new)
      end
    end
  end
  describe '#edit' do
    it 'renders institution#edit' do
      request_params = {
        id: 1
      }
      get :edit, params: request_params
      expect(response).to render_template(:edit)
    end
  end

  describe '#update' do
    context 'when institution is updated successfully' do
      it 'renders institution#list' do
        request_params = {
          id: 1,
          institution: {
            name: 'test institution'
          }
        }
        put :update, params: request_params
        expect(response).to redirect_to('/institution/list')
      end
    end
    context 'when institution is not updated successfully' do
      it 'renders institution#edit' do
        stub_current_user(instructor, instructor.role.name, instructor.role)
        request_params = {
          id: 1,
          institution: {
            name: 'test institution'
          }
        }
        allow(institution).to receive(:update_attribute).with(any_args).and_return(false)
        put :update, params: request_params
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#index' do
    context 'when institution query all institution' do
      it 'renders institution#list' do
        get :index
        expect(response).to render_template(:list)
      end
    end
  end

  describe '#show' do
    context 'when try to show a institution' do
      it 'renders institution#show when find the target institution' do
        request_params = {
          id: 1
        }
        get :show, params: request_params
        expect(response).to render_template(:show)
      end
    end
  end

  describe '#delete' do
    context 'when try to delete a institution' do
      it 'renders institution#list when delete successfully' do
        request_params = {
          id: 1
        }
        post :delete, params: request_params, session: session
        expect(response).to redirect_to('/institution/list')
      end
    end
  end
end
