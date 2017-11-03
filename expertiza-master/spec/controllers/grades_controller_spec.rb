describe GradesController do
  let(:review_response) { build(:response) }
  let(:assignment) { build(:assignment, id: 1, questionnaires: [review_questionnaire], is_penalty_calculated: true) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire, used_in_round: 1, assignment: assignment) }
  let(:participant) { build(:participant, id: 1, assignment: assignment, user_id: 1) }
  let(:review_questionnaire) { build(:questionnaire, id: 1, questions: [question]) }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:question) { build(:question) }
  let(:team) { build(:assignment_team, id: 1, assignment: assignment, users: [instructor]) }
  let(:student) { build(:student) }
  let(:review_response_map) { build(:review_response_map, id: 1) }
  let(:assignment_due_date) { build(:assignment_due_date) }

  before(:each) do
    allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
    allow(participant).to receive(:team).and_return(team)
    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
  end

  describe '#view' do
    context 'when current assignment varys rubric by round' do
      it 'retrieves questions, calculates scores and renders grades#view page'
    end

    context 'when current assignment does not vary rubric by round' do
      it 'calculates scores and renders grades#view page'
    end
  end

  describe '#view_my_scores' do
    before(:each) do
      allow(Participant).to receive(:find_by).with(id: '1').and_return(participant)
      allow(Participant).to receive(:find).with('1').and_return(participant)
    end

    context 'when view_my_scores page is not allow to access' do
      it 'shows a flash errot message and redirects to rot path (/)'
    end

    context 'when view_my_scores page is allow to access' do
      it 'renders grades#view_my_scores page'
    end
  end

  describe '#view_team' do
    it 'renders grades#view_team page'
  end

  describe '#edit' do
    it 'renders grades#edit page'
  end

  describe '#instructor_review' do
    context 'when review does not exist' do
      it 'redirects to grades#new page'
    end

    context 'when review does not exist' do
      it 'redirects to grades#edit page'
    end
  end

  describe '#update' do
    context 'when total is not equal to participant\'s grade' do
      it 'updates grades and redirects to grades#edit page'
    end

    context 'when total is equal to participant\'s grade' do
      it 'redirects to grades#edit page'
    end
  end

  describe '#save_grade_and_comment_for_submission' do
    it 'saves grade and comment for submission and redirects to assignments#list_submissions page'
  end
end
