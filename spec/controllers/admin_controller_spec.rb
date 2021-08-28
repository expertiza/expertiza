describe AdminController do
    let(:review_response) { build(:response) }
    let(:assignment) { build(:assignment, id: 1, max_team_size: 2, questionnaires: [review_questionnaire], is_penalty_calculated: true)}
    let(:assignment_questionnaire) { build(:assignment_questionnaire, used_in_round: 1, assignment: assignment) }
    let(:participant) { build(:participant, id: 1, assignment: assignment, user_id: 1) }
    let(:participant2) { build(:participant, id: 2, assignment: assignment, user_id: 1) }
    let(:review_questionnaire) { build(:questionnaire, id: 1, questions: [question]) }
    let(:admin) { build(:admin) }
    let(:administrator) { build(:administrator) }
    let(:instructor) { build(:instructor, id: 6) }
    let(:question) { build(:question) }
    let(:team) { build(:assignment_team, id: 1, assignment: assignment, users: [instructor]) }
    let(:student) { build(:student) }
    let(:review_response_map) { build(:review_response_map, id: 1) }
    let(:assignment_due_date) { build(:assignment_due_date) }
    let(:ta) { build(:teaching_assistant, id: 8) }
  
    before(:each) do
      allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
      allow(participant).to receive(:team).and_return(team)
      stub_current_user(instructor, instructor.role.name, instructor.role)
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
    end

    describe '#action_allowed?' do
        context 'when the student doesnt have admin privileges' do
            it 'returns false' do 
                params = {action: 'list_instructors'}
                session[:user].role.name = 'Student'
                expect(controller.action_allowed?).to eq(false)
            end
            
            it 'returns false' do
                params = {action: 'remove_instructor'}
                session[:user].role.name = 'Student'
                expect(controller.action_allowed?).to eq(false)
            end
        end
        context 'when the student has super-admin privileges' do
            it 'returns true' do
                params = {action: 'fake_case'}
                session[:user].role.name = 'Super-Administrator'
                expect(controller.action_allowed?).to eq(true) 
            end
        end
    end

    describe '#list_super_administrators' do
        
    end

    describe '#show_super_administrator' do
        
    end

    describe '#list_administrators' do
        
    end

    describe '#show_administrator' do
        
    end

    describe '#list_instructors' do
        
    end

    describe '#show_instructor' do
        
    end

end