require 'rails_helper'
describe ReportsController do
  let(:assignment) { double('Assignment', id: 1) }
  let(:review_response_map) do
    double('ReviewResponseMap', id: 1, map_id: 1, assignment: assignment,
                                reviewer: double('Participant', id: 1, name: 'reviewer'), reviewee: double('Participant', id: 2, name: 'reviewee'))
  end
  let(:participant) { double('AssignmentParticipant', id: 1, can_review: false, user: double('User', id: 1)) }
  let(:participant1) { double('AssignmentParticipant', id: 2, can_review: true, user: double('User', id: 2)) }
  let(:user) { double('User', id: 3) }
  let(:participant2) { double('AssignmentParticipant', id: 3, can_review: true, user: user) }
  let(:team) { double('AssignmentTeam', name: 'no one') }
  let(:team1) { double('AssignmentTeam', name: 'no one1') }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    instructor = build(:instructor)
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  shared_examples_for "summary_report" do
    it 'renders response_report page with corresponding data' do
      allow(SummaryHelper::Summary).to receive_message_chain(:new, :summarize_reviews_by_reviewees)
        .with(no_args).with(assignment, 'expertiza.ncsu.edu')
        .and_return(double('Summary', summary: 'awesome!',
                                      reviewers: [participant, participant1],
                                      avg_scores_by_reviewee: 95,
                                      avg_scores_by_round: 92,
                                      avg_scores_by_criterion: 94))
      params = {
        id: 1,
        report: {type: 'SummaryByRevieweeAndCriteria'}
      }
      get :response_report, params
      expect(response).to render_template(:response_report)
    end
  end

  describe 'response_report' do
    before(:each) do
      stub_const('WEBSERVICE_CONFIG', 'summary_webservice_url' => 'expertiza.ncsu.edu')
    end

    describe 'summary_by_reviewee_and_criteria' do
      context 'when type is SummaryByRevieweeAndCriteria' do
        it_should_behave_like "summary_report"
      end
    end

    describe 'summary_by_criteria' do
      context 'when type is SummaryByCriteria' do
        it_should_behave_like "summary_report"
      end
    end

    describe 'review_response_map' do
      context 'when type is ReviewResponseMap' do
        it 'renders response_report page with corresponding data' do
          allow(ReviewResponseMap).to receive(:review_response_report)
            .with('1', assignment, 'ReviewResponseMap', 'no one')
            .and_return([participant, participant1])
          allow(assignment).to receive(:compute_reviews_hash)
            .and_return('1' => 'good')
          allow(assignment).to receive(:compute_avg_and_ranges_hash)
            .and_return(avg: 94, range: [90, 99])
          params = {
            id: 1,
            report: {type: 'ReviewResponseMap'},
            user: 'no one'
          }
          get :response_report, params
          expect(response).to render_template(:response_report)
        end
      end
    end

    describe 'feedback_response_map' do
      context 'when type is FeedbackResponseMap' do
        context 'when assignment has varying_rubrics_by_round feature' do
          it 'renders response_report page with corresponding data' do
            allow(assignment).to receive(:varying_rubrics_by_round?).and_return(true)
            allow(FeedbackResponseMap).to receive(:feedback_response_report)
              .with('1', 'FeedbackResponseMap').and_return([participant, participant1], [1, 2], [3, 4], [])
            params = {
              id: 1,
              report: {type: 'FeedbackResponseMap'}
            }
            get :response_report, params
            expect(response).to render_template(:response_report)
          end
        end

        context 'when assignment does not have varying_rubrics_by_round feature' do
          it 'renders response_report page with corresponding data' do
            allow(assignment).to receive(:varying_rubrics_by_round?).and_return(false)
            allow(FeedbackResponseMap).to receive(:feedback_response_report)
              .with('1', 'FeedbackResponseMap').and_return([participant, participant1], [1, 2, 3, 4])
            params = {
              id: 1,
              report: {type: 'FeedbackResponseMap'}
            }
            get :response_report, params
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
          params = {
            id: 1,
            report: {type: 'TeammateReviewResponseMap'}
          }
          get :response_report, params
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
          params = {
            id: 1,
            report: {type: 'Calibration'}
          }
          session = {user: user}
          get :response_report, params, session
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
          params = {
            id: 1,
            report: {type: 'PlagiarismCheckerReport'}
          }
          get :response_report, params
          expect(response).to render_template(:response_report)
        end
      end
    end
  end
end
