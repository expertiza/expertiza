require 'rails_helper'
describe ReviewMappingController do
  let(:assignment) {double('Assignment', id: 1)}
  let(:review_response_map) do
    double('ReviewResponseMap', id: 1, map_id: 1, assignment: assignment,
           reviewer: double('Participant', id: 1, name: 'reviewer'), reviewee: double('Participant', id: 2, name: 'reviewee'))
  end
  let(:metareview_response_map) do
    double('MetareviewResponseMap', id: 1, map_id: 1, assignment: assignment,
           reviewer: double('Participant', id: 1, name: 'reviewer'), reviewee: double('Participant', id: 2, name: 'reviewee'))
  end
  let(:participant) {double('AssignmentParticipant', id: 1, can_review: false, user: double('User', id: 1))}
  let(:participant1) {double('AssignmentParticipant', id: 2, can_review: true, user: double('User', id: 2))}
  let(:user) {double('User', id: 3)}
  let(:participant2) {double('AssignmentParticipant', id: 3, can_review: true, user: user)}
  let(:team) {double('AssignmentTeam', name: 'no one')}
  let(:team1) {double('AssignmentTeam', name: 'no one1')}
  let(:resp) {double('Response', is_submitted: false)}


  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    instructor = build(:instructor)
    stub_current_user(instructor, instructor.role.name, instructor.role)
    request.env["HTTP_REFERER"] = root_url
  end

  describe '#add_calibration' do
    context 'when both participant and review_response_map have already existed' do
      it 'does not need to create new objects and redirects to responses#new maps' do
        expect(AssignmentParticipant).to receive_message_chain("where.first").with(any_args).and_return(participant)
        allow(participant).to receive(:nil?).and_return(false)
        expect(ReviewResponseMap).to receive_message_chain("where.first").with(any_args).and_return(review_response_map)
        params = {id: 1, team_id: 1}
        session[:user] = user
        post :add_calibration, params, session
        expect(response).to redirect_to controller: 'response', action: 'new', id: review_response_map.id, assignment_id: params[:id], return: 'assignment_edit'
      end
    end

    context 'when both participant and review_response_map have not been created' do
      it 'creates new objects and redirects to responses#new maps' do
        expect(AssignmentParticipant).to receive_message_chain("where.first").with(any_args).and_return(participant)
        allow(participant).to receive(:nil?).and_return(true)
        expect(AssignmentParticipant).to receive(:create).with(any_args).and_return(participant)
        expect(ReviewResponseMap).to receive_message_chain("where.first").with(any_args).and_return(review_response_map)
        expect(review_response_map).to receive(:nil?).and_return(true)
        expect(ReviewResponseMap).to receive(:create).with(any_args).and_return(review_response_map)
        params = {id: 1, team_id: 1}
        session[:user] = user
        post :add_calibration, params, session
        expect(response).to redirect_to controller: 'response', action: 'new', id: review_response_map.id, assignment_id: params[:id], return: 'assignment_edit'
      end
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
      it 'shows an error message and redirects to student_review#list page' do
        expect(Assignment).to receive(:find).and_return(assignment)
        expect(AssignmentParticipant).to receive(:where).and_return([participant])
        expect(assignment).to receive(:topics?).and_return(true)
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
        expect(assignment).to receive(:topics?).and_return(true)
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
        expect(assignment).to receive(:topics?).and_return(false)
        expect(assignment).to receive(:topics?).and_return(false)
        assignment_teams = double()
        assignment_team = double()
        expect(assignment).to receive(:candidate_assignment_teams_to_review).with(any_args).and_return(assignment_teams)
        expect(assignment_teams).to receive_message_chain("to_a.sample").and_return(assignment_team)
        expect(assignment_team).to receive(:nil?).and_return(false)
        expect(assignment).to receive(:assign_reviewer_dynamically_no_topic).with(any_args)
        get :assign_reviewer_dynamically
        expect(response).to redirect_to ('/student_review/list?id=' +participant.id.to_s)
      end
    end
  end

  describe '#assign_quiz_dynamically' do
    context 'when corresponding response map exists' do
      it 'shows a flash error and redirects to student_quizzes page'do
        expect(Assignment).to receive(:find).with(any_args).and_return(assignment)
        expect(AssignmentParticipant).to receive_message_chain("where.first").with(any_args).and_return(participant)
        expect(ResponseMap).to receive_message_chain("where.first").with(any_args).and_return(response)
        get :assign_quiz_dynamically
        expect(flash[:error]).to eq("You have already taken that quiz.")
        expect(response).to redirect_to ('/student_quizzes?id='+participant.id.to_s)
      end
    end

    context 'when corresponding response map does not exist' do
      it 'creates a new QuizResponseMap and redirects to student_quizzes page' do
        expect(Assignment).to receive(:find).with(any_args).and_return(assignment)
        expect(AssignmentParticipant).to receive_message_chain("where.first").with(any_args).and_return(participant)
        expect(ResponseMap).to receive_message_chain("where.first").with(any_args).and_return(nil)
        expect(QuizResponseMap).to receive(:new)
        get :assign_quiz_dynamically
        #expect(flash[:error]).to eq("You have already taken that quiz.")
        expect(response).to redirect_to ('/student_quizzes?id='+participant.id.to_s)
      end
    end
  end

  describe '#add_metareviewer' do
    it 'redirects to review_mapping#list_mappings page' do
      expect(ResponseMap).to receive(:find).with(any_args).and_return(review_response_map)
      expect(User).to receive(:from_params).with(any_args).and_return(user)
      expect(user).to receive(:name).and_return("test")
      get :add_metareviewer
      expect(response.location).to match(/http:\/\/test.host\/review_mapping\/list_mappings\?id=1&msg/)
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
        expect(Assignment).to receive(:find).with(any_args).and_return(assignment)
        expect(AssignmentTeam).to receive(:find).with(any_args).and_return(team)
        review_response_maps = double(id: 1)
        expect(team).to receive(:review_mappings).with(any_args).and_return(review_response_maps)
        num_remain_review_response_maps = double()
        expect(review_response_maps).to receive(:size).and_return(2)
        expect(review_response_maps).to receive(:each).with(any_args).and_yield(review_response_map)
        expect(ReviewResponseMap).to receive_message_chain('find.destroy').with(any_args)
        get :delete_outstanding_reviewers
        expect(flash[:error]).to eq("1 reviewer(s) cannot be deleted because they have already started a review.")
      end
    end

    context 'when review response map does not have corresponding responses' do
      it 'shows a flash success and redirects to review_mapping#list_mappings page' do
        expect(Assignment).to receive(:find).with(any_args).and_return(assignment)
        expect(AssignmentTeam).to receive(:find).with(any_args).and_return(team)
        review_response_maps = double(id: 1)
        expect(team).to receive(:review_mappings).with(any_args).and_return(review_response_maps)
        num_remain_review_response_maps = double()
        expect(review_response_maps).to receive(:size).and_return(-1)
        expect(review_response_maps).to receive(:each).with(any_args).and_yield(review_response_map)
        expect(ReviewResponseMap).to receive_message_chain('find.destroy').with(any_args)
        get :delete_outstanding_reviewers
        expect(flash[:success]).to eq("All review mappings for \"#{team.name}\" have been deleted.")
      end
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
      it 'shows a success flash message and redirects to previous page' do
        expect(ReviewResponseMap).to receive(:find_by).with(any_args).and_return(review_response_map)
        expect(Response).to receive(:exists?).with(any_args).and_return(false)
        expect(review_response_map).to receive(:destroy)
        get :delete_reviewer
        expect(flash[:success]).to be_present
        expect(response).to redirect_to (:back)
      end
    end

    context 'when corresponding response exists to current review response map' do
      it 'shows an error flash message and redirects to previous page' do
        expect(ReviewResponseMap).to receive(:find_by).with(any_args).and_return(review_response_map)
        expect(Response).to receive(:exists?).with(any_args).and_return(true)
        get :delete_reviewer
        expect(flash[:error]).to be_present
        expect(response).to redirect_to (:back)
      end
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
    it 'redirects to review_mapping#list_mappings page after deletion' do
      dummy_mapping = double
      expect(MetareviewResponseMap).to receive(:find).and_return(dummy_mapping)
      expect(dummy_mapping).to receive(:assignment).and_return(assignment)
      expect(dummy_mapping).to receive(:delete)
      get :delete_metareview
      expect(response).to redirect_to action: 'list_mappings', id: assignment.id
    end
  end

  describe '#list_mappings' do
    it 'renders review_mapping#list_mappings page' do
      params = {msg: 'error', id: 1}
      expect(Assignment).to receive(:find).with(any_args).and_return(assignment)
      items = double()
      expect(AssignmentTeam).to receive(:where).with(any_args).and_return(items)
      expect(items).to receive(:sort_by)
      get :list_mappings, params
      expect(flash[:error]).to eq(params[:msg])
      expect(response).to render_template('review_mapping/list_mappings')
    end
  end

  describe '#automatic_review_mapping' do
    context 'when teams is not empty' do
      context 'when all nums in params are 0' do
        it 'shows an error flash message and redirects to review_mapping#list_mappings page' do
          expect(AssignmentParticipant).to receive_message_chain("where.to_a.reject.shuffle!").with(any_args).and_return(participant)
          expect(AssignmentTeam).to receive_message_chain("where.to_a.shuffle!").with(any_args).and_return(team)
          allow_any_instance_of(ReviewMappingController).to receive(:team_size).with(any_args)
          allow_any_instance_of(ReviewMappingController).to receive(:artifacts_num).with(any_args)
          allow(team).to receive(:empty?).and_return(false)
          get :automatic_review_mapping, :id =>1, :student_review_num =>0, :submission_review_num=>0, :calibrated_artifacts_num=>0,
              :uncalibrated_artifacts_num=>0, :max_team_size=>0
          expect(flash[:error]) =~ /Please choose either the number of reviews per student or the number of reviewers per team (student), not both./i
          expect(response).to redirect_to action: 'list_mappings', id: 1
        end
      end

      context 'when all nums in params are 0 except student_review_num' do
        it 'runs automatic review mapping strategy and redirects to review_mapping#list_mappings page'do
          expect(AssignmentParticipant).to receive_message_chain("where.to_a.reject.shuffle!").with(any_args).and_return(participant)
          expect(AssignmentTeam).to receive_message_chain("where.to_a.shuffle!").with(any_args).and_return(team)
          allow_any_instance_of(ReviewMappingController).to receive(:team_size).with(any_args)
          allow_any_instance_of(ReviewMappingController).to receive(:artifacts_num).with(any_args)
          allow(team).to receive(:empty?).and_return(false)
          get :automatic_review_mapping, :id =>1, :student_review_num =>1, :submission_review_num=>0, :calibrated_artifacts_num=>0,
              :uncalibrated_artifacts_num=>0, :max_team_size=>0
          allow_any_instance_of(ReviewMappingController).to receive(:automatic_review_mapping_strategy).with(any_args)
          expect(response).to redirect_to action: 'list_mappings', id:1
        end
      end

      context 'when calibrated params are not 0' do
        it 'runs automatic review mapping strategy and redirects to review_mapping#list_mappings page' do
          expect(AssignmentParticipant).to receive_message_chain("where.to_a.reject.shuffle!").with(any_args).and_return(participant)
          expect(AssignmentTeam).to receive_message_chain("where.to_a.shuffle!").with(any_args).and_return(team)
          allow_any_instance_of(ReviewMappingController).to receive(:team_size).with(any_args)
          allow_any_instance_of(ReviewMappingController).to receive(:artifacts_num).with(any_args)
          allow(team).to receive(:empty?).and_return(false)
          get :automatic_review_mapping, :id =>1, :student_review_num =>1, :submission_review_num=>0, :calibrated_artifacts_num=>1,
              :uncalibrated_artifacts_num=>0, :max_team_size=>0
          allow_any_instance_of(ReviewMappingController).to receive(:automatic_review_mapping_strategy).with(any_args)
          expect(response).to redirect_to action: 'list_mappings', id:1
        end
      end
    end

    context 'when teams is empty, max team size is 1 and when review params are not 0' do
      it 'shows an error flash message and redirects to review_mapping#list_mappings page' do
        expect(AssignmentParticipant).to receive_message_chain("where.to_a.reject.shuffle!").with(any_args).and_return(participant)
        expect(AssignmentTeam).to receive_message_chain("where.to_a.shuffle!").with(any_args).and_return(team)
        allow_any_instance_of(ReviewMappingController).to receive(:team_size).with(any_args)
        allow_any_instance_of(ReviewMappingController).to receive(:artifacts_num).with(any_args)
        allow(team).to receive(:empty?).and_return(true)
        #expect(participant).to receive(:each).and_return(participant)
        #expect(participant).to receive(:user).and_return(user)
        get :automatic_review_mapping, :id =>1, :student_review_num =>1, :submission_review_num=>1, :calibrated_artifacts_num=>1,
              :uncalibrated_artifacts_num=>0, :max_team_size=>1
        expect(flash[:error]) =~ /Please choose either the number of reviews per student or the number of reviewers per team (student), not both./i
        expect(response).to redirect_to action: 'list_mappings', id: 1
      end
    end
  end

  describe '#automatic_review_mapping_staggered' do
    it 'shows a note flash message and redirects to review_mapping#list_mappings page' do
      expect(Assignment).to receive(:find).and_return(assignment)
      allow(assignment).to receive(:assign_reviewers_staggered).with(any_args).and_return("check")
      get :automatic_review_mapping_staggered, id: assignment.id, assignment: {num_reviews: '1', num_metareviews: '2'}
      expect(flash[:note]).to be_present
      expect(response).to redirect_to ('/review_mapping/list_mappings?id=' +assignment.id.to_s)
    end
  end

  describe 'response_report' do
    context 'when type is SummaryByRevieweeAndCriteria' do
      it 'renders response_report page with corresponding data' do
        expect(Assignment).to receive(:find).with(any_args).and_return(assignment)
        sum = double()
        expect(SummaryHelper::Summary).to receive_message_chain('new.summarize_reviews_by_reviewees').with(any_args).and_return(sum)
        summary = double()
        expect(sum).to receive(:summary).with(any_args).and_return(summary)
        reviewers = double()
        expect(sum).to receive(:reviewers).with(any_args).and_return(reviewers)
        avg_scores_by_reviewee = double()
        expect(sum).to receive(:avg_scores_by_reviewee).with(any_args).and_return(avg_scores_by_reviewee)
        avg_scores_by_round = double()
        expect(sum).to receive(:avg_scores_by_round).with(any_args).and_return(avg_scores_by_round)
        avg_scores_by_criterion = double()
        expect(sum).to receive(:avg_scores_by_criterion).with(any_args).and_return(avg_scores_by_criterion)
        params = double{ }
        params = {id: 1, report: {type: 'SummaryByRevieweeAndCriteria'}}
        get :response_report, params
        expect(response).to render_template('response_report')
      end
    end

    context 'when type is SummaryByCriteria' do
      it 'renders response_report page with corresponding data' do
        expect(Assignment).to receive(:find).with(any_args).and_return(assignment)
        sum = double()
        expect(SummaryHelper::Summary).to receive_message_chain('new.summarize_reviews_by_criterion').with(any_args).and_return(sum)
        summary = double()
        expect(sum).to receive(:summary).with(any_args).and_return(summary)
        avg_scores_by_round = double()
        expect(sum).to receive(:avg_scores_by_round).with(any_args).and_return(avg_scores_by_round)
        avg_scores_by_criterion = double()
        expect(sum).to receive(:avg_scores_by_criterion).with(any_args).and_return(avg_scores_by_criterion)
        params = double{ }
        params = {id: 1, report: {type: 'SummaryByCriteria'}}
        get :response_report, params
        expect(response).to render_template('response_report')
      end
    end

    context 'when type is ReviewResponseMap' do
      it 'renders response_report page with corresponding data' do
        expect(Assignment).to receive(:find).with(any_args).and_return(assignment)
        reviewers = double()
        expect(ReviewResponseMap).to receive(:review_response_report).with(any_args).and_return(reviewers)
        review_scores = double()
        expect(assignment).to receive(:compute_reviews_hash).with(any_args).and_return(review_scores)
        avg_and_ranges = double()
        expect(assignment).to receive(:compute_avg_and_ranges_hash).with(any_args).and_return(avg_and_ranges)
        params = double{ }
        params = {id: 1, report: {type: 'ReviewResponseMap'}, user: 1}
        get :response_report, params
        expect(response).to render_template('response_report')
      end
    end

    context 'when type is FeedbackResponseMap' do
      context 'when assignment has varying_rubrics_by_round feature' do
        it 'renders response_report page with corresponding data' do
          expect(Assignment).to receive(:find).with(any_args).and_return(assignment)
          expect(assignment).to receive(:varying_rubrics_by_round?).with(any_args).and_return(true)
          expect(assignment).to receive(:varying_rubrics_by_round?).with(any_args).and_return(true)
          expect(assignment).to receive(:varying_rubrics_by_round?).with(any_args).and_return(true)
          params = double{ }
          params = {id: 1, report: {type: 'FeedbackResponseMap'}}
          get :response_report, params
          expect(response).to render_template('response_report')
        end
      end

      context 'when assignment does not have varying_rubrics_by_round feature' do
        it 'renders response_report page with corresponding data' do
          expect(Assignment).to receive(:find).with(any_args).and_return(assignment)
          expect(assignment).to receive(:varying_rubrics_by_round?).with(any_args).and_return(false)
          expect(assignment).to receive(:varying_rubrics_by_round?).with(any_args).and_return(false)
          expect(assignment).to receive(:varying_rubrics_by_round?).with(any_args).and_return(false)
          params = double{ }
          params = {id: 1, report: {type: 'FeedbackResponseMap'}}
          get :response_report, params
          expect(response).to render_template('response_report')
        end
      end
    end

    context 'when type is TeammateReviewResponseMap' do
      it 'renders response_report page with corresponding data' do
        expect(Assignment).to receive(:find).with(any_args).and_return(assignment)
        reviewers = double()
        expect(TeammateReviewResponseMap).to receive(:teammate_response_report).with(any_args).and_return(reviewers)
        params = double{ }
        params = {id: 1, report: {type: 'TeammateReviewResponseMap'}}
        get :response_report, params
        expect(response).to render_template('response_report')
      end
    end

    context 'when type is Calibration and participant variable is nil' do
      it 'renders response_report page with corresponding data' do
        expect(Assignment).to receive(:find).with(any_args).and_return(assignment)
        expect(AssignmentParticipant).to receive_message_chain('where.first').with(any_args).and_return(participant)
        allow(participant).to receive(:nil?).with(any_args).and_return(true)
        expect(AssignmentParticipant).to receive(:create).with(any_args).and_return(participant)
        assignment_questionnaire = double()
        expect(AssignmentQuestionnaire).to receive_message_chain('where.first').with(any_args).and_return(assignment_questionnaire)
        questions = double()
        expect(assignment_questionnaire).to receive_message_chain('questionnaire.questions.select').with(any_args).and_return(questions)
        calibration_response_maps = double()
        expect(ReviewResponseMap).to receive(:where).with(any_args).and_return(calibration_response_maps)
        responses = double()
        expect(Response).to receive(:where).with(any_args).and_return(responses)
        params = double{ }
        params = {id: 1, report: {type: 'Calibration'}}
        session[:user] = user
        get :response_report, params, session
        expect(response).to render_template('response_report')
      end
    end

    context 'when type is PlagiarismCheckerReport' do
      it 'renders response_report page with corresponding data' do
        expect(Assignment).to receive(:find).with(any_args).and_return(assignment)
        plagiarism_checker_comparisons = double()
        expect(PlagiarismCheckerComparison).to receive(:where).with(any_args).and_return(plagiarism_checker_comparisons)
        params = double{ }
        params = {id: 1, report: {type: 'PlagiarismCheckerReport'}}
        session[:user] = user
        get :response_report, params, session
        expect(response).to render_template('response_report')
      end
    end
  end

  describe '#save_grade_and_comment_for_reviewer' do
    it 'redirects to review_mapping#response_report page' do
      review_grade = double()
      expect(ReviewGrade).to receive(:find_by).with(any_args).and_return(review_grade)
      allow(review_grade).to receive(:nil?).and_return(false)
      allow(review_grade).to receive(:grade_for_reviewer=).with(any_args)
      allow(review_grade).to receive(:comment_for_reviewer=).with(any_args)
      allow(review_grade).to receive(:review_graded_at=).with(any_args)
      allow(review_grade).to receive(:reviewer_id=).with(any_args)
      allow(review_grade).to receive(:save)
      allow_any_instance_of(ApplicationController).to receive(:session).and_return( user: user )
      get :save_grade_and_comment_for_reviewer, :assignment_id => 1
      expect(response).to redirect_to controller: 'review_mapping', action: 'response_report', id:1
    end
  end

  describe '#start_self_review' do
    context 'when self review response map does not exist' do
      it 'creates a new record and redirects to submitted_content#edit page' do
        expect(Assignment).to receive(:find).and_return(assignment)
        expect(TeamsUser).to receive(:find_by_sql).and_return('1')
        self_resp = double()
        get :start_self_review
        expect(response.location).to match(%r"http://test.host/submitted_content/edit.*")
      end
    end

    context 'when self review response map exists' do
      it 'redirects to submitted_content#edit page' do
        expect(Assignment).to receive(:find).and_return(assignment)
        expect(TeamsUser).to receive(:find_by_sql).and_return('1')
        self_resp = double()
        #expect(SelfReviewResponseMap).to receive_message_chain("where.first").with(any_args).and_return(self_resp)
        #expect(self_resp).to receive(:nil?).and_return(false).and_raise("Self review already assigned!")
        get :start_self_review
        #expect(response).to redirect_to controller: 'submitted_content', action: 'edit'
        expect(response.location).to match(%r"http://test.host/submitted_content/edit.*")
      end
    end
  end
end

