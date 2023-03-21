describe ResponseController do
  let(:assignment) { build(:assignment, instructor_id: 6, id: 1) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:participant) { build(:participant, id: 1, user_id: 6, assignment: assignment) }
  let(:review_response) { build(:response, id: 1, map_id: 1) }
  let(:review_response_round1) { build(:response, id: 1, map_id: 1, round: 1, is_submitted: 0) }
  let(:review_response_map) { build(:review_response_map, id: 1, reviewer: participant) }
  let(:questionnaire) { build(:questionnaire, id: 1, questions: [question]) }
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire) }
  let(:answer) { double('Answer') }
  let(:assignment_due_date) { build(:assignment_due_date) }
  let(:bookmark) { build(:bookmark) }
  let(:team_response) { build(:response, id: 2, map_id: 2) }
  let(:team_response_map) { build(:review_response_map, id: 2, reviewer: participant, team_reviewing_enabled: true) }
  let(:team_questionnaire) { build(:questionnaire, id: 2) }
  let(:team_assignment) { build(:assignment, id: 2) }
  let(:assignment_team) { build(:assignment_team, id: 1) }
  let(:signed_up_team) { build(:signed_up_team, team_id: assignment_team.id) }
  let(:assignment_form) { AssignmentForm.new }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)

    allow(Assignment).to receive(:find).with('2').and_return(team_assignment)
    allow(Assignment).to receive(:find).with(2).and_return(team_assignment)

    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(Response).to receive(:find).with('1').and_return(review_response)
    allow(Response).to receive(:find).with(1).and_return(review_response)

    allow(Response).to receive(:find).with('2').and_return(team_response)
    allow(Response).to receive(:find).with(2).and_return(team_response)

    allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
    allow(review_response).to receive(:map).and_return(review_response_map)

    allow(team_response).to receive(:map).and_return(team_response_map)
    allow(SignedUpTeam).to receive(:find_by).with(team_id: assignment_team.id).and_return(signed_up_team)
  end

  describe '#action_allowed?' do
    context 'when request_params action is edit' do
      before(:each) do
        controller.params = { id: '1', action: 'edit' }
      end

      context 'when response is not submitted and current_user is the reviewer of the response' do
        it 'allows certain action' do
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when response is submitted' do
        it 'does not allow certain action' do
          allow(review_response).to receive(:is_submitted).and_return(true)
          expect(controller.send(:action_allowed?)).to be false
        end
      end
    end

    context 'when request_params action is delete or update' do
      context 'when current_user is the reviewer of the response' do
        it 'allows certain action' do
          controller.params = { id: '1', action: 'update' }
          expect(controller.send(:action_allowed?)).to be true
        end
      end
    end

    context 'when request_params action is view' do
      context 'when response_map is a ReviewResponseMap and current user is the instructor of current assignment' do
        it 'allows certain action' do
          controller.params = { id: '1', action: 'view' }
          expect(controller.send(:action_allowed?)).to be true
        end
      end
    end
  end

  describe '#delete' do
    it 'deletes current response and redirects to response#redirect page' do
      allow(review_response).to receive(:delete).and_return(review_response)
      request_params = { id: 1 }
      post :delete, params: request_params
      expect(response).to redirect_to('/response/redirect?id=1&msg=The+response+was+deleted.')
    end

    it 'Redirects away if another user has a lock on the resource' do
      allow(team_response).to receive(:delete).and_return(team_response)
      allow(Lock).to receive(:get_lock).and_return(nil)
      request_params = { id: 2 }
      post :delete, params: request_params
      expect(response).not_to redirect_to('/response/redirect?id=2&msg=The+response+was+deleted.')
    end
  end

  describe '#edit' do
    it 'renders response#response page' do
      allow(Response).to receive(:where).with(map_id: 1).and_return([review_response])
      allow(ResponseMap).to receive(:find).with(1).and_return(review_response_map)
      allow(review_response_map).to receive(:reviewer_id).and_return(1)
      allow(Participant).to receive(:find).with(1).and_return(participant)
      allow(assignment).to receive(:review_questionnaire_id).and_return(1)
      allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire)
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, questionnaire_id: 1).and_return([assignment_questionnaire])
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1).and_return([assignment_questionnaire])
      allow(Answer).to receive(:where).with(response_id: 1, question_id: 1).and_return([answer])
      request_params = { id: 1, return: 'assignment_edit' }
      get :edit, params: request_params
      expect(controller.instance_variable_get(:@review_scores)).to eq([answer])
      expect(controller.instance_variable_get(:@dropdown_or_scale)).to eq('dropdown')
      expect(controller.instance_variable_get(:@min)).to eq(0)
      expect(controller.instance_variable_get(:@max)).to eq(5)
      expect(response).to render_template(:response)
    end

    it 'does not render the page if the user does not have a lock on the response' do
      allow(Lock).to receive(:get_lock).and_return(nil)
      request_params = { id: 2, return: 'assignment_edit' }
      get :edit, params: request_params
      expect(response).not_to render_template(:response)
    end
  end

  describe '#update' do
    context 'when something is wrong during response updating' do
      it 'raise an error and redirects to response#save page' do
        allow(review_response).to receive(:update_attribute).with('additional_comment', 'some comments').and_raise('ERROR!')
        request_params = {
          id: 1,
          review: {
            comments: 'some comments'
          }
        }
        user_session = { user: instructor }
        post :update, params: request_params, session: user_session
        expect(response).to redirect_to('/response/save?id=1&msg=Your+response+was+not+saved.+Cause%3A189+ERROR%21')
      end

      it 'Does not allow a user to update a response if a lock exists on the response' do
        allow(ResponseMap).to receive(:find).with(2).and_return(team_response_map)
        allow(Lock).to receive(:get_lock).and_return(nil)
        request_params = {
          id: 2,
          review: {
            comments: 'some comments'
          },
          responses: {
            '0' => { score: 98, comment: 'LGTM' }
          },
          isSubmit: 'No'
        }
        user_session = { user: instructor }
        post :update, params: request_params, session: user_session
        expect(response).not_to redirect_to('/response/save?id=1&msg=')
      end
    end

    context 'when response is updated successfully' do
      it 'redirects to response#save page' do
        allow(ResponseMap).to receive(:find).with(1).and_return(review_response_map)
        allow(review_response_map).to receive(:reviewer_id).and_return(1)
        allow(review_response_map).to receive(:assignment).and_return(assignment)
        allow(Participant).to receive(:find).with(1).and_return(participant)
        allow(participant).to receive(:assignment).and_return(assignment)
        allow(assignment).to receive(:review_questionnaire_id).and_return(1)
        allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire)
        allow(Answer).to receive(:create).with(response_id: 1, question_id: 1, answer: '98', comments: 'LGTM').and_return(answer)
        allow(answer).to receive(:update_attribute).with(any_args).and_return('OK!')
        request_params = {
          id: 1,
          review: {
            comments: 'some comments'
          },
          responses: {
            '0' => { score: 98, comment: 'LGTM' }
          },
          isSubmit: 'No'
        }
        user_session = { user: instructor }
        post :update, params: request_params, session: user_session
        expect(response).to redirect_to('/response/save?id=1&msg=')
      end
    end
  end

  describe '#new' do
    it 'renders response#response page' do
      allow(AssignmentForm).to receive(:create_form_object).with(1).and_return(assignment_form)
      allow(assignment_form).to receive(:assignment_questionnaire).with('ReviewQuestionnaire', 1, 1).and_return(assignment_questionnaire)
      allow(SignedUpTeam).to receive(:where).with(team_id: 1, is_waitlisted: 0).and_return([double('SignedUpTeam', topic_id: 1)])
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      allow(AssignmentDueDate).to receive(:find_by).with(any_args).and_return(assignment_due_date)
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, questionnaire_id: 1).and_return([assignment_questionnaire])
      request_params = {
        id: 1,
        feedback: '',
        return: ''
      }
      get :new, params: request_params
      expect(controller.instance_variable_get(:@dropdown_or_scale)).to eq('dropdown')
      expect(controller.instance_variable_get(:@min)).to eq(0)
      expect(controller.instance_variable_get(:@max)).to eq(5)
      expect(response).to render_template(:response)
    end
  end

  describe '#new_feedback' do
    context 'when current response is nil' do
      it 'redirects to response#new page' do
        allow(AssignmentParticipant).to receive(:where).with(user_id: 6, parent_id: 1).and_return([participant])
        allow(FeedbackResponseMap).to receive(:where).with(reviewed_object_id: 1, reviewer_id: 1).and_return([])
        request_params = { id: 1 }
        user_session = { user: instructor }
        get :new_feedback, params: request_params, session: user_session
        expect(response).to redirect_to('/response/new?id=2&return=feedback')
      end
    end

    context 'when current response is not nil' do
      it 'redirects to previous page' do
        allow(Response).to receive(:find).with('2').and_return(nil)
        request_params = { id: 2 }
        user_session = { user: instructor }
        request.env['HTTP_REFERER'] = 'www.google.com'
        get :new_feedback, params: request_params, session: user_session
        expect(response).to redirect_to('www.google.com')
      end
    end
  end

  describe '#view' do
    it 'renders response#view page' do
      allow(Response).to receive(:where).with(map_id: 1).and_return([review_response])
      allow(ResponseMap).to receive(:find).with(1).and_return(review_response_map)
      allow(review_response_map).to receive(:reviewer_id).and_return(1)
      allow(Participant).to receive(:find).with(1).and_return(participant)
      allow(assignment).to receive(:review_questionnaire_id).and_return(1)
      allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire)
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, questionnaire_id: 1).and_return([assignment_questionnaire])
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1).and_return([assignment_questionnaire])
      allow(Answer).to receive(:where).with(response_id: 1, question_id: 1).and_return([answer])
      request_params = { id: 1, return: 'assignment_edit' }
      get :view, params: request_params
      expect(controller.instance_variable_get(:@dropdown_or_scale)).to eq('dropdown')
      expect(controller.instance_variable_get(:@min)).to eq(0)
      expect(controller.instance_variable_get(:@max)).to eq(5)
      expect(response).to render_template(:view)
    end
  end

  describe '#create' do
    it 'creates a new response and redirects to response#save page' do
      allow(ResponseMap).to receive(:find).with('1').and_return(review_response_map)
      allow(Response).to receive_message_chain(:where, :order).with(map_id: 1, round: 1).with(created_at: :desc).and_return([review_response_round1])
      allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
      allow(Answer).to receive(:create).with(response_id: 1, question_id: 1, answer: '98', comments: 'LGTM').and_return(answer)
      allow(answer).to receive(:update_attribute).with(any_args).and_return('OK!')
      allow_any_instance_of(Response).to receive(:email).and_return('OK!')
      request_params = {
        id: 1,
        review: {
          questionnaire_id: '1',
          round: 1,
          comments: 'no comment'
        },
        responses: {
          '0' => { score: 98, comment: 'LGTM' }
        },
        isSubmit: 'No'
      }
      post :create, params: request_params
      expect(response).to redirect_to('/response/save?error_msg=&id=1&msg=Your+response+was+successfully+saved.')
    end
  end

  describe '#save' do
    it 'save current response map and redirects to response#redirect page' do
      allow(ResponseMap).to receive(:find).with('1').and_return(review_response_map)
      allow(review_response_map).to receive(:save).and_return(review_response_map)
      request_params = {
        id: 1,
        return: ''
      }
      user_session = { user: instructor }
      post :save, params: request_params, session: user_session
      expect(response).to redirect_to('/response/redirect?id=1&return=')
    end
  end

  describe '#send_email' do
      it 'should redirect to same page if no subject' do
        request_params = { 
          send_email:{
            subject: '',
            email_body: 'Hello',
            response:9320,
            email:'expertiza.debugging@gmail.com' 
          }
        }
        
        post :send_email, params: request_params

        expect(flash[:error]).to eq('Please fill in the subject and the email content.')
        expect(response).to redirect_to ('/response/author')
     
      end
  end
  
  describe '#send_email' do
      it 'should redirect to same page if no body' do
        request_params = { 
          send_email:{
            subject: 'Hello',
            email_body: '',
            response:9320,
            email:'expertiza.debugging@gmail.com' 
          }
        }
        
        post :send_email, params: request_params

        expect(flash[:error]).to eq('Please fill in the subject and the email content.')
        expect(response).to redirect_to ('/response/author')
     
      end
  end

  describe '#send_email' do
      it 'should redirect to student task list on success' do
        request_params = { 
          send_email:{
            subject: 'Hello',
            email_body: 'Hi',
            response:9320,
            email:'expertiza.debugging@gmail.com' 
          }
        }
        
        post :send_email, params: request_params

        expect(flash[:success]).to eq('Email sent to the author.')
        expect(response).to redirect_to ('/student_task/list')
     
      end
  end

  describe '#send_email' do
      it 'should redirect to same page if no body or subject' do
        request_params = { 
          send_email:{
            subject: '',
            email_body: '',
            response:9320,
            email:'expertiza.debugging@gmail.com' 
          }
        }
        
        post :send_email, params: request_params

        expect(flash[:error]).to eq('Please fill in the subject and the email content.')
        expect(response).to redirect_to ('/response/author')
     
      end
  end

  describe '#redirect' do
    before(:each) do
      allow(Response).to receive(:find_by).with(map_id: '1').and_return(review_response)
      @request_params = { id: 1 }
    end

    context 'when request_params[:return] is bookmark' do
      it 'redirects to bookmarks#list page' do
        allow(Bookmark).to receive(:find).with(1).and_return(bookmark)
        @request_params[:return] = 'bookmark'
        get :redirect, params: @request_params
        expect(response).to redirect_to('/bookmarks/list?id=1')
      end
    end

    context 'when request_params[:return] is feedback' do
      it 'redirects to grades#view_my_scores page' do
        @request_params[:return] = 'feedback'
        get :redirect, params: @request_params
        expect(response).to redirect_to('/grades/view_my_scores?id=1')
      end
    end

    context 'when request_params[:return] is teammate' do
      it 'redirects to student_teams#view page' do
        @request_params[:return] = 'teammate'
        get :redirect, params: @request_params
        expect(response).to redirect_to('/student_teams/view?student_id=1')
      end
    end

    context 'when request_params[:return] is instructor' do
      it 'redirects to grades#view page' do
        @request_params[:return] = 'instructor'
        get :redirect, params: @request_params
        expect(response).to redirect_to('/grades/view?id=1')
      end
    end

    context 'when request_params[:return] is assignment_edit' do
      it 'redirects to assignment#edit page' do
        @request_params[:return] = 'assignment_edit'
        get :redirect, params: @request_params
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end

    context 'when request_params[:return] is selfreview' do
      it 'redirects to submitted_content#edit page' do
        @request_params[:return] = 'selfreview'
        get :redirect, params: @request_params
        expect(response).to redirect_to('/submitted_content/1/edit')
      end
    end

    context 'when request_params[:return] is survey' do
      it 'redirects to response#pending_surveys page' do
        @request_params[:return] = 'survey'
        get :redirect, params: @request_params
        expect(response).to redirect_to('/survey_deployment/pending_surveys')
      end
    end

    context 'when request_params[:return] is other content' do
      it 'redirects to student_review#list page' do
        @request_params[:return] = 'other'
        get :redirect, params: @request_params
        expect(response).to redirect_to('/student_review/list?id=1')
      end
    end
  end
end
