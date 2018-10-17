describe ResponseController do
  let(:assignment) { build(:assignment, instructor_id: 6) }
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

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(Response).to receive(:find).with('1').and_return(review_response)
    allow(review_response).to receive(:map).and_return(review_response_map)
  end

  describe '#action_allowed?' do
    context 'when params action is edit' do
      before(:each) do
        controller.params = {id: '1', action: 'edit'}
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

    context 'when params action is delete or update' do
      context 'when current_user is the reviewer of the response' do
        it 'allows certain action' do
          controller.params = {id: '1', action: 'update'}
          expect(controller.send(:action_allowed?)).to be true
        end
      end
    end

    context 'when params action is view' do
      context 'when response_map is a ReviewResponseMap and current user is the instructor of current assignment' do
        it 'allows certain action' do
          controller.params = {id: '1', action: 'view'}
          expect(controller.send(:action_allowed?)).to be true
        end
      end
    end
  end

  describe '#delete' do
    it 'deletes current response and redirects to response#redirection page' do
      allow(review_response).to receive(:delete).and_return(review_response)
      params = {id: 1}
      post :delete, params
      expect(response).to redirect_to('/response/redirection?id=1&msg=The+response+was+deleted.')
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
      allow(Answer).to receive(:where).with(response_id: 1, question_id: 1).and_return([answer])
      params = {id: 1, return: 'assignment_edit'}
      get :edit, params
      expect(controller.instance_variable_get(:@review_scores)).to eq([answer])
      expect(controller.instance_variable_get(:@dropdown_or_scale)).to eq('dropdown')
      expect(controller.instance_variable_get(:@min)).to eq(0)
      expect(controller.instance_variable_get(:@max)).to eq(5)
      expect(response).to render_template(:response)
    end
  end

  describe '#update' do
    context 'when something is wrong during response updating' do
      it 'raise an error and redirects to response#saving page' do
        allow(review_response).to receive(:update_attribute).with('additional_comment', 'some comments').and_raise('ERROR!')
        params = {
          id: 1,
          review: {
            comments: 'some comments'
          }
        }
        session = {user: instructor}
        post :update, params, session
        expect(response).to redirect_to('/response/saving?id=1&msg=Your+response+was+not+saved.+Cause%3A189+ERROR%21&review%5Bcomments%5D=some+comments')
      end
    end

    context 'when response is updated successfully' do
      it 'redirects to response#saving page' do
        allow(ResponseMap).to receive(:find).with(1).and_return(review_response_map)
        allow(review_response_map).to receive(:reviewer_id).and_return(1)
        allow(Participant).to receive(:find).with(1).and_return(participant)
        allow(assignment).to receive(:review_questionnaire_id).and_return(1)
        allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire)
        allow(Answer).to receive(:create).with(response_id: 1, question_id: 1, answer: '98', comments: 'LGTM').and_return(answer)
        allow(answer).to receive(:update_attribute).with(any_args).and_return('OK!')
        params = {
          id: 1,
          review: {
            comments: 'some comments'
          },
          responses: {
            '0' => {score: 98, comment: 'LGTM'}
          },
          isSubmit: 'No'
        }
        session = {user: instructor}
        post :update, params, session
        expect(response).to redirect_to('/response/saving?id=1&msg=&review%5Bcomments%5D=some+comments')
      end
    end
  end

  describe '#new' do
    it 'renders response#response page' do
      allow(ResponseMap).to receive(:find).with('1').and_return(review_response_map)
      allow(SignedUpTeam).to receive(:where).with(team_id: 1, is_waitlisted: 0).and_return([double('SignedUpTeam', topic_id: 1)])
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      allow(AssignmentDueDate).to receive(:find_by).with(any_args).and_return(assignment_due_date)
      # varying_rubrics_by_round?
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 2).and_return([])
      # review_questionnaire_id
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1).and_return([assignment_questionnaire])
      # set_dropdown_or_scale
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, questionnaire_id: 1).and_return([assignment_questionnaire])
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 1).and_return([assignment_questionnaire])
      allow(Questionnaire).to receive(:find).with(any_args).and_return(questionnaire)
      allow(Questionnaire).to receive(:questions).and_return(question)
      allow(Answer).to receive(:create).and_return(answer)
      params = {
        id: 1,
        feedback: '',
        return: ''
      }
      get :new, params
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
        params = {id: 1}
        session = {user: instructor}
        get :new_feedback, params, session
        expect(response).to redirect_to('/response/new?id=2&return=feedback')
      end
    end

    context 'when current response is not nil' do
      it 'redirects to previous page' do
        allow(Response).to receive(:find).with('2').and_return(nil)
        params = {id: 2}
        session = {user: instructor}
        request.env['HTTP_REFERER'] = 'www.google.com'
        get :new_feedback, params, session
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
      allow(Answer).to receive(:where).with(response_id: 1, question_id: 1).and_return([answer])
      params = {id: 1, return: 'assignment_edit'}
      get :view, params
      expect(controller.instance_variable_get(:@dropdown_or_scale)).to eq('dropdown')
      expect(controller.instance_variable_get(:@min)).to eq(0)
      expect(controller.instance_variable_get(:@max)).to eq(5)
      expect(response).to render_template(:view)
    end
  end

  describe '#create' do
    it 'creates a new response and redirects to response#saving page' do
      allow(Response).to receive(:where).with(map_id: 1).and_return([review_response])
      allow(Response).to receive(:where).with(map_id: 1, round: 1).and_return([review_response_round1])
      allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
      allow(Answer).to receive(:create).with(response_id: 1, question_id: 1, answer: '98', comments: 'LGTM').and_return(answer)
      allow(answer).to receive(:update_attribute).with(any_args).and_return('OK!')
      allow_any_instance_of(Response).to receive(:email).and_return('OK!')
      params = {
        id: 1,
        review: {
          questionnaire_id: '1',
          round: 1,
          comments: 'no comment'
        },
        responses: {
          '0' => {score: 98, comment: 'LGTM'}
        },
        isSubmit: 'No'
      }
      post :create, params
      expect(response).to redirect_to('/response/saving?error_msg=&id=1&msg=Your+response+was+successfully+saved.&review%5Bcomments%5D=no+comment&review%5Bquestionnaire_id%5D=1&review%5Bround%5D=1')
    end
  end

  describe '#saving' do
    it 'save current response map and redirects to response#redirection page' do
      allow(ResponseMap).to receive(:find).with('1').and_return(review_response_map)
      allow(review_response_map).to receive(:save).and_return(review_response_map)
      params = {
        id: 1,
        return: ''
      }
      session = {user: instructor}
      post :saving, params, session
      expect(response).to redirect_to('/response/redirection?id=1&return=')
    end
  end

  describe '#redirection' do
    before(:each) do
      allow(Response).to receive(:find_by).with(map_id: '1').and_return(review_response)
      @params = {id: 1}
    end

    context 'when params[:return] is feedback' do
      it 'redirects to grades#view_my_scores page' do
        @params[:return] = 'feedback'
        get :redirection, @params
        expect(response).to redirect_to('/grades/view_my_scores?id=1')
      end
    end

    context 'when params[:return] is teammate' do
      it 'redirects to student_teams#view page' do
        @params[:return] = 'teammate'
        get :redirection, @params
        expect(response).to redirect_to('/student_teams/view?student_id=1')
      end
    end

    context 'when params[:return] is instructor' do
      it 'redirects to grades#view page' do
        @params[:return] = 'instructor'
        get :redirection, @params
        expect(response).to redirect_to('/grades/view?id=1')
      end
    end

    context 'when params[:return] is assignment_edit' do
      it 'redirects to assignment#edit page' do
        @params[:return] = 'assignment_edit'
        get :redirection, @params
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end

    context 'when params[:return] is selfreview' do
      it 'redirects to submitted_content#edit page' do
        @params[:return] = 'selfreview'
        get :redirection, @params
        expect(response).to redirect_to('/submitted_content/1/edit')
      end
    end

    context 'when params[:return] is survey' do
      it 'redirects to response#pending_surveys page' do
        @params[:return] = 'survey'
        get :redirection, @params
        expect(response).to redirect_to('/response/pending_surveys')
      end
    end

    context 'when params[:return] is other content' do
      it 'redirects to student_review#list page' do
        @params[:return] = 'other'
        get :redirection, @params
        expect(response).to redirect_to('/student_review/list?id=1')
      end
    end
  end

  describe '#pending_surveys' do
    context 'when session[:user] is nil' do
      it 'redirects to root path (/)' do
        params = {}
        session = {}
        get :pending_surveys, params, session
        expect(response).to redirect_to('/')
      end
    end

    context 'when session[:user] is not nil' do
      it 'renders pending_surveys page' do
        allow(CourseParticipant).to receive(:where).with(user_id: 6).and_return([double('CourseParticipant', id: 8, parent_id: 1)])
        allow(AssignmentParticipant).to receive(:where).with(user_id: 6).and_return([participant])
        survey_deployment = double('SurveyDeployment', id: 1, questionnaire_id: 1, global_survey_id: 1,
                                                       start_date: DateTime.now.in_time_zone - 1.day, end_date: DateTime.now.in_time_zone + 1.day)
        allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire)
        allow(CourseSurveyDeployment).to receive(:where).with(parent_id: 1).and_return([survey_deployment])
        participant.parent_id = 1
        allow(AssignmentSurveyDeployment).to receive(:where).with(parent_id: 1).and_return([survey_deployment])
        params = {}
        session = {user: instructor}
        get :pending_surveys, params, session
        expect(controller.instance_variable_get(:@surveys).size).to eq(2)
        expect(response).to render_template(:pending_surveys)
      end
    end
  end
end
