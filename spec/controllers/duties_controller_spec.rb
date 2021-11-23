describe DutiesController do
  let(:assignment) { build(:assignment, id: 1, instructor_id: 6, due_dates: [due_date], microtask: true, staggered_deadline: true) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:duty) { build(:duty, id: 1, duty_name: "Role", max_members_for_duty: 2, assignment_id: 1) }
  let(:due_date) { build(:assignment_due_date, deadline_type_id: 1) }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(Duty).to receive(:find).with('1').and_return(duty)
  end

  describe '#create' do
      context 'when new duty can be saved successfully' do
        it 'sets up a new duty and redirects to assignment#edit page' do
          allow(duty).to receive(:save).and_return('OK')
          params = {
              id: 2,
              duty: {
                  duty_name: 'Scrum Master',
                  max_members_for_duty: 2,
                  assignment_id: 1
              }
          }
          post :create, params
          expect(response).to redirect_to('/assignments/1/edit')
        end
      end
    end

  describe '#update' do

    context 'when duty can be found' do
      it 'updates current duty and redirects to assignment#edit page' do
        allow(Duty).to receive(:find).with('1').and_return(build(:duty, id: 1))
          params = {
            id: 1,
            assignment_id: 1,
            duty: {
                duty_name: 'Scrum Master',
                max_members_for_duty: 5,
                assignment_id: 1
            }
        }
        post :update, params
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end

  end

  describe '#destroy' do
    context 'when duty can be found' do
      it 'redirects to assignment#edit page' do
        params = {id: 1, assignment_id: 1}
        post :destroy, params
        expect(response).to redirect_to('/assignments/1/edit')
      end
      end
  end
end

