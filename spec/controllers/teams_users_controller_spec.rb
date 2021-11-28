describe TeamsUsersController do
  let(:assignment) do
    build(:assignment, id: 1, name: 'test assignment', instructor_id: 6, staggered_deadline: true, directory_path: 'same path',
          participants: [build(:participant)], teams: [build(:assignment_team)], course_id: 1)
  end
  let(:assignment_form) { double('AssignmentForm', assignment: assignment) }
  let(:student) { build(:student) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:duty1) { build(:duty, id: 1, duty_name: "Role", max_members_for_duty: 2, assignment_id: 1) }
  let(:duty2) { build(:duty, id: 2, duty_name: "Role", max_members_for_duty: 2, assignment_id: 1) }
  let(:team_user) { build(:team_user, id: 1, team_id: 1, user_id: 1, duty_id: 1) }

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


  describe '#update_duties' do
    context 'testing the function to update duty_id' do
      it 'when duties are updated correctly' do
        allow(TeamsUser).to receive(:find).with('1').and_return(team_user)
        params = {teams_user_id: 1, teams_user: { duty_id: 2 }, participant_id: 1 }
        session = {user: instructor}
        post :update_duties, params, session
        expect(response).to redirect_to
      end
    end
  end
end
