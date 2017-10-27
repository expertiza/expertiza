require 'rails_helper'
describe ReviewMappingController do
  let(:assignment) { double('Assignment', id: 1) }
  let(:review_response_map) do
    double('ReviewResponseMap', id: 1, map_id: 1, assignment: assignment,
                                reviewer: double('Participant', id: 1, name: 'reviewer'), reviewee: double('Participant', id: 2, name: 'reviewee'))
  end
  let(:metareview_response_map) do
    double('MetareviewResponseMap', id: 1, map_id: 1, assignment: assignment,
                                    reviewer: double('Participant', id: 1, name: 'reviewer'), reviewee: double('Participant', id: 2, name: 'reviewee'))
  end
  let(:participant) { double('AssignmentParticipant', id: 1, can_review: false, user: double('User', id: 1)) }
  let(:participant1) { double('AssignmentParticipant', id: 2, can_review: true, user: double('User', id: 2)) }
  let(:user) { double('User', id: 3) }
  let(:participant2) { double('AssignmentParticipant', id: 3, can_review: true, user: user) }
  let(:team) { double('AssignmentTeam', name: 'no one') }
  let(:team1) { double('AssignmentTeam', name: 'no one1') }
  let(:resp) { double('Response', is_submitted: false) }



  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    instructor = build(:instructor)
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  describe '#add_calibration' do
    context 'when both participant and review_response_map have already existed' do
      it 'does not need to create new objects and redirects to responses#new maps'
    end

    context 'when both participant and review_response_map have not been created' do
      it 'creates new objects and redirects to responses#new maps'
    end
  end

  describe '#add_reviewer and #get_reviewer' do
    context 'when team_user does not exist' do
      it 'shows an error message and redirects to review_mapping#list_mappings page'

    end

    context 'when team_user exists and get_reviewer method returns a reviewer' do
      it 'creates a whole bunch of objects and redirects to review_mapping#list_mappings page'
    end
  end

  describe '#assign_reviewer_dynamically' do
    context 'when assignment has topics and no topic is selected by reviewer' do
      it 'shows an error message and redirects to student_review#list page' do
        expect(Assignment).to receive(:find).and_return(assignment)
        expect(AssignmentParticipant).to receive(:where).and_return([participant])
        expect(assignment).to receive(:has_topics?).and_return(true)
        expect(assignment).to receive(:can_choose_topic_to_review?).and_return(true)
        get :assign_reviewer_dynamically
        expect(flash[:error]).to eq("No topic is selected.  Please go back and select a topic.")
        expect(response).to redirect_to ('/student_review/list?id=' +participant.id.to_s)
      end
    end

    context 'when assignment has topics and a topic is selected by reviewer' do
      it 'assigns reviewer dynamically and redirects to student_review#list page' do
        expect(Assignment).to receive(:find).and_return(assignment)
        expect(AssignmentParticipant).to receive(:where).and_return([participant])
        expect(assignment).to receive(:has_topics?).and_return(true)
        dummy_topic = double()
        expect(SignUpTopic).to receive(:find).and_return(dummy_topic)
        allow(dummy_topic).to receive(:nil?).and_return(false)
        expect(assignment).to receive(:assign_reviewer_dynamically).with(any_args)
        get :assign_reviewer_dynamically, :topic_id => '1'
        expect(response).to redirect_to ('/student_review/list?id=' +participant.id.to_s)
      end
    end

    context 'when assignment does not have topics' do
      it 'runs another algorithms and redirects to student_review#list page' do
        expect(Assignment).to receive(:find).and_return(assignment)
        expect(AssignmentParticipant).to receive(:where).and_return([participant])
        expect(assignment).to receive(:has_topics?).and_return(false)
        expect(assignment).to receive(:candidate_assignment_teams_to_review).and_return(team)
        get :assign_reviewer_dynamically
        expect(response).to redirect_to ('/student_review/list?id=' +participant.id.to_s)
      end
    end
  end

  describe '#assign_quiz_dynamically' do
    context 'when corresponding response map exists' do
      it 'shows a flash error and redirects to student_quizzes page'

    end

    context 'when corresponding response map does not exist' do
      it 'creates a new QuizResponseMap and redirects to student_quizzes page'

    end
  end

  describe '#add_metareviewer' do
    it 'redirects to review_mapping#list_mappings page' do

    end

  end

  describe '#assign_metareviewer_dynamically' do
    it 'redirects to student_review#list page' do
      expect(Assignment).to receive(:find).and_return(assignment)
      expect(AssignmentParticipant).to receive(:where).and_return([participant])
      expect(assignment).to receive(:assign_metareviewer_dynamically)
      get :assign_metareviewer_dynamically
      expect(response).to redirect_to ('/student_review/list?id=' +participant.id.to_s)
    end
  end

  describe '#delete_outstanding_reviewers' do
    context 'when review response map has corresponding responses' do
      it 'shows a flash error and redirects to review_mapping#list_mappings page' do
      end
    end

    context 'when review response map does not have corresponding responses' do
      it 'shows a flash success and redirects to review_mapping#list_mappings page'
    end
  end

  describe '#delete_all_metareviewers' do
    context 'when failed times are bigger than 0' do
      it 'shows an error flash message and redirects to review_mapping#list_mappings page'
    end

    context 'when failed time is equal to 0' do
      it 'shows a note flash message and redirects to review_mapping#list_mappings page'
    end
  end

  describe '#unsubmit_review' do
    context 'when attributes of response are updated successfully' do
      it 'shows a success flash.now message and renders a .js.erb file' do
        expect(Response).to receive(:where).and_return([resp])
        expect(ReviewResponseMap).to receive(:find_by).and_return(review_response_map)
        expect(resp).to receive(:update_attribute).and_return(true)
        xhr :get, :unsubmit_review, format: :json
         expect(flash.now[:success]).to eq("The review by \"" +
                                          review_response_map.reviewer.name +
                                           "\" for \"" + review_response_map.reviewee.name +
                                           "\" has been unsubmitted.")
        expect(response).to render_template('unsubmit_review.js.erb')
      end
    end

    context 'when attributes of response are not updated successfully' do
      it 'shows an error flash.now message and renders a .js.erb file' do
        expect(Response).to receive(:where).and_return([resp])
        expect(ReviewResponseMap).to receive(:find_by).and_return(review_response_map)
        expect(resp).to receive(:update_attribute).and_return(false)
        xhr :get, :unsubmit_review, format: :json
        expect(flash.now[:error]).to eq("The review by \"" + review_response_map.reviewer.name +
                                        "\" for \"" + review_response_map.reviewee.name +
                                        "\" could not be unsubmitted.")
      expect(response).to render_template('unsubmit_review.js.erb')
    end
    end
  end

  describe '#delete_reviewer' do
    context 'when corresponding response does not exist to current review response map' do
      it 'shows a success flash message and redirects to previous page'
    end

    context 'when corresponding response exists to current review response map' do
      it 'shows an error flash message and redirects to previous page'
    end
  end

  describe '#delete_metareviewer' do
    context 'when metareview_response_map can be deleted successfully' do
      it 'show a note flash message and redirects to review_mapping#list_mappings page' do
        expect(MetareviewResponseMap).to receive(:find).and_return(metareview_response_map)
        expect(metareview_response_map).to receive(:delete).and_return(true)
        get :delete_metareviewer, id: assignment.id
        expect(flash[:note]).to eq("The metareview mapping for " + metareview_response_map.reviewee.name+
                                       " and " + metareview_response_map.reviewer.name + " has been deleted.")
        expect(response).to redirect_to ('/review_mapping/list_mappings?id=' +assignment.id.to_s)
      end
    end

    context 'when metareview_response_map cannot be deleted successfully' do
      it 'show a note flash message and redirects to review_mapping#list_mappings page' do
        expect(MetareviewResponseMap).to receive(:find).and_return(metareview_response_map)
        expect(metareview_response_map).to receive(:delete).and_return(false)
        get :delete_metareviewer, id: assignment.id
        expect(flash[:note]).to eq("The metareview mapping for " + metareview_response_map.reviewee.name+
                                       " and " + metareview_response_map.reviewer.name + " has been deleted.")
        expect(response).to redirect_to ('/review_mapping/list_mappings?id=' +assignment.id.to_s)
      end
    end
  end

  describe '#delete_metareview' do
    it 'redirects to review_mapping#list_mappings page after deletion'
  end

  describe '#list_mappings' do
    it 'renders review_mapping#list_mappings page'
  end

  describe '#automatic_review_mapping' do
    context 'when teams is not empty' do
      context 'when all nums in params are 0' do
        it 'shows an error flash message and redirects to review_mapping#list_mappings page'
      end

      context 'when all nums in params are 0 except student_review_num' do
        it 'runs automatic review mapping strategy and redirects to review_mapping#list_mappings page'
      end

      context 'when calibrated params are not 0' do
        it 'runs automatic review mapping strategy and redirects to review_mapping#list_mappings page'
      end
    end

    context 'when teams is empty, max team size is 1 and when review params are not 0' do
      it 'shows an error flash message and redirects to review_mapping#list_mappings page'
    end
  end

  describe '#automatic_review_mapping_staggered' do
    it 'shows a note flash message and redirects to review_mapping#list_mappings page' do
      expect(Assignment).to receive(:find).and_return(assignment)
      allow(assignment).to receive(:assign_reviewers_staggered).with(any_args).and_return("check")
      get :automatic_review_mapping_staggered,  id: assignment.id, assignment: {num_reviews: '1', num_metareviews:'2' }
      expect(flash[:note]).to be_present
      expect(response).to redirect_to ('/review_mapping/list_mappings?id=' +assignment.id.to_s)

   end
  end

  describe 'response_report' do
    context 'when type is SummaryByRevieweeAndCriteria' do
      it 'renders response_report page with corresponding data'
    end

    context 'when type is SummaryByCriteria' do
      it 'renders response_report page with corresponding data'
    end

    context 'when type is ReviewResponseMap' do
      it 'renders response_report page with corresponding data'
    end

    context 'when type is FeedbackResponseMap' do
      context 'when assignment has varying_rubrics_by_round feature' do
        it 'renders response_report page with corresponding data'
      end

      context 'when assignment does not have varying_rubrics_by_round feature' do
        it 'renders response_report page with corresponding data'
      end
    end

    context 'when type is TeammateReviewResponseMap' do
      it 'renders response_report page with corresponding data'
    end

    context 'when type is Calibration and participant variable is nil' do
      it 'renders response_report page with corresponding data'
    end

    context 'when type is PlagiarismCheckerReport' do
      it 'renders response_report page with corresponding data'
    end
  end

  describe '#save_grade_and_comment_for_reviewer' do
    it 'redirects to review_mapping#response_report page'
  end

  describe '#start_self_review' do
    context 'when self review response map does not exist' do
      it 'creates a new record and redirects to submitted_content#edit page' do
        expect(Assignment).to receive(:find).and_return(assignment)
        expect(TeamsUser).to receive(:find_by_sql).and_return([team])
        expect(SelfReviewResponseMap).to receive(:where).with(reviewee_id: team.id,
                                                             reviewer_id: params[:reviewer_id]).and_return(true)
        expect(SelfReviewResponseMap).to receive(:create)
        get :start_self_review
        #expect(response).to redirect_to ('/submitted_content/edit?id=' +team.id.to_s)
      end
    end

    context 'when self review response map exists' do
      it 'redirects to submitted_content#edit page' do
      allow(Assignment).to receive(:find).and_return(assignment)
      allow(TeamsUser).to receive(:find_by_sql).and_return([team])
      #get :start_self_review
      #expect(response).to redirect_to ('/submitted_content/edit?id=' +team.id.to_s)
      end
    end
  end
  end

