describe GradesController do
  let(:review_response) { build(:response) }
  let(:assignment) { build(:assignment, id: 1, questionnaires: [review_questionnaire], is_penalty_calculated: true) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire, used_in_round: 1, assignment: assignment) }
  let(:participant) { build(:participant, id: 1, assignment: assignment, user_id: 1) }
  let(:participant2) { build(:participant, id: 2, assignment: assignment, user_id: 1) }
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
    before(:each) do
      allow(Answer).to receive(:compute_scores).with([review_response], [question]).and_return(max: 95, min: 88, avg: 90)
      allow(Participant).to receive(:where).with(parent_id: 1).and_return([participant])
      allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
      allow(assignment).to receive(:late_policy_id).and_return(false)
      allow(assignment).to receive(:calculate_penalty).and_return(false)
    end

    context 'when current assignment varys rubric by round' do
      it 'retrieves questions, calculates scores and renders grades#view page' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 2).and_return([assignment_questionnaire])
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, questionnaire_id: 1).and_return([assignment_questionnaire])
        params = {id: 1}
        get :view, params
        expect(controller.instance_variable_get(:@questions)[:review1].size).to eq(1)
        expect(response).to render_template(:view)
      end
    end

    context 'when current assignment does not vary rubric by round' do
      it 'calculates scores and renders grades#view page' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 2).and_return([])
        allow(ReviewResponseMap).to receive(:get_assessments_for).with(team).and_return([review_response])
        params = {id: 1}
        get :view, params
        expect(controller.instance_variable_get(:@questions)[:review].size).to eq(1)
        expect(response).to render_template(:view)
      end
    end
  end

  describe '#view_my_scores' do
    before(:each) do
      allow(Participant).to receive(:find_by).with(id: '1').and_return(participant)
      allow(Participant).to receive(:find).with('1').and_return(participant)
    end

    context 'when view_my_scores page is not allow to access' do
      it 'shows a flash errot message and redirects to root path (/)' do
        allow(TeamsUser).to receive(:where).with(user_id: 1).and_return([double('TeamsUser', team_id: 1)])
        team.users = []
        allow(Team).to receive(:find).with(1).and_return(team)
        params = {id: 1}
        get :view_my_scores, params
        expect(response).to redirect_to('/')
      end
    end

    context 'when view_my_scores page is allow to access' do
      it 'renders grades#view_my_scores page' do
        allow(TeamsUser).to receive(:where).with(any_args).and_return([double('TeamsUser', team_id: 1)])
        allow(Team).to receive(:find).with(1).and_return(team)
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1).and_return(assignment_questionnaire)
        allow(AssignmentQuestionnaire).to receive(:where).with(any_args).and_return([assignment_questionnaire])
        allow(review_questionnaire).to receive(:get_assessments_round_for).with(participant, 1).and_return([review_response])
        allow(Answer).to receive(:compute_scores).with([review_response], [question]).and_return(max: 95, min: 88, avg: 90)
        allow(Participant).to receive(:where).with(parent_id: 1).and_return([participant])
        allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
        allow(assignment).to receive(:late_policy_id).and_return(false)
        allow(assignment).to receive(:calculate_penalty).and_return(false)
        allow(assignment).to receive(:compute_total_score).with(any_args).and_return(100)
        params = {id: 1}
        session = {user: instructor}
        get :view_my_scores, params, session
        expect(response).to render_template(:view_my_scores)
      end
    end
  end

  xdescribe '#view_team' do
    it 'renders grades#view_team page' do
      allow(participant).to receive(:team).and_return(team)
      params = {id: 1}
      get :view_team, params
      expect(response).to render_template(:view_team)
    end
  end

  describe '#edit' do
    it 'renders grades#edit page' do
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 2).and_return([])
      assignment_questionnaire.used_in_round = nil
      allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1).and_return(assignment_questionnaire)
      allow(review_questionnaire).to receive(:get_assessments_for).with(participant).and_return([review_response])
      allow(Answer).to receive(:compute_scores).with([review_response], [question]).and_return(max: 95, min: 88, avg: 90)
      allow(assignment).to receive(:compute_total_score).with(any_args).and_return(100)
      params = {id: 1}
      get :edit, params
      expect(response).to render_template(:edit)
    end
  end

  describe '#instructor_review' do
    context 'when review exists' do
      it 'redirects to response#edit page' do
        allow(AssignmentParticipant).to receive(:find_or_create_by).with(user_id: 6, parent_id: 1).and_return(participant)
        allow(participant).to receive(:new_record?).and_return(false)
        allow(ReviewResponseMap).to receive(:find_or_create_by).with(reviewee_id: 1, reviewer_id: 1, reviewed_object_id: 1).and_return(review_response_map)
        allow(review_response_map).to receive(:new_record?).and_return(false)
        allow(Response).to receive(:find_by).with(map_id: 1).and_return(review_response)
        params = {id: 1}
        session = {user: instructor}
        get :instructor_review, params, session
        expect(response).to redirect_to('/response/edit?return=instructor')
      end
    end

    context 'when review does not exist' do
      it 'redirects to response#new page' do
        allow(AssignmentParticipant).to receive(:find_or_create_by).with(user_id: 6, parent_id: 1).and_return(participant2)
        allow(participant2).to receive(:new_record?).and_return(false)
        allow(ReviewResponseMap).to receive(:find_or_create_by).with(reviewee_id: 1, reviewer_id: 2, reviewed_object_id: 1).and_return(review_response_map)
        allow(review_response_map).to receive(:new_record?).and_return(true)
        allow(Response).to receive(:find_by).with(map_id: 1).and_return(review_response)
        params = {id: 1}
        session = {user: instructor}
        get :instructor_review, params, session
        expect(response).to redirect_to('/response/new?id=1&return=instructor')
      end
    end
  end

  describe '#update' do
    before(:each) do
      allow(participant).to receive(:update_attribute).with(any_args).and_return(participant)
    end
    context 'when total is not equal to participant\'s grade' do
      it 'updates grades and redirects to grades#edit page' do
        params = {
          id: 1,
          total_score: 98,
          participant: {
            grade: 96
          }
        }
        post :update, params
        expect(flash[:note]).to eq("The computed score will be used for #{participant.user.name}.")
        expect(response).to redirect_to('/grades/1/edit')
      end
    end

    context 'when total is equal to participant\'s grade' do
      it 'redirects to grades#edit page' do
        params = {
          id: 1,
          total_score: 98,
          participant: {
            grade: 98
          }
        }
        post :update, params
        expect(flash[:note]).to eq("The computed score will be used for #{participant.user.name}.")
        expect(response).to redirect_to('/grades/1/edit')
      end
    end
  end

  describe '#save_grade_and_comment_for_submission' do
    it 'saves grade and comment for submission and refreshes the grades#view_team page' do
      allow(AssignmentParticipant).to receive(:find_by).with(id: '1').and_return(participant)
      allow(participant).to receive(:team).and_return(build(:assignment_team, id: 2, parent_id: 8))
      params = {
        participant_id: 1,
        grade_for_submission: 100,
        comment_for_submission: 'comment'
      }
      post :save_grade_and_comment_for_submission, params
      expect(flash[:error]).to be nil
      expect(response).to redirect_to('/grades/view_team?id=1')
    end
  end
end
