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
  let(:teamsuser) {'TeamsUser'}
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
      it 'shows an error message and redirects to review_mapping#list_mappings page' do

        expect(User).to receive_message_chain("where.first.id").with(any_args).and_return(user.id)
        expect(TeamsUser).to receive(:exists?).with(any_args).and_return(true)
        #expect(flash[:error]).to match "You cannot assign this student to review his/her own artifact"
        post :add_reviewer, :contributor_id => '1', :id =>'1', :topic_id =>'2', user: {name: '2'}
        expect(flash[:error]) =~ /you cannot assign this student to review his.*her own artifact/i
        expect(response).to redirect_to action: 'list_mappings', id: assignment.id
      end
    end

    context 'when team_user exists and get_reviewer method returns a reviewer' do
      it 'creates a whole bunch of objects and redirects to review_mapping#list_mappings page' do
        expect(User).to receive_message_chain("where.first.id").with(any_args).and_return(user.id)
        expect(TeamsUser).to receive(:exists?).with(any_args).and_return(false)
        expect(SignUpSheet).to receive(:signup_team).with(any_args)
        expect(User).to receive(:from_params).with(any_args).and_return(user)
        expect(AssignmentParticipant).to receive_message_chain("where.first").with(any_args).and_return(participant)
        #expect(ReviewResponseMap).to receive_message_chain("where.first.nil").with(any_args).and_return(true)
        expect(ReviewResponseMap).to receive(:create).with(any_args)
        post :add_reviewer, :contributor_id => '1', :id =>'1', :topic_id =>'2', user: {name: '2'}
        expect(response).to redirect_to action: 'list_mappings', id: assignment.id, msg: ''
      end
    end
  end

  describe '#assign_reviewer_dynamically' do
    context 'when assignment has topics and no topic is selected by reviewer' do
      it 'shows an error message and redirects to student_review#list page'
    end

    context 'when assignment has topics and a topic is selected by reviewer' do
      it 'assigns reviewer dynamically and redirects to student_review#list page'
    end

    context 'when assignment does not have topics' do
      it 'runs another algorithms and redirects to student_review#list page'
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
    it 'redirects to review_mapping#list_mappings page'
  end

  describe '#assign_metareviewer_dynamically' do
    it  'redirects to student_review#list page' do
      expect(AssignmentParticipant).to receive_message_chain("where.first").with(any_args).and_return(participant)
      expect(assignment).to receive(:assign_metareviewer_dynamically).with(participant)
      get :assign_metareviewer_dynamically, :assignment_id=> assignment.id, :metareviewer_id=>participant.id

      expect(response).to redirect_to controller: 'student_review', action: 'list', id: participant.id
    end
  end

  describe '#delete_outstanding_reviewers' do
    context 'when review response map has corresponding responses' do
      it 'shows a flash error and redirects to review_mapping#list_mappings page'
    end

    context 'when review response map does not have corresponding responses' do
      it 'shows a flash success and redirects to review_mapping#list_mappings page'
    end
  end

  describe '#delete_all_metareviewers' do
    context 'when failed times are bigger than 0' do
      it 'shows an error flash message and redirects to review_mapping#list_mappings page' do
        dummy_response_map = double()
        expect(ResponseMap).to receive(:find).with(any_args).and_return(dummy_response_map)
        allow(dummy_response_map).to receive(:map_id).and_return('1')
        allow(dummy_response_map).to receive(:assignment).and_return(assignment)
        expect(MetareviewResponseMap).to receive(:where).with(any_args).and_return(metareview_response_map)
        expect(ResponseMap).to receive(:delete_mappings).with(any_args).and_return(1)
        get :delete_all_metareviewers
        expect(flash[:error]).to be_present
        expect(response).to redirect_to action: 'list_mappings', id: assignment.id
      end
    end

    context 'when failed time is equal to 0' do
      it 'shows a note flash message and redirects to review_mapping#list_mappings page' do
        dummy_response_map = double()
        expect(ResponseMap).to receive(:find).with(any_args).and_return(dummy_response_map)
        allow(dummy_response_map).to receive(:map_id).and_return('1')
        allow(dummy_response_map).to receive(:assignment).and_return(assignment)
        dummy_reviewee = double
        allow(dummy_reviewee).to receive(:name).and_return('test_reviewee')
        dummy_reviewer = double
        allow(dummy_reviewer).to receive(:name).and_return('test_reviewer')
        allow(dummy_response_map).to receive(:reviewee).and_return(dummy_reviewee)
        allow(dummy_response_map).to receive(:reviewer).and_return(dummy_reviewer)
        expect(MetareviewResponseMap).to receive(:where).with(any_args).and_return(metareview_response_map)
        expect(ResponseMap).to receive(:delete_mappings).with(any_args).and_return(0)
        get :delete_all_metareviewers
        expect(flash[:note]).to be_present
        expect(response).to redirect_to action: 'list_mappings', id: assignment.id
      end
    end
  end

  describe '#unsubmit_review' do
    context 'when attributes of response are updated successfully' do
      it 'shows a success flash.now message and renders a .js.erb file'
    end

    context 'when attributes of response are not updated successfully' do
      it 'shows an error flash.now message and renders a .js.erb file'
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
      it 'show a note flash message and redirects to review_mapping#list_mappings page'
    end

    context 'when metareview_response_map cannot be deleted successfully' do
      it 'show a note flash message and redirects to review_mapping#list_mappings page'
    end
  end

  describe '#delete_metareview' do
    it 'redirects to review_mapping#list_mappings page after deletion' do
      dummy_mapping = double
      expect(MetareviewResponseMap).to receive(:find).and_return()
    end
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
    it 'shows a note flash message and redirects to review_mapping#list_mappings page'
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
      it 'creates a new record and redirects to submitted_content#edit page'
    end

    context 'when self review response map exists' do
      it 'redirects to submitted_content#edit page'
    end
  end
end
