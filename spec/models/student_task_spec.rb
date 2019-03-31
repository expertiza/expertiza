describe StudentTask do
  # Write your mocked object here!
  let(:assignment) { build(:assignment) }
  let(:participant) { build(:participant, user_id: 1) }
  let(:student_task) do
    StudentTask.new(assignment: assignment, participant: participant, stage_deadline: Time.zone.now.to_s)
  end

  describe '#from_participant' do
    it 'creates new student task using student task as participant' do
      expect(StudentTask.from_participant(student_task).stage_deadline.to_s).to eq(student_task.stage_deadline.to_s)
    end
  end
end
