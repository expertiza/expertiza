describe StudentQuizzesController do
  let(:assignment) { build(:assignment, id: 1, instructor_id: 6, due_dates: [due_date], microtask: true, staggered_deadline: true, directory_path: 'assignment') }
  let(:instructor) { build(:instructor) }
  let(:student) { build(:student) }
  let(:participant) { build(:participant, id: 1, user_id: 6, assignment: assignment) }
  let(:topic) { build(:topic, id: 1) }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(Participant).to receive(:find_by).with(id: '1').and_return(participant)
    allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
  end

  describe '#new' do
    it 'builds a new student quiz form' do
      request_params = { id: 1 }
      get :new, params: request_params
      expect(controller.instance_variable_get(:@quiz_mappings).assignment).to eq(assignment)
      expect(response).to render_template(:new)
    end
  end
end

