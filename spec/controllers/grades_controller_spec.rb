describe GradesController do
  let(:review_response) { build(:response) }
  let(:assignment) { build(:assignment, id: 1, max_team_size: 2, questionnaires: [review_questionnaire], is_penalty_calculated: true)}
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
  let(:ta) { build(:teaching_assistant, id: 8) }

  before(:each) do
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

    context 'when current assignment varies rubrics by round' do
      it 'retrieves questions, calculates scores and renders grades#view page' do
        allow(assignment).to receive(:vary_by_round).and_return(true)
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
        allow(ReviewResponseMap).to receive(:assessments_for).with(team).and_return([review_response])
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

    context 'when view_my_scores page is not allowed to access' do
      it 'shows a flash error message and redirects to root path (/)' do
        session[:user] = nil
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

  describe '#view_team' do
    render_views

    # All stubs and factories are instantiated within this scope so as to not 
    # clash with other broken test.
    # The names of the factories created for testing view_team
    # have `_vt` suffix ```where necessary``` to differentiate them from 
    # the above declared factories

    let(:student1_vt) { create(:student, name: "barry", id: 12) }
    let(:student2_vt) { create(:student, name: "iris", id: 13) }

    let(:tm_questionnaire) {
      build(
        :teammate_review_questionnaire,
        id: 12,
        questions: [question],
        max_question_score: 5
      )
    }
    let(:assignment_vt) {
      create(:assignment, id: 6, max_team_size: 2,
      questionnaires: [tm_questionnaire])
    }
    let(:assignment_questionnaire_vt) {
      create(:tm_assignment_questionnaire, id: 12, used_in_round: nil,
      assignment: assignment_vt, questionnaire: tm_questionnaire) }
    let(:team_vt) { create(:assignment_team, id: 12,
    assignment: assignment_vt) }
    let(:participant_vt) { create(:participant, id: 12,
      assignment: assignment_vt, user_id: student1_vt.id) }
    let(:participant2_vt) { create(:participant, id: 13,
      assignment: assignment_vt, user_id: student2_vt.id) }


    before(:each) do
      # Need to stub this method so the factory instance with
      # the stubbed :team method is returned by :find
      # instead of a separate instance with the same data
      allow(AssignmentParticipant)
        .to receive(:find)
        .with(participant_vt.id.to_s)
        .and_return(participant_vt)
      allow(participant_vt).to receive(:team).and_return(team_vt)
      allow(team_vt).to receive(:participants).and_return([participant_vt, participant2_vt])
      allow(AssignmentQuestionnaire)
        .to receive(:find_by)
        .with(assignment_id: assignment_vt.id, questionnaire_id: tm_questionnaire.id)
        .and_return(assignment_questionnaire_vt)
      allow(AssignmentQuestionnaire)
        .to receive(:find_by)
        .with(assignment_id: assignment.id, questionnaire_id: review_questionnaire.id)
        .and_return(assignment_questionnaire_vt)
      allow(AssignmentQuestionnaire)
        .to receive(:where)
        .with(any_args)
        .and_return([assignment_questionnaire_vt])
      allow(assignment_vt)
        .to receive(:late_policy_id)
        .and_return(false)
      allow(assignment_vt)
        .to receive(:calculate_penalty)
        .and_return(false)
      allow(assignment_vt)
        .to receive(:compute_total_score)
        .with(any_args)
        .and_return(100)
      allow(review_questionnaire).to receive(:get_assessments_round_for).with(participant, 1).and_return([review_response])
      allow(Answer).to receive(:compute_scores).with([review_response], [question]).and_return(max: 95, min: 88, avg: 90)
    end

    it 'renders grades#view_team page' do
      params = {id: participant_vt.id}
      get :view_team, params
      expect(response).to render_template(:view_team)
    end

    context 'dropdown for selecting a teammate review' do
      it 'is not rendered is not rendered when page is opened by student' do
        session = { user: student1_vt }
        params = {id: participant_vt.id}
        stub_current_user(student1_vt, student1_vt.role.name, student1_vt.role)
        get :view_team, params
        expect(response.body).to_not have_selector('select')
      end

      it 'is rendered when page is opened by instructor' do
        session = { user: instructor }
        params = {id: participant_vt.id}
        get :view_team, params
        expect(response.body).to have_selector('select')
      end
    end

    context 'when view_team page is viewed by a student who is also a TA for another course' do
      it 'renders grades#view_team page' do
        params = { id: participant_vt.id }
        allow(TaMapping).to receive(:exists?).with(ta_id: participant_vt.user_id, course_id: 1).and_return(true)
        stub_current_user(ta, ta.role.name, ta.role)
        get :view_team, params
        expect(response.body).not_to have_content "TA"
      end
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

  describe '#action_allowed' do
    context 'when the student does not belong to a team' do
      it 'returns false' do 
        params = {action: 'view_team'}
        session[:user].role.name = 'Student'
        expect(controller.action_allowed?).to eq(false)
      end
    end
    context 'when the user is an instructor' do
      it 'returns true' do 
        params = {action: 'view_team'} 
        session[:user].role.name = 'Instructor'
        expect(controller.action_allowed?).to eq(true)
      end
    end
  end

  describe '#redirect_when_disallowed' do
    context 'when a participant without a team exists' do
      it 'redirects to /' do
        params = {id: 1}
        session
        allow(participant).to receive(:team).and_return(nil)
        allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
        allow(TeamsUser).to receive(:team_id).and_return(1)
        get :view_my_scores, params
        expect(response).to redirect_to('/')
      end
    end 
  end
end
