RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end
# Declaring common stubbed objects: This creates single instances of superadmin, admin, instructor, teaching assistant, course and assignment.
# There are 2 instances of students, 5 instances of assignment teams, 2 instances of course teams, 4 instances of team join requests, and single instances of participant, node and team user.
shared_context 'object initializations' do
  let(:superadmin) { build_stubbed(:superadmin) }
  let(:admin) { build_stubbed(:admin) }
  let(:instructor) { build_stubbed(:instructor, id: 1) }
  let(:ta) { build_stubbed(:teaching_assistant) }
  let(:student1) { build_stubbed(:student, id: 1, username: 'student2065') }
  let(:student2) { build_stubbed(:student, id: 2) }
  let(:course1) { build_stubbed(:course, name: 'TestCourse', id: 1, instructor_id: instructor.id) }
  let(:assignment1) do
    build(:assignment, id: 1, name: 'test assignment', instructor_id: 6, staggered_deadline: true, directory_path: 'same path',
                       participants: [build(:participant)], teams: [build(:assignment_team)], course_id: 1)
  end
  let(:team1) { build_stubbed(:assignment_team, id: 1, name: 'wolfers', parent_id: assignment1.id) }
  let(:team2) { build_stubbed(:assignment_team, id: 2, parent_id: assignment1.id) }
  let(:team3) { build_stubbed(:assignment_team, id: 3, parent_id: assignment1.id) }
  let(:team4) { build_stubbed(:assignment_team, id: 4, parent_id: assignment1.id) }
  let(:team5) { build_stubbed(:course_team, id: 5, name: 'team5', parent_id: course1.id) }
  let(:team6) { build_stubbed(:course_team, id: 6, parent_id: course1.id) }
  let(:team7) { build_stubbed(:assignment_team, name: 'test', parent_id: course1.id) }
  let(:team8) { build_stubbed(:assignment_team, id: 1, name: 'wolfers', parent_id: assignment1.id) }
  let(:join_team_request1) { build_stubbed(:join_team_request, id: 1, team_id: team1.id, status: 'P') }
  let(:join_team_request2) { build_stubbed(:join_team_request, id: 2, team_id: team2.id, status: 'P', comments: 'Any comment') }
  let(:join_team_request3) { build_stubbed(:join_team_request, id: 3, team_id: team2.id, status: 'D', comments: 'Updated') }
  let(:invalidrequest) { build_stubbed(:join_team_request) }
  let(:participant) { build_stubbed(:participant, id: 1) }
  let(:node1) { build_stubbed(:assignment_node, node_object_id: 1) }
  let(:team_user1) { build_stubbed(:team_user, team_id: 1, user_id: 1, id: 1) }
end
# Creating a shared context for authorization check to be shared with teams related files
shared_context 'authorization check', shared_context: :metadata do
  # Testing to check SuperAdmin access
  it 'superadmin credentials' do
    stub_current_user(superadmin, superadmin.role.name, superadmin.role)
    expect(controller.send(:action_allowed?)).to be true
  end
  # Testing to check Admin access
  it 'admin credentials' do
    stub_current_user(admin, admin.role.name, admin.role)
    expect(controller.send(:action_allowed?)).to be true
  end
  # Testing to check TA access
  it 'ta credentials' do
    stub_current_user(ta, ta.role.name, ta.role)
    expect(controller.send(:action_allowed?)).to be true
  end
  # Testing to check Instructor access
  it 'instructor credentials' do
    stub_current_user(instructor, instructor.role.name, instructor.role)
    expect(controller.send(:action_allowed?)).to be true
  end
end
