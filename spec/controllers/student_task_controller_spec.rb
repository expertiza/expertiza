describe StudentTaskController do
  let(:due_date) { build(:assignment_due_date, deadline_type_id: 1) }
  let(:due_date2) { build(:assignment_due_date, deadline_type_id: 2) }
  let(:assignment_avail) { build(:assignment, id: 1, instructor_id: 6, due_dates: [due_date], microtask: true, staggered_deadline: true, availability_flag: true) }
  let(:assignment_not_avail) { build(:assignment, id: 1, instructor_id: 6, due_dates: [due_date], microtask: true, staggered_deadline: true, availability_flag: false) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student, id: 8) }
  let(:participant_avail) { build(:participant, id: 1, user_id: 8, assignment: assignment_avail) }
  let(:participant_not_avail) { build(:participant, id: 1, user_id: 8, assignment: assignment_not_avail) }

  let(:student_task_current) { StudentTask.new(participant: participant_avail,
                                               assignment: participant_avail.assignment,
                                               topic: participant_avail.topic,
                                               current_stage: participant_avail.current_stage,
                                               stage_deadline: (Time.parse(participant_avail.stage_deadline) rescue Time.now + 1.year)) }

  let(:student_task_past) { StudentTask.new(participant: participant_avail,
                                            assignment: participant_avail.assignment,
                                            topic: participant_avail.topic,
                                            current_stage: participant_avail.current_stage,
                                            stage_deadline: (Time.parse(participant_avail.stage_deadline) rescue Time.now - 1.year)) }

  let(:student_task_not_avail) { StudentTask.new(participant: participant_not_avail,
                                            assignment: participant_not_avail.assignment,
                                            topic: participant_not_avail.topic,
                                            current_stage: participant_not_avail.current_stage,
                                            stage_deadline: (Time.parse(participant_not_avail.stage_deadline) rescue Time.now + 1.year)) }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment_avail)
    allow(Assignment).to receive(:find).with(1).and_return(assignment_avail)
    stub_current_user(student, student.role.name, student.role)
    allow(Participant).to receive(:find_by).with(id: '1').and_return(participant_avail)
    allow(Participant).to receive(:find_by).with(parent_id: 1, user_id: 8).and_return(participant_avail)
    allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant_avail)
    allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant_avail)


  end

  describe '#list' do

    context 'when there are available assignments due in the future' do
      it 'should populate all_tasks, student_tasks, and current_student_tasks instance variables with tasks' do
        session = {user: student}
        allow(StudentTask).to receive(:from_user).with(student).and_return([student_task_current])
        get :list, session
        expect(controller.instance_variable_get(:@all_tasks)).not_to be_empty
        expect(controller.instance_variable_get(:@student_tasks)).not_to be_empty
        expect(controller.instance_variable_get(:@current_student_tasks)).not_to be_empty
        expect(controller.instance_variable_get(:@past_student_tasks)).to be_empty
      end
    end

    context 'when there are available assignments due in the future' do
      it 'should populate past_student_tasks instance variable with tasks' do
        session = {user: student}
        allow(StudentTask).to receive(:from_user).with(student).and_return([student_task_past])
        get :list, session
        expect(controller.instance_variable_get(:@all_tasks)).not_to be_empty
        expect(controller.instance_variable_get(:@student_tasks)).not_to be_empty
        expect(controller.instance_variable_get(:@current_student_tasks)).to be_empty
        expect(controller.instance_variable_get(:@past_student_tasks)).not_to be_empty
      end
    end

    context 'when there are assignments but they are not available' do
      it 'should not populate the student_tasks instance variable with tasks' do
        session = {user: student}
        allow(StudentTask).to receive(:from_user).with(student).and_return([student_task_not_avail])
        get :list, session
        expect(controller.instance_variable_get(:@all_tasks)).not_to be_empty
        expect(controller.instance_variable_get(:@student_tasks)).to be_empty
        expect(controller.instance_variable_get(:@current_student_tasks)).to be_empty
        expect(controller.instance_variable_get(:@past_student_tasks)).to be_empty
      end
    end

    context 'when there are available assignments due in the future and in the past' do
      it 'should populate past_student_tasks and current_student_tasks instance variable with tasks' do
        session = {user: student}
        allow(StudentTask).to receive(:from_user).with(student).and_return([student_task_past, student_task_current])
        get :list, session
        expect(controller.instance_variable_get(:@all_tasks)).not_to be_empty
        expect(controller.instance_variable_get(:@student_tasks)).not_to be_empty
        expect(controller.instance_variable_get(:@current_student_tasks)).not_to be_empty
        expect(controller.instance_variable_get(:@past_student_tasks)).not_to be_empty
      end
    end

  end
end