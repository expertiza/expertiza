describe DutiesController do
  let(:assignment) { build(:assignment, id: 1, course_id: 1, instructor_id: 6, due_dates: [due_date], microtask: true, staggered_deadline: true) }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:instructor2) { build(:instructor, id: 66) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:duty) { build(:duty, id: 1, name: 'Role', max_members_for_duty: 2, assignment_id: 1) }
  let(:due_date) { build(:assignment_due_date, deadline_type_id: 1) }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(Duty).to receive(:find).with('1').and_return(duty)
  end

  describe '#action_allowed?' do
    context 'when params action is edit or update' do
      before(:each) do
        controller.params = { id: '1', action: 'edit' }
      end

      context 'when the role name of current user is super admin or admin' do
        it 'allows certain action' do
          stub_current_user(admin, admin.role.name, admin.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when current user is the instructor of current assignment' do
        it 'allows certain action' do
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when current user is the ta of the course which current assignment belongs to' do
        it 'allows certain action' do
          stub_current_user(ta, ta.role.name, ta.role)
          allow(TaMapping).to receive(:exists?).with(ta_id: 8, course_id: 1).and_return(true)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when current user is the instructor of the course which current assignment belongs to' do
        it 'allows certain action' do
          stub_current_user(instructor2, instructor2.role.name, instructor2.role)
          allow(Course).to receive(:find).with(1).and_return(double('Course', instructor_id: 66))
          expect(controller.send(:action_allowed?)).to be true
        end
      end
    end

    context 'when params action is not edit and update' do
      before(:each) do
        controller.params = { id: '1', action: 'new' }
      end

      context 'when the role current user is super admin/admin/instructor/ta' do
        it 'allows certain action except edit and update' do
          expect(controller.send(:action_allowed?)).to be true
        end
      end
    end
  end

  describe '#create' do
    context 'when new duty can be saved successfully' do
      it 'sets up a new duty and redirects to assignment#edit page' do
        allow(duty).to receive(:save).and_return('OK')
        request_params = {
          id: 1,
          duty: {
            name: 'Scrum Master',
            max_members_for_duty: 2,
            assignment_id: 1
          }
        }
        post :create, params: request_params
        expect(response).to redirect_to('/assignments/1/edit')
        expect(flash[:notice]).to match(/Role was successfully created.*/)
      end
    end

    context 'when new duty cannot be saved successfully' do
      it 'shows error message and redirects to duty#new page' do
        allow(duty).to receive(:errors)
        request_params = {
          id: 1,
          duty: {
            name: 'Scrum Master',
            max_members_for_duty: -1,
            assignment_id: 1
          }
        }
        post :create, params: request_params
        expect(flash[:error]).to eq('Value for max members for role is invalid')
        expect(response).to redirect_to('/duties/new?id=1')
      end
    end
  end

  describe '#update' do
    context 'when duty can be found' do
      it 'updates current duty and redirects to assignment#edit page' do
        allow(Duty).to receive(:find).with('1').and_return(build(:duty, id: 1))
        request_params = {
          id: 1,
          assignment_id: 1,
          duty: {
            name: 'Scrum Master',
            max_members_for_duty: 5,
            assignment_id: 1
          }
        }
        post :update, params: request_params
        expect(response).to redirect_to('/assignments/1/edit')
        expect(flash[:notice]).to match(/Role was successfully updated.*/)
      end
    end

    context 'when new duty cannot be updated successfully' do
      it 'shows error message and redirects to duty#new page' do
        allow(duty).to receive(:errors)
        request_params = {
          id: 1,
          duty: {
            name: 'SM',
            max_members_for_duty: 1,
            assignment_id: 1
          }
        }
        post :create, params: request_params
        expect(flash[:error]).to eq('Role name is too short (minimum is 3 characters)')
        expect(response).to redirect_to('/duties/new?id=1')
      end
    end
  end

  describe '#delete' do
    context 'when duty can be found' do
      it 'redirects to assignment#edit page' do
        request_params = { id: 1, assignment_id: 1 }
        post :delete, params: request_params
        expect(response).to redirect_to('/assignments/1/edit')
        expect(flash[:notice]).to match(/Role was successfully deleted.*/)
      end
    end
  end
end
