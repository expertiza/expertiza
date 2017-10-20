describe ResponseController do
  success_response = Net::HTTPResponse.new(1.0, 200, "OK")
  current_round = 1
  stage = nil
  let(:assignment) { build(:assignment, instructor_id: 6) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:participant) { build(:participant, id: 1, user_id: 6, assignment: assignment) }
  let(:review_response) { build(:response, id: 1, map_id: 1) }
  let(:review_response_map) { build(:review_response_map, id: 1, reviewer: participant) }
  let(:questionnaire) { build(:questionnaire, id: 1, questions: [question]) }
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire) }
  let(:answer) { double('Answer') }
  let(:assignment_due_date) { build(:assignment_due_date) }

  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Assignment).to receive(:find).and_return(assignment)
    allow(Response).to receive(:find).with('1').and_return(review_response)
    allow(Response).to receive(:find_by_map_id).and_return(review_response)
    allow(Response).to receive(:find).and_return(review_response)
    allow(ResponseMap).to receive(:find).with('1').and_return(review_response_map)
    allow(ResponseMap).to receive(:find).with(1).and_return(review_response_map)
    allow(Participant).to receive(:find).with(1).and_return(participant)
    allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
    allow(assignment).to receive(:number_of_current_round).and_return(current_round)
    allow(assignment).to receive(:get_current_stage).and_return(stage)
    allow(review_response).to receive(:delete).and_return(success_response)
    allow(review_response).to receive(:map).and_return(review_response_map)
    allow(review_response).to receive(:questionnaire_by_answer).and_return(questionnaire)
    allow(review_response_map).to receive(:assignment).and_return(assignment)
    allow(review_response_map).to receive(:questionnaire).with(current_round).and_return(questionnaire)
    request.env['HTTP_REFERER'] = 'www.google.com'
  end

  describe '#action_allowed?' do
    context 'when params action is edit' do
      context 'when response is not submitted and current_user is the reviewer of the response' do
        it 'allows certain action' do
          params = {action: "edit", id: review_response.id}
          current_user = participant
          controller.params = params
          expect(controller.action_allowed?).to eq(true)
        end

      end

      context 'when response is submitted' do
        it 'does not allow certain action' do
          response = build(:response)
          response.is_submitted = true
          allow(Response).to receive(:find).and_return(response)
          params = {action: "edit", id: response.id}
          controller.params = params
          expect(controller.action_allowed?).to eq(false)
        end
      end
    end

    context 'when params action is delete or update' do
      context 'when current_user is the reviewer of the response' do
        it 'allows certain action' do
          params = {action: "delete", id: review_response.id}
          current_user = participant
          controller.params = params
          expect(controller.action_allowed?).to eq(true)

          params = {action: "update", id: review_response.id}
          current_user = participant
          controller.params = params
          expect(controller.action_allowed?).to eq(true)
        end
      end
    end

    context 'when params action is view' do
      context 'when response_map is a ReviewResponseMap and current user is the instructor of current assignment' do
        it 'allows certain action' do
          params = {action: "view", id: review_response.id}
          controller.params = params
          expect(controller.action_allowed?).to eq(true)
        end
      end
    end
  end

  describe '#delete' do
    it 'deletes current response and redirects to response#redirection page' do
      params = {id: review_response.id}
      delete :delete, params
      expect(response).to redirect_to('/response/redirection?id=' + review_response.id.to_s + '&msg=The+response+was+deleted.')
      expect(response).to have_http_status 302
    end
  end

  describe '#edit' do
    it 'renders response#response page' do
      params = {id: review_response.id, return: ''}
      post :edit, params
      expect(response).to render_template("response")
    end
  end

  describe '#update' do
    context 'when something is wrong during response updating' do
      it 'raise an error and redirects to response#saving page' do
        allow(review_response).to receive(:update_attribute).and_raise('wrong input')
        params = {id: review_response.id}
        put :update, params
        #fetching correct message embedded in response to check while redirection
        message = response["Location"].split("&msg=").last
        expect(response).to redirect_to('/response/saving?id=' + review_response.id.to_s + '&msg=' + message)
      end
    end

    context 'when response is updated successfully' do
      it 'redirects to response#saving page' do
        allow(review_response).to receive(:update_attribute).and_return(true)
        params = {id: review_response.id, :review => {:comments=>''}}
        put :update, params
        expect(response).to redirect_to('/response/saving?id=' + review_response.id.to_s + '&msg=')
      end
    end
  end

  describe '#new' do
    it 'renders response#response page' do
      params = {id: review_response.id, feedback: ''}
      post :new, params
      expect(response).to render_template("response")
    end
  end

  describe '#new_feedback' do
    context 'when current response is nil' do
      it 'redirects to response#new page' do
        session[:user] = participant
        params = {id: review_response.id}
        allow(AssignmentParticipant).to receive(:where).and_return([participant])
        allow(FeedbackResponseMap).to receive(:where).and_return([])
        get :new_feedback, params, session
        #fetching newly created map id in response to check while redirection
        id = response["Location"].split("?id=").last.split("&return").first
        expect(response).to redirect_to('/response/new?id=' + id + "&return=feedback")
      end

    end

    context 'when current response is not nil' do
      it 'redirects to previous page' do
        session[:user] = participant
        params = {id: review_response.id}
        allow(Response).to receive(:find).and_return(nil)
        get :new_feedback, params, session
        expect(response).to redirect_to(request.env['HTTP_REFERER'])
      end
    end
  end

  describe '#view' do
    it 'renders response#view page'  do
      params = {id: 1}
      get "view", params
      expect(response).to have_http_status(200)
      expect(response).to render_template('view')
    end
  end

  describe '#create' do
    it 'creates a new response and redirects to response#saving page'  do
      params = {id: review_response.id, review: {questionnaire_id: questionnaire.id}}
      post :create, params
      #fetching correct message embedded in response to check while redirection
      message = response["Location"].split("&msg=").last
      expect(response).to redirect_to(saving_response_index_url + "?error_msg=&id=" + review_response.id.to_s + "&msg=" + message)
    end
  end

  describe '#saving' do
    it 'save current response map and redirects to response#redirection page' do
      # params = {id: review_response_map.id}
      # get :saving, params
      # expect(response).to redirect_to('/response/redirection')
    end

  end

  describe '#redirection' do
    context 'when params[:return] is feedback' do
      it 'redirects to grades#view_my_scores page' do
        params = {return: "feedback"}
        get :redirection, params
        expect(response).to redirect_to('/grades/view_my_scores?id='+review_response.reviewer.id.to_s)
      end
    end

    context 'when params[:return] is teammate' do
      it 'redirects to student_teams#view page' do
        params = {return: "teammate"}
        get :redirection, params
        expect(response).to redirect_to('/student_teams/view?student_id='+review_response.reviewer.id.to_s)
      end
    end

    context 'when params[:return] is instructor' do
      it 'redirects to grades#view page' do
        params = {return: "instructor", id: 1}
        get :redirection, params
        expect(response).to redirect_to('/grades/view?id='+review_response.reviewer.id.to_s)
      end
    end

    context 'when params[:return] is assignment_edit' do
      it 'redirects to assignment#edit page' do
        params = {return: "assignment_edit"}
        get :redirection, params
        expect(response).to redirect_to('/assignments/'+review_response.reviewer.id.to_s + '/edit')
      end
    end

    context 'when params[:return] is selfreview' do
      it 'redirects to submitted_content#edit page' do
        params = {return: "selfreview"}
        get :redirection, params
        expect(response).to redirect_to('/submitted_content/'+review_response.reviewer.id.to_s + '/edit')
      end
    end

    context 'when params[:return] is survey' do
      it 'redirects to response#pending_surveys page' do
        params = {return: "survey"}
        get :redirection, params
        expect(response).to redirect_to('/response/pending_surveys')
      end
    end

    context 'when params[:return] is other content' do
      it 'redirects to student_review#list page'  do
        params = {return: "other"}
        get :redirection, params
        expect(response).to redirect_to('/student_review/list?id='+review_response.reviewer.id.to_s)
      end
    end
  end

  describe '#pending_surveys' do
    context 'when session[:user] is nil' do
      it 'redirects to root path (/)' do
      get "pending_surveys"
      expect(response).to redirect_to('/')
      end
    end

    context 'when session[:user] is not nil' do
      it 'renders pending_surveys page' do
        session[:user] = participant
        get "pending_surveys"
        expect(response).to have_http_status(200)
        expect(response).to render_template("pending_surveys")
      end

    end
  end
end
