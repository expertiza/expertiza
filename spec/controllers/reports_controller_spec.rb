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
          allow(ReviewResponseMap).to receive(:review_response_report)
            .with('1', assignment, 'ReviewResponseMap', 'no one')
            .and_return([participant, participant1])
          allow_any_instance_of(Scoring).to receive(:compute_reviews_hash).with(assignment)
                                                                          .and_return('1' => 'good')
          allow_any_instance_of(Scoring).to receive(:compute_avg_and_ranges_hash).with(assignment)
                                                                                 .and_return(avg: 94, range: [90, 99])
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
            allow(assignment).to receive(:vary_by_round?).and_return(true)
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
            allow(assignment).to receive(:vary_by_round?).and_return(false)
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
end
