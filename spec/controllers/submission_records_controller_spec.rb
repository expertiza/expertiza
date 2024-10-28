describe SubmissionRecordsController do
  # initialize objects using factories.rb required for stubbing in test cases
  let(:super_admin) { build(:superadmin, id: 1) }
  let(:instructor1) { build(:instructor, id: 10, username: 'Instructor1') }
  let(:instructor2) { build(:instructor, id: 11, username: 'Instructor2') }
  let(:ta) { build(:teaching_assistant, id: 8) }

  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 2, instructor_id: 10) }
  let(:student) { build(:student, id: 1, username: 'name', name: 'no one', email: 'expertiza@mailinator.com') }
  let(:team) { build(:assignment_team, id: 1, name: 'team no name', assignment: assignment, users: [student], parent_id: 1) }

  let(:submission_record) { build(:submission_record, id: 1, team_id: 27158, assignment_id: 1) }

  # Redirects to a page when index method called
  describe '#index' do
    it 'call index method' do
      params = { team_id: 27158 }
      allow(AssignmentTeam).to receive(:find).with(any_args).and_return(team)
      allow(Assignment).to receive(:find).with(any_args).and_return(assignment)
      allow(SubmissionRecord).to receive(:where).with(any_args).and_return([submission_record])

      result = get :index, params: params
      expect(result.status).to eq 302

      controller.send(:index)
      expect(controller.instance_variable_get(:@submission_records)).to eq [submission_record]
      end
  end

  # To allow the functionality only if the accessing user is a super admin
  # or instructor who instructs current assignment or TA of the course which current assignment belongs
  describe '#action_allowed?' do
    # define default behaviors for each testcase
    before(:each) do
      controller.params = { team_id: '27158' }
      allow(AssignmentTeam).to receive(:find).with('27158').and_return(team)
      allow(Assignment).to receive(:find).with(team.parent_id).and_return(assignment)
    end

    context 'when superadmin is logged in' do
      it 'allows certain action' do
        stub_current_user(super_admin, super_admin.role.name, super_admin.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end

    context 'when current user is instructor who instructs the current assignment' do
      it 'allows certain action' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end

    context 'when current user is instructor but NOT the instructor who instructs the current assignment' do
      it 'refuses certain action' do
        stub_current_user(instructor2, instructor2.role.name, instructor2.role)
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end

    context 'when current user is TA of the course which current assignment belongs to' do
      it 'allows certain action' do
        stub_current_user(ta, ta.role.name, ta.role)
        allow(TaMapping).to receive(:exists?).with(ta_id: 8, course_id: 1).and_return(true)
        expect(controller.send(:action_allowed?)).to be true
      end
    end

    context 'when current user is a TA but NOT the TA of course which current assignment belongs to' do
      it 'refuses certain action' do
        stub_current_user(ta, ta.role.name, ta.role)
        allow(TaMapping).to receive(:exists?).with(ta_id: 8, course_id: 1).and_return(false )
        expect(controller.send(:action_allowed?)).to be false
      end
    end

    context 'when current user is a student' do
      it 'refuses certain action' do
        stub_current_user(student, student.role.name, student.role)
        expect(controller.send(:action_allowed?)).to be false
      end
    end
  end
end