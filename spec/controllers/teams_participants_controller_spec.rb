# spec/controllers/teams_participants_controller_spec.rb
require 'rails_helper'
require_relative '../support/teams_shared'

RSpec.describe TeamsParticipantsController, type: :controller do
  include_context 'object initializations'

  let(:student)     { build(:student) }
  let(:admin)       { build(:admin) }
  let(:instructor)  { build(:instructor) }
  let(:course1)     { build(:course, id: 1) }

  let(:assignment1) do
    build(
      :assignment,
      id: 1,
      name: 'test assignment',
      instructor_id: 6,
      staggered_deadline: true,
      directory_path: 'same path',
      course_id: 1
    )
  end

  let(:team1) { build(:assignment_team, id: 1, parent_id: assignment1.id) }
  let(:team5) { build(:course_team,     id: 5, parent_id: course1.id) }
  let(:participant)  { build(:participant, id: 1, parent_id: assignment1.id) }
  let(:participant2) { build(:participant, id: 2, parent_id: assignment1.id) }

  let(:teams_participant1) do
    TeamsParticipant.new(id: 1, team_id: team1.id, participant_id: participant.id, duty_id: 1)
  end
  let(:teams_participant2) do
    TeamsParticipant.new(id: 2, team_id: team1.id, participant_id: participant2.id, duty_id: 1)
  end

  before do
    allow(Assignment).to receive(:find).with('1').and_return(assignment1)
    stub_current_user(student, student.role.name, student.role)
  end

  describe '#action_allowed?' do
    context "when action == 'update_duties'" do
      before { controller.params = { id: '1', action: 'update_duties' } }

      it 'allows a student to update duties' do
        stub_current_user(student, student.role.name, student.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end

  describe '#update_duties' do
    it 'updates a duty and redirects back to student_teams#view' do
      allow(TeamsParticipant).to receive(:find).with('1').and_return(teams_participant1)
      allow(teams_participant1).to receive(:update_attribute).and_return(true)

      request_params = {
        teams_participant_id: '1',
        teams_participant:     { duty_id: '1' },
        participant_id:        '1'
      }
      session       = { user: student }
      get :update_duties, params: request_params, session: session

      expect(response).to redirect_to('/student_teams/view?student_id=1')
    end
  end

  include_context 'authorization check'
  context 'students should not have access to admin actions' do
    it 'denies access for student1' do
      stub_current_user(student1, student1.role.name, student1.role)
      expect(controller.send(:action_allowed?)).to be false
    end
  end

  describe '#list' do
    it 'renders the list template for an assignment team' do
      allow(Team).to       receive(:find).with('1').and_return(team1)
      allow(Assignment).to receive(:find).with(1).and_return(assignment1)

      get :list, params: { id: 1 }, session: { user: instructor }
      expect(response).to render_template(:list)
    end
  end

  describe '#new' do
    it 'loads @team for the new form' do
      allow(Team).to receive(:find).with('1').and_return(team1)
      get :new, params: { id: 1 }, session: { user: instructor }
      expect(assigns(:team)).to eq(team1)
    end
  end

  describe '#create' do
    let(:student1) { build(:student, id: 1, name: 'student2065') }

    context 'when user not defined' do
      it 'sets flash error and redirects' do
        allow(User).to    receive(:find_by).with(name: 'instructor6').and_return(nil)
        allow(Team).to    receive(:find).with('1').and_return(team1)

        post :create, params: { user: { name: 'instructor6' }, id: 1 }, session: { user: admin }

        expect(flash[:error]).to match(/"instructor6" is not defined/)
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end

    context 'when not a participant of the assignment' do
      it 'sets flash error and redirects' do
        allow(User).to                   receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to                   receive(:find).with('1').and_return(team1)
        allow(Assignment).to             receive(:find).with(1).and_return(assignment1)
        allow(AssignmentParticipant).to  receive(:find_by).with(user_id: 1, parent_id: 1).and_return(nil)

        post :create, params: { user: { name: student1.name }, id: 1 }, session: { user: admin }

        expect(flash[:error]).to match(/is not a participant of the current assignment/)
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end

    context 'when team full' do
      it 'sets flash error and redirects' do
        allow(User).to                   receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to                   receive(:find).with('1').and_return(team1)
        allow(Assignment).to             receive(:find).with(1).and_return(assignment1)
        allow(AssignmentParticipant).to  receive(:find_by).and_return(participant)
        allow_any_instance_of(Team).to   receive(:add_member).and_return(false)

        post :create, params: { user: { name: student1.name }, id: 1 }, session: { user: admin }

        expect(flash[:error]).to eq('This team already has the maximum number of members.')
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end

    context 'when successfully added to assignment team' do
      it 'redirects back to list' do
        allow(User).to                   receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to                   receive(:find).and_return(team1)
        allow(Assignment).to             receive(:find).with(1).and_return(assignment1)
        allow(AssignmentParticipant).to  receive(:find_by).and_return(participant)
        allow_any_instance_of(Team).to   receive(:add_member).and_return(true)
        allow(TeamsParticipant).to       receive(:last).and_return(participant.user)

        post :create, params: { user: { name: student1.name }, id: 1 }, session: { user: admin }
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end

    # …and similarly for the “course team” contexts, swapping in CourseTeam,
    # CourseParticipant, and redirect to the same teams/list path…

  end

  describe '#delete' do
    it 'removes the member and redirects back to the team' do
      allow(TeamsParticipant).to receive(:find).with('1').and_return(teams_participant1)
      allow(Team).to           receive(:find).with(team1.id).and_return(team1)
      allow(User).to           receive(:find).with(teams_participant1.participant.user_id).and_return(student1)

      post :delete, params: { id: 1 }, session: { user: instructor }
      expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end
  end

  describe '#delete_selected' do
    it 'removes multiple members and redirects' do
      allow(TeamsParticipant).to receive(:find).with('1').and_return([teams_participant1])
      allow(TeamsParticipant).to receive(:find).with('2').and_return([teams_participant2])

      post :delete_selected, params: { item: ['1', '2'] }, session: { user: instructor }
      expect(response).to redirect_to('http://test.host/teams_participants/list')
    end
  end
end
