describe StudentTask do
  # Write your mocked object here!
  let(:participant) { build(:participant, id: 1, user_id: user.id, parent_id: assignment.id) }
  let(:participant2) { build(:participant, id: 2, user_id: user2.id, parent_id: assignment.id) }
  let(:participant3) { build(:participant, id: 3, user_id: user3.id, parent_id: assignment2.id) }
  let(:user) { create(:student) }
  let(:user2) { create(:student, name: "qwertyui", id: 5) }
  let(:user3) { create(:student, name: "qwertyui1234", id: 6) }
  let(:course) { build(:course) }
  let(:assignment) { build(:assignment, name: 'assignment 1') }
  let(:assignment2) { create(:assignment, name: 'assignment 2', is_calibrated: true) }
  let(:team) { create(:assignment_team, id: 1, name: 'team 1', parent_id: assignment.id, users: [user, user2]) }
  let(:team2) { create(:assignment_team, id: 2, name: 'team 2', parent_id: assignment2.id, users: [user3]) }
  let(:team_user) { create(:team_user, id: 3, team_id: team.id, user_id: user.id) }
  let(:team_user2) { create(:team_user, id: 4, team_id: team.id, user_id: user2.id) }
  let(:team2_user3) { create(:team_user, id: 5, team_id: team2.id, user_id: user3.id) }
  let(:course_team) { create(:course_team, id: 3, name: 'course team 1', parent_id: course.id) }
  let(:cource_team_user) { create(:team_user, id: 6, team_id: course_team.id, user_id: user.id) }
  let(:cource_team_user2) { create(:team_user, id: 7, team_id: course_team.id, user_id: user2.id) }
  let(:topic) { build(:topic) }
  let(:topic2) { create(:topic, topic_name: "TestReview") }
  let(:due_date) { build(:assignment_due_date, deadline_type_id: 1) }
  let(:deadline_type) { build(:deadline_type, id: 1) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team2) }
  let(:metareview_response_map) { build(:meta_review_response_map, reviewed_object_id: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map) }
  let(:response2) { build(:response, id: 2, map_id: 1, response_map: review_response_map) }
  let(:submission_record) {build(:submission_record, id:1, team_id: 1, assignment_id: 1) }
  let(:student_task) do
    StudentTask.new(
      user: user,
      participant: participant,
      assignment: assignment,
      stage_deadline: 'Complete'
    )
  end
  let(:student_task2) do
    StudentTask.new(
      user: user,
      participant: participant,
      assignment: assignment
    )
  end

describe "#complete?" do
      it 'checks a student_task is complete' do
        expect(student_task.complete?).to be true
      end
end

describe "#incomplete?" do
      it 'checks a student_task is incomplete' do
	expect(student_task2.incomplete?).to be true
      end 	
end

describe "#not_started?" do
	it 'returns true' do
	allow(student_task).to receive(:in_work_stage?).and_return(true)
	allow(student_task).to receive(:started?).and_return(true)
	expect(student_task.not_started?).to eq(false)
	end
end

end
