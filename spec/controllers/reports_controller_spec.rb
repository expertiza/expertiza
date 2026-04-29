require 'rails_helper'
describe ReportsController do
  let(:assignment) { double('Assignment', id: 1) }
  let(:review_response_map) do
    double('ReviewResponseMap', id: 1, map_id: 1, assignment: assignment,
                                reviewer: double('Participant', id: 1, name: 'reviewer'), reviewee: double('Participant', id: 2, name: 'reviewee'))
  end
  let(:participant) { double('AssignmentParticipant', id: 1, can_review: false, user: double('User', id: 1)) }
  let(:participant1) { double('AssignmentParticipant', id: 2, can_review: true, user: double('User', id: 2)) }
  let(:role) { double('Role', id: 2) }
  let(:user) { double('User', id: 3, role: role) }
  let(:participant2) { double('AssignmentParticipant', id: 3, can_review: true, user: user) }
  let(:team) { double('AssignmentTeam', name: 'no one') }
  let(:team1) { double('AssignmentTeam', name: 'no one1') }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    instructor = build(:instructor)
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  describe 'response_report' do
    before(:each) do
      stub_const('WEBSERVICE_CONFIG', 'summary_webservice_url' => 'expertiza.ncsu.edu')
    end

    describe 'review_response_map' do
      context 'when type is ReviewResponseMap' do
        it 'renders response_report page with corresponding data' do
          allow(assignment).to receive(:varying_rubrics_by_round?).and_return(false)
          allow(assignment).to receive(:contributors).and_return([])
          allow(ReviewResponseMap).to receive(:review_response_report)
            .with('1', assignment, 'ReviewResponseMap', 'no one')
            .and_return([participant, participant1])
          request_params = {
            id: 1,
            report: { type: 'ReviewResponseMap' },
            user: 'no one'
          }
          get :response_report, params: request_params
          expect(response).to render_template(:response_report)
        end
      end
    end

    describe 'feedback_response_map' do
      context 'when type is FeedbackResponseMap' do
        context 'when assignment varies rubrics by round' do
          it 'renders response_report page with corresponding data' do
            allow(assignment).to receive(:varying_rubrics_by_round?).and_return(true)
            allow(FeedbackResponseMap).to receive(:feedback_response_report)
              .with('1', 'FeedbackResponseMap').and_return([participant, participant1], [1, 2], [3, 4], [])
            request_params = {
              id: 1,
              report: { type: 'FeedbackResponseMap' }
            }
            get :response_report, params: request_params
            expect(response).to render_template(:response_report)
          end
        end

        context 'when assignment does not vary rubrics by round' do
          it 'renders response_report page with corresponding data' do
            allow(assignment).to receive(:varying_rubrics_by_round?).and_return(false)
            allow(FeedbackResponseMap).to receive(:feedback_response_report)
              .with('1', 'FeedbackResponseMap').and_return([participant, participant1], [1, 2, 3, 4])
            request_params = {
              id: 1,
              report: { type: 'FeedbackResponseMap' }
            }
            get :response_report, params: request_params
            expect(response).to render_template(:response_report)
          end
        end
      end
    end

    describe 'teammate_review_response_map' do
      context 'when type is TeammateReviewResponseMap' do
        it 'renders response_report page with corresponding data' do
          allow(TeammateReviewResponseMap).to receive(:teammate_response_report)
            .with('1').and_return([participant, participant2])
          request_params = {
            id: 1,
            report: { type: 'TeammateReviewResponseMap' }
          }
          get :response_report, params: request_params
          expect(response).to render_template(:response_report)
        end
      end
    end

    describe 'calibration' do
      context 'when type is Calibration and participant variable is nil' do
        it 'renders response_report page with corresponding data' do
          allow(AssignmentParticipant).to receive(:where).with(parent_id: '1', user_id: 3).and_return([nil])
          allow(AssignmentParticipant).to receive(:create)
            .with(parent_id: '1', user_id: 3, can_submit: 1, can_review: 1, can_take_quiz: 1, handle: 'handle')
            .and_return(participant)
          allow(ReviewQuestionnaire).to receive(:select).with('id').and_return([1, 2, 3])
          assignment_questionnaire = double('AssignmentQuestionnaire')
          allow(AssignmentQuestionnaire).to receive(:retrieve_questionnaire_for_assignment).with('1').and_return([assignment_questionnaire])
          allow(assignment_questionnaire).to receive_message_chain(:questionnaire, :questions)
            .and_return([double('Question', type: 'Criterion')])
          allow(ReviewResponseMap).to receive(:where).with(reviewed_object_id: '1', calibrate_to: 1).and_return([review_response_map])
          allow(ReviewResponseMap).to receive_message_chain(:select, :where)
            .with('id').with(reviewed_object_id: '1', calibrate_to: 0).and_return([1, 2])
          allow(Response).to receive(:where).with(map_id: [1, 2]).and_return([double('response')])
          allow(role).to receive(:has_all_privileges_of?).with(any_args).and_return(true)
          request_params = {
            id: 1,
            report: { type: 'Calibration' }
          }
          user_session = { user: user }
          get :response_report, params: request_params, session: user_session
          expect(response).to render_template(:response_report)
        end
      end
    end

    describe 'plagiarism_checker_report' do
      context 'when type is PlagiarismCheckerReport' do
        it 'renders response_report page with corresponding data' do
          allow(PlagiarismCheckerAssignmentSubmission).to receive_message_chain(:where, :pluck)
            .with(assignment_id: '1').with(:id)
            .and_return([double('PlagiarismCheckerAssignmentSubmission', id: 1)])
          allow(PlagiarismCheckerAssignmentSubmission).to receive(:where)
            .with(plagiarism_checker_assignment_submission_id: 1)
            .and_return([double('PlagiarismCheckerAssignmentSubmission')])
          request_params = {
            id: 1,
            report: { type: 'PlagiarismCheckerReport' }
          }
          get :response_report, params: request_params
          expect(response).to render_template(:response_report)
        end
      end
    end
  end

  describe 'get_llm_evaluation' do
    it 'stores formative and summative review data on instructor review scores' do
      mcp_client = instance_double(MCPServerClient)
      instructor_review_score = instance_double(InstructorReviewScore, save!: true)

      allow(MCPServerClient).to receive(:new).and_return(mcp_client)
      allow(Response).to receive(:latest_submitted_review_response_ids_for_assignment).with(1).and_return([10])
      allow(mcp_client).to receive(:get_finalized_review).with(10).and_return(
        'summative_feedback_score' => 4.0,
        'formative_feedback_score' => 3.5,
        'feedback_of_summative_feedback' => 'Strong final review.',
        'feedback_of_formative_feedback' => 'Add more actionable suggestions.'
      )
      allow(InstructorReviewScore).to receive(:find_or_initialize_by).with(response_id: 10).and_return(instructor_review_score)
      allow(instructor_review_score).to receive(:score_for_summative=).with(4.0)
      allow(instructor_review_score).to receive(:score_for_formative=).with(3.5)
      allow(instructor_review_score).to receive(:feedback_for_summative=).with('Strong final review.')
      allow(instructor_review_score).to receive(:feedback_for_formative=).with('Add more actionable suggestions.')
      allow(controller).to receive(:save_review_grades_from_instructor_scores)

      get :get_llm_evaluation, params: { id: 1 }

      expect(instructor_review_score).to have_received(:score_for_summative=).with(4.0)
      expect(instructor_review_score).to have_received(:score_for_formative=).with(3.5)
      expect(instructor_review_score).to have_received(:feedback_for_summative=).with('Strong final review.')
      expect(instructor_review_score).to have_received(:feedback_for_formative=).with('Add more actionable suggestions.')
      expect(controller).to have_received(:save_review_grades_from_instructor_scores).with(assignment)
    end
  end

  describe '#save_review_grades_from_instructor_scores' do
    it 'keeps two-round reviews on the original 5 plus 5 scale' do
      response_relation = instance_double(ActiveRecord::Relation)
      response_map_relation = instance_double(ActiveRecord::Relation)
      review_grade = instance_double(ReviewGrade, save!: true)
      instructor_user = instance_double(User, id: 99)
      instructor_review_scores = [
        instance_double(InstructorReviewScore, response_id: 10, score_for_summative: 1.0, score_for_formative: 4.0),
        instance_double(InstructorReviewScore, response_id: 11, score_for_summative: 5.0, score_for_formative: 3.0),
        instance_double(InstructorReviewScore, response_id: 12, score_for_summative: 2.0, score_for_formative: 5.0),
        instance_double(InstructorReviewScore, response_id: 13, score_for_summative: 4.0, score_for_formative: 4.0)
      ]

      allow(assignment).to receive(:num_review_rounds).and_return(2)
      allow(Response).to receive(:latest_submitted_review_response_ids_for_assignment).with(1).and_return([10, 11, 12, 13])
      allow(Response).to receive(:where).with(id: [10, 11, 12, 13]).and_return(response_relation)
      allow(response_relation).to receive(:pluck).with(:id, :map_id, :round).and_return([[10, 100, 1], [11, 100, 2], [12, 101, 1], [13, 101, 2]])
      allow(ResponseMap).to receive(:where).with(id: [100, 101]).and_return(response_map_relation)
      allow(response_map_relation).to receive(:pluck).with(:id, :reviewer_id).and_return([[100, 1], [101, 1]])
      allow(InstructorReviewScore).to receive(:where).with(response_id: [10, 11, 12, 13]).and_return(instructor_review_scores)
      allow(ReviewGrade).to receive(:find_or_initialize_by).with(participant_id: 1).and_return(review_grade)
      allow(review_grade).to receive(:grade_for_reviewer=)
      allow(review_grade).to receive(:comment_for_reviewer=)
      allow(review_grade).to receive(:review_graded_at=)
      allow(review_grade).to receive(:reviewer_id=)
      allow(controller).to receive(:session).and_return(user: instructor_user)

      controller.send(:save_review_grades_from_instructor_scores, assignment)

      expect(review_grade).to have_received(:grade_for_reviewer=).with(16.0)
      expect(review_grade).to have_received(:comment_for_reviewer=).with('Your scores are 7, 9 | Review 1 round 1: 4 round 2: 3, total 7 | Review 2 round 1: 5 round 2: 4, total 9')
      expect(review_grade).to have_received(:reviewer_id=).with(99)
      expect(review_grade).to have_received(:save!)
    end

    it 'normalizes single-round reviews from 5 points to 10 points' do
      response_relation = instance_double(ActiveRecord::Relation)
      response_map_relation = instance_double(ActiveRecord::Relation)
      review_grade = instance_double(ReviewGrade, save!: true)
      instructor_user = instance_double(User, id: 99)
      instructor_review_scores = [
        instance_double(InstructorReviewScore, response_id: 10, score_for_summative: 1.0, score_for_formative: 3.5),
        instance_double(InstructorReviewScore, response_id: 11, score_for_summative: 5.0, score_for_formative: 4.5)
      ]

      allow(assignment).to receive(:num_review_rounds).and_return(1)
      allow(Response).to receive(:latest_submitted_review_response_ids_for_assignment).with(1).and_return([10, 11])
      allow(Response).to receive(:where).with(id: [10, 11]).and_return(response_relation)
      allow(response_relation).to receive(:pluck).with(:id, :map_id, :round).and_return([[10, 100, 1], [11, 101, 1]])
      allow(ResponseMap).to receive(:where).with(id: [100, 101]).and_return(response_map_relation)
      allow(response_map_relation).to receive(:pluck).with(:id, :reviewer_id).and_return([[100, 1], [101, 1]])
      allow(InstructorReviewScore).to receive(:where).with(response_id: [10, 11]).and_return(instructor_review_scores)
      allow(ReviewGrade).to receive(:find_or_initialize_by).with(participant_id: 1).and_return(review_grade)
      allow(review_grade).to receive(:grade_for_reviewer=)
      allow(review_grade).to receive(:comment_for_reviewer=)
      allow(review_grade).to receive(:review_graded_at=)
      allow(review_grade).to receive(:reviewer_id=)
      allow(controller).to receive(:session).and_return(user: instructor_user)

      controller.send(:save_review_grades_from_instructor_scores, assignment)

      expect(review_grade).to have_received(:grade_for_reviewer=).with(16.0)
      expect(review_grade).to have_received(:comment_for_reviewer=).with('Your scores are 7, 9')
      expect(review_grade).to have_received(:reviewer_id=).with(99)
      expect(review_grade).to have_received(:save!)
    end
  end
end
