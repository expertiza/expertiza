RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

shared_context 'object initializations' do
  let(:superadmin) { build_stubbed(:superadmin) }
  let(:admin) { build_stubbed(:admin) }
  let(:instructor) { build_stubbed(:instructor, id: 1) }
  let(:ta) { build_stubbed(:teaching_assistant) }
  let(:student1) { build_stubbed(:student, id: 1, name: 'student2065') }
  let(:student2) { build_stubbed(:student, id: 2) }
  let(:course1) { build_stubbed(:course, id: 517, name: 'TestCourse', instructor_id: instructor.id) }
  let(:assignment1) { build_stubbed(:assignment, name: 'TestAssignment', id: 1) }
  let(:team1) { build_stubbed(:assignment_team, id: 1, parent_id: assignment1.id) }
  let(:team2) { build_stubbed(:assignment_team, id: 2, parent_id: assignment1.id) }
  let(:team3) { build_stubbed(:assignment_team, id: 3, parent_id: assignment1.id) }
  let(:team4) { build_stubbed(:assignment_team, id: 4, parent_id: assignment1.id) }
  let(:team5) { build_stubbed(:course_team, id: 5, parent_id: course1.id) }
  let(:team6) { build_stubbed(:course_team, id: 6, parent_id: course1.id) }
  let(:join_team_request1) { build_stubbed(:join_team_request, id: 1, team_id: team1.id, status: 'P') }
  let(:join_team_request2) { build_stubbed(:join_team_request, id: 2, team_id: team2.id, status: 'P',comments: "Any comment") }
  let(:join_team_request3) { build_stubbed(:join_team_request, id: 3, team_id: team2.id, status: 'D',comments: "Updated") }
  let(:invalidrequest) { build_stubbed(:join_team_request) }
  let(:participant) { build_stubbed(:participant, id: 1) }

end

shared_context 'authorization check', :shared_context => :metadata do
  it 'superadmin credentials' do
    stub_current_user(superadmin, superadmin.role.name, superadmin.role)
    expect(controller.send(:action_allowed?)).to be true
  end
  it 'admin credentials' do
    stub_current_user(admin, admin.role.name, admin.role)
    expect(controller.send(:action_allowed?)).to be true
  end
  it 'ta credentials' do
    stub_current_user(ta, ta.role.name, ta.role)
    expect(controller.send(:action_allowed?)).to be true
  end
  it 'instructor credentials' do
    stub_current_user(instructor, instructor.role.name, instructor.role)
    expect(controller.send(:action_allowed?)).to be true
  end
end
