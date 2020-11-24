describe RevisionPlanQuestionnairesController do
    let(:questionnaire) { build(:questionnaire,id:1) }
    let(:revision_plan_questionnaire) { build(:revision_plan_questionnaire, questionnaire_id: 1, team_id: 1) }
    let(:team) { create(:assignment_team, id: 1, parent_id: 1) }
    let(:question) { build(:question, id: 1, user: {}) }
    let(:admin) { build(:admin) }
    let(:instructor) { build(:instructor, id: 6) }
    let(:student) { build(:student, id: 1) }
    let(:student2) { build(:student, id: 4) }
    let(:assignment) { build(:assignment, id: 1, instructor_id: 6, microtask: true, staggered_deadline: true) }
    before(:each) do
      allow(Questionnaire).to receive(:find).with(any_args).and_return(questionnaire)
      allow(RevisionPlanQuestionnaire).to receive(:find).with(any_args).and_return(questionnaire)
      allow(User).to receive(:find).with(1).and_return(student)
      controller.params = {id: 1,team_id: 1}
      allow(Team).to receive(:find).with(any_args).and_return(1)
      #allow(TeamsUser).to receive(:where).with(team: Team).and_return([student])
     # allow(TeamsUser).to receive(:where).with(any_args).and_return(student)
      allow(TeamsUser).to receive(:team_id).with('1', 1).and_return(1)
    end
  
    def check_access username
      stub_current_user(username, username.role.name, username.role)
      expect(controller.send(:action_allowed?))
    end
  
    describe '#action_allowed?' do
  
      context 'when params action is edit or update' do
  
        before(:each) do
          controller.params = {id: '1', action: 'edit',team_id: 1}
          controller.request.session[:user] = student
        end
  
        context 'when the role name of current user is super admin or admin' do
          it 'allows certain action' do
            check_access(admin).to be true
          end
        end
  
  
        context 'when current user is a student but not of the team' do
          it 'does not allow certain action' do
            check_access(student2).to be false
          end
        end
      end

      context 'when params action is not edit and update' do
        before(:each) do
          controller.params = {id: '1', action: 'new',team_id: 1}
        end
  
        context 'when the role current user is super admin/admin/instructor/ta' do
          it 'allows certain action except edit and update' do
            check_access(admin).to be true
          end
        end
      end
    end

    describe '#new' do

        it 'creates new questionnaire object and renders questionnaires#new page' do
            allow(Assignment).to receive(:number_of_current_round).with(topic_id:8 ).and_return(2)    
            allow(Questionnaire).to receive(:get_questionnaire_for_current_round).with( 1).and_return(2) 
            params = {id: 1, questionnaire_id: 1, team_id: 1}   
            get :new, params
        end
    end
end
