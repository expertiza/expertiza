describe StudentTask do
  # Write your mocked object here!
  let(:participant) { build(:participant) }
  let(:user) { build(:student) }
  let(:assignment) { build(:assignment) }
  let(:student_task) do
    StudentTask.new(
      user: user,
      participant: participant,
      assignment: assignment
    )
  end
end
