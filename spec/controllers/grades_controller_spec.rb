describe GradesController do
  let(:review_response) { build(:response) }
  let(:assignment) { build(:assignment, id: 1, max_team_size: 2, questionnaires: [review_questionnaire], is_penalty_calculated: true) }
  let(:assignment2) { build(:assignment, id: 2, max_team_size: 2, questionnaires: [review_questionnaire], is_penalty_calculated: true) }
  let(:assignment3) { build(:assignment, id: 3, max_team_size: 0, questionnaires: [review_questionnaire], is_penalty_calculated: true) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire, used_in_round: 1, assignment: assignment) }
  let(:participant) { build(:participant, id: 1, assignment: assignment, user_id: 1) }
  let(:participant2) { build(:participant, id: 2, assignment: assignment, user_id: 1) }
  let(:participant3) { build(:participant, id: 3, assignment: assignment, user_id: 1, grade: 98) }
  let(:participant4) { build(:participant, id: 4, assignment: assignment2, user_id: 1) }
  let(:participant5) { build(:participant, id: 5, assignment: assignment3, user_id: 1) }
  let(:review_questionnaire) { build(:questionnaire, id: 1, questions: [question]) }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:question) { build(:question) }
  let(:team) { build(:assignment_team, id: 1, assignment: assignment, users: [instructor]) }
  let(:team2) { build(:assignment_team, id: 2, parent_id: 8) }
  let(:student) { build(:student, id: 2) }
  let(:review_response_map) { build(:review_response_map, id: 1) }
  let(:assignment_due_date) { build(:assignment_due_date) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:late_policy) { build(:late_policy) }
  score_view_setup_query = '
  CREATE OR REPLACE VIEW score_views AS SELECT ques.weight question_weight,ques.type AS type,
      q1.id "q1_id",q1.NAME AS q1_name,q1.instructor_id AS q1_instructor_id,q1.private AS q1_private,
      q1.min_question_score AS q1_min_question_score,q1.max_question_score AS q1_max_question_score,
      q1.created_at AS q1_created_at,q1.updated_at AS q1_updated_at,
      q1.TYPE AS q1_type,q1.display_type AS q1_display_type,
      ques.id as ques_id,ques.questionnaire_id as ques_questionnaire_id, s.id AS s_id,s.question_id AS s_question_id,
      s.answer AS s_score,s.comments AS s_comments,s.response_id AS s_response_id
      FROM questions ques left join questionnaires q1 on ques.questionnaire_id = q1.id left join answers s on ques.id = s.question_id'
  ActiveRecord::Base.connection.execute(score_view_setup_query)
  before(:each) do
    allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
    allow(AssignmentParticipant).to receive(:find).with('3').and_return(participant3)
    allow(AssignmentParticipant).to receive(:find).with('4').and_return(participant4)
    allow(AssignmentParticipant).to receive(:find).with('5').and_return(participant5)
    allow(AssignmentDueDate).to receive(:where).and_return([assignment_due_date])
    allow(participant).to receive(:team).and_return(team)
    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    allow_any_instance_of(Assignment).to receive(:late_policy_id).and_return(1)
    allow(controller).to receive(:calculate_penalty).and_return({ submission: 0, review: 0, meta_review: 0 })
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
        allow(assignment).to receive(:vary_by_round?).and_return(true)
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 2).and_return([assignment_questionnaire])
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, questionnaire_id: 1).and_return([assignment_questionnaire])
        request_params = { id: 1 }
        get :view, params: request_params
        expect(controller.instance_variable_get(:@questions)[:review1].size).to eq(1)
        expect(response).to render_template(:view)
      end
    end

    context 'when current assignment does not vary rubric by round' do
      it 'calculates scores and renders grades#view page' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 2).and_return([])
        allow(ReviewResponseMap).to receive(:assessments_for).with(team).and_return([review_response])
        request_params = { id: 1 }
        get :view, params: request_params
        expect(controller.instance_variable_get(:@questions).size).to eq(1)
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
        request_params = { id: 1 }
        get :view_my_scores, params: request_params
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
        allow_any_instance_of(GradesController).to receive(:compute_total_score).with(assignment, any_args).and_return(100)
        request_params = { id: 1 }
        user_session = { user: instructor }
        get :view_my_scores, params: request_params, session: user_session
        expect(response).to render_template(:view_my_scores)
      end
    end
  end

  xdescribe '#view_team' do
    it 'renders grades#view_team page' do
      allow(participant).to receive(:team).and_return(team2)
      request_params = { id: 1 }
      get :view_team, params: request_params
      expect(response).to render_template(:view_team)
    end
  end

  describe '#view_team' do
    render_views
    context 'when view_team page is viewed by a student who is also a TA for another course' do
      it 'renders grades#view_team page' do
        allow(participant).to receive(:team).and_return(team)
        allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1).and_return(assignment_questionnaire)
        allow(AssignmentQuestionnaire).to receive(:where).with(any_args).and_return([assignment_questionnaire])
        allow(assignment).to receive(:late_policy_id).and_return(false)
        allow(assignment).to receive(:calculate_penalty).and_return(false)
        allow_any_instance_of(GradesController).to receive(:compute_total_score).with(assignment, any_args).and_return(100)
        allow(review_questionnaire).to receive(:get_assessments_round_for).with(participant, 1).and_return([review_response])
        allow(Answer).to receive(:compute_scores).with([review_response], [question]).and_return(max: 95, min: 88, avg: 90)
        request_params = { id: 1 }
        allow(TaMapping).to receive(:exists?).with(ta_id: 1, course_id: 1).and_return(true)
        stub_current_user(ta, ta.role.name, ta.role)
        get :view_team, params: request_params
        expect(response.body).not_to have_content 'TA'
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
      allow_any_instance_of(GradesController).to receive(:compute_total_score).with(assignment, any_args).and_return(100)
      request_params = { id: 1 }
      get :edit, params: request_params
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
        request_params = { id: 1 }
        user_session = { user: instructor }
        get :instructor_review, params: request_params, session: user_session
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
        request_params = { id: 1 }
        user_session = { user: instructor }
        get :instructor_review, params: request_params, session: user_session
        expect(response).to redirect_to('/response/new?id=1&return=instructor')
      end
    end
  end

  describe '#update' do
    context 'when participant\'s grade is update' do
      it 'updates grades and redirects to grades#edit page' do
        request_params = {
          id: 3,
          total_score: 98,
          participant: {
            grade: 98
          }
        }
        allow(participant3).to receive(:update_attribute).with(any_args).and_return(participant3)
        post :update, params: request_params
        expect(flash[:note]).to eq('A score of 98% has been saved for instructor6.')
        expect(response).to redirect_to('/grades/3/edit')
      end
    end
    context 'when total is not equal to participant\'s grade' do
      it 'updates grades and redirects to grades#edit page' do
        request_params = {
          id: 1,
          total_score: 98,
          participant: {
            grade: 96
          }
        }
        allow(participant).to receive(:update_attribute).with(any_args).and_return(participant)
        post :update, params: request_params
        expect(flash[:note]).to eq("The computed score will be used for #{participant.user.name}.")
        expect(response).to redirect_to('/grades/1/edit')
      end
    end

    context 'when total is equal to participant\'s grade' do
      it 'redirects to grades#edit page' do
        request_params = {
          id: 1,
          total_score: 98,
          participant: {
            grade: 98
          }
        }
        allow(participant).to receive(:update_attribute).with(any_args).and_return(participant)
        post :update, params: request_params
        expect(flash[:note]).to eq("The computed score will be used for #{participant.user.name}.")
        expect(response).to redirect_to('/grades/1/edit')
      end
    end
  end

  describe '#save_grade_and_comment_for_submission' do
    it 'saves grade and comment for submission and refreshes the grades#view_team page' do
      allow(AssignmentParticipant).to receive(:find_by).with(id: '1').and_return(participant)
      allow(participant).to receive(:team).and_return(build(:assignment_team, id: 2, parent_id: 8))
      request_params = {
        participant_id: 1,
        grade_for_submission: 100,
        comment_for_submission: 'comment'
      }
      post :save_grade_and_comment_for_submission, params: request_params
      expect(flash[:error]).to be nil
      expect(response).to redirect_to('/grades/view_team?id=1')
    end

    context 'save grade and comment for submission failed' do
      it 'catch error' do
        allow(AssignmentParticipant).to receive(:find_by).with(id: '4').and_return(participant4)
        allow(participant4).to receive(:team).and_return(team2)
        request_params = {
          participant_id: 4,
          grade_for_submission: 100,
          comment_for_submission: 'comment'
        }
        post :save_grade_and_comment_for_submission, params: request_params
        allow(team2).to receive(:save).and_raise StandardError
        expect { save_grade_and_comment_for_submission }.to raise_error StandardError
      end
    end
  end

  describe '#action_allowed' do
    context 'when the student does not belong to a team' do
      it 'returns false' do
        params = { action: 'view_team' }
        session[:user].role.name = 'Student'
        expect(controller.action_allowed?).to eq(false)
      end
    end
    context 'when the user is an instructor' do
      it 'returns true' do
        params = { action: 'view_team' }
        session[:user].role.name = 'Instructor'
        expect(controller.action_allowed?).to eq(true)
      end
    end
    context 'when the user is an student' do
      before(:each) do
        controller.params = { id: 4, action: 'view_team' }
      end
      it 'only see the heat map for their own team' do
        stub_current_user(student, student.role.name, student.role)
        allow(AssignmentParticipant).to receive(:find).with(4).and_return(participant4)
        allow(AssignmentParticipant).to receive(:exist?).with(parent_id: 2, user_id: 2).and_return(false)
        expect(controller.action_allowed?).to eq(false)
      end
    end
  end

  describe '#redirect_when_disallowed' do
    context 'when a participant without a team exists' do
      it 'redirects to /' do
        request_params = { id: 1 }
        session
        allow(participant).to receive(:team).and_return(nil)
        allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
        allow(TeamsUser).to receive(:team_id).and_return(1)
        get :view_my_scores, params: request_params
        expect(response).to redirect_to('/')
      end
    end
  end
end
