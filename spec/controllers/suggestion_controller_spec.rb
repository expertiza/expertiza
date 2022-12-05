describe SuggestionController do
  let(:assignment) do
    build(:assignment, id: 1, name: 'test assignment', instructor_id: 6, staggered_deadline: true, directory_path: 'same path',
                       participants: [build(:participant)], teams: [build(:assignment_team)], course_id: 1, allow_suggestions: 1)
  end
  let(:assignment_form) { double('AssignmentForm', assignment: assignment) }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:instructor2) { build(:instructor, id: 66) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:student) { build(:student, id: 1) }
  let(:questionnaire) { build(:questionnaire, id: 666) }
  let(:suggestion) { build(:suggestion, id: 1, assignment_id: 1) }
  let(:comment) { build(:comment) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire, id: 1, questionnaire: questionnaire) }
  let(:suggestion_comment) { build(:suggestion_comment) }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Suggestion).to receive(:find).with('1').and_return(suggestion)
  end

  describe '#student_view' do
    it 'renders suggestions#student_view' do
      stub_current_user(student, student.role.name, student.role)
      get :student_view, params: { id: 1 }
      expect(response).to render_template(:student_view)
    end
  end

  describe '#student_edit' do
    it 'renders suggestions#student_edit' do
      stub_current_user(student, student.role.name, student.role)
      get :student_edit, params: { id: 1 }
      expect(response).to render_template(:student_edit)
    end
  end

  describe '#update' do
    it 'checks updated is saved and redirect to the new' do
      allow(Suggestion).to receive(:find).and_return(suggestion)
      allow_any_instance_of(Suggestion).to receive(:update_attributes).and_return(true)
      allow_any_instance_of(SuggestionController).to receive(:current_user_has_student_privileges?).and_return(true)
      request_params = { id: 1, suggestion: { title: 'new title', description: 'new description', signup_preference: 'N' } }
      user_session = { user: instructor }
      post :update, params: request_params, session: user_session
      expect(response).to redirect_to('/suggestion/new?id=1')
    end
  end

  describe '#add_comment' do
    it 'adds a participant is succesfull' do
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      allow(User).to receive(:find_by).with(name: student.name).and_return(student)
      allow(SuggestionComment).to receive(:new).and_return(suggestion_comment)
      allow_any_instance_of(SuggestionComment).to receive(:save).and_return(true)
      request_params = { id: 1, suggestion_comment: { vote: 'Y', comments: 'comments' } }
      user_session = { user: instructor }
      get :add_comment, params: request_params, session: user_session, xhr: true
      expect(flash[:notice]).to eq 'Your comment has been successfully added.'
    end
    it 'adds a participant is not successfull' do
      allow_any_instance_of(SuggestionComment).to receive(:save).and_return(false)
      request_params = { id: 1, suggestion_comment: { vote: 'Y', comments: 'comments' } }
      user_session = { user: instructor }
      get :add_comment, params: request_params, session: user_session, xhr: true
      expect(flash[:error]).to eq 'There was an error in adding your comment.'
    end
  end

  describe '#submit' do
    context 'when you want to reject a suggestion' do
      it 'rejecting a suggestion is succesfull' do
        allow(Suggestion).to receive(:find).and_return(suggestion)
        allow_any_instance_of(Suggestion).to receive(:update_attribute).and_return(true)
        request_params = { id: 1, reject: true }
        user_session = { user: instructor }
        get :submit, params: request_params, session: user_session, xhr: true
        expect(flash[:notice]).to eq 'The suggestion has been successfully rejected.'
      end
      it 'rejecting a suggestion is not successfull' do
        allow_any_instance_of(Suggestion).to receive(:update_attribute).and_return(false)
        request_params = { id: 1, reject: true }
        user_session = { user: instructor }
        get :submit, params: request_params, session: user_session, xhr: true
        expect(flash[:error]).to eq 'An error occurred when rejecting the suggestion.'
      end
    end
    context 'when you want to accept a suggestion' do
      it 'accept a suggestion is succesfull' do
        allow(Suggestion).to receive(:find).and_return(suggestion)
        allow(User).to receive(:find_by).and_return(instructor)
        allow(TeamsUser).to receive(:team_id).and_return(1)
        allow(SignedUpTeam).to receive(:topic_id).and_return(1)
        allow(SignUpTopic).to receive(:new_topic_from_suggestion).and_return(true)
        allow_any_instance_of(SuggestionController).to receive(:notify_suggester).and_return(true)
        request_params = { id: 1, approve_suggestion: true }
        user_session = { user: instructor }
        get :submit, params: request_params, session: user_session, xhr: true
        expect(flash[:success]).to eq 'The suggestion was successfully approved.'
      end
      it 'accept a suggestion is not successfull' do
        allow(SignUpTopic).to receive(:new_topic_from_suggestion).and_return('failed')
        allow_any_instance_of(SuggestionController).to receive(:notify_suggester).and_return(true)
        request_params = { id: 1, approve_suggestion: true }
        user_session = { user: instructor }
        get :submit, params: request_params, session: user_session, xhr: true
        expect(flash[:error]).to eq 'An error occurred when approving the suggestion.'
      end
    end
  end
end
