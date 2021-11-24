describe TeamsUsersController do
  let(:assignment) do
    build(:assignment, id: 1, name: 'test assignment', instructor_id: 6, staggered_deadline: true, directory_path: 'same path',
          participants: [build(:participant)], teams: [build(:assignment_team)], course_id: 1)
  end
  let(:assignment_form) { double('AssignmentForm', assignment: assignment) }
  let(:student) { build(:student) }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    stub_current_user(student, student.role.name, student.role)
  end

describe '#action_allowed?' do
  context 'when params action is update duties' do
    before(:each) do
      controller.params = {id: '1', action: 'update_duties'}
    end

    context 'when the role current user is student' do
      it 'allows certain action' do
        stub_current_user(student, student.role.name, student.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end
  end
end