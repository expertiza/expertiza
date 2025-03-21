require 'rails_helper'

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
  let(:team_participant) { build(:teams_participant, id: 1, team_id: 1, participant_id: 1) }
  let(:team) { build(:team, id: 1) }
  let(:participant) { build(:participant, id: 1) }

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

  describe '#update_suggestion' do
    it 'checks updated is saved and redirect to the new' do
      allow(Suggestion).to receive(:find).and_return(suggestion)
      allow_any_instance_of(Suggestion).to receive(:update_attributes).and_return(true)
      allow_any_instance_of(SuggestionController).to receive(:current_user_has_student_privileges?).and_return(true)
      request_params = { id: 1, suggestion: { title: 'new title', description: 'new description', signup_preference: 'N' } }
      user_session = { user: instructor }
      post :update_suggestion, params: request_params, session: user_session
      expect(response).to redirect_to('/suggestion/new?id=1')
    end
  end

  describe '#add_comment' do
    it 'adds a participant' do
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      allow(User).to receive(:find_by).with(name: student.name).and_return(student)
      allow(SuggestionComment).to receive(:new).and_return(suggestion_comment)
      allow_any_instance_of(SuggestionComment).to receive(:save).and_return(true)
      request_params = { id: 1, suggestion_comment: { vote: 'Y', comments: 'comments' } }
      user_session = { user: instructor }
      get :add_comment, params: request_params, session: user_session, xhr: true
      expect(flash[:notice]).to eq 'Your comment has been successfully added.'
    end
  end

  describe '#submit' do
    context 'when you want to reject a suggestion' do
      it 'reject a suggestion' do
        allow(Suggestion).to receive(:find).and_return(suggestion)
        allow_any_instance_of(Suggestion).to receive(:update_attribute).and_return(true)
        request_params = { id: 1, reject_suggestion: true }
        user_session = { user: instructor }
        get :submit, params: request_params, session: user_session, xhr: true
        expect(flash[:notice]).to eq 'The suggestion has been successfully rejected.'
      end
    end
    context 'when you want to accept a suggestion' do
      it 'accept a suggestion' do
        allow(Suggestion).to receive(:find).and_return(suggestion)
        allow(User).to receive(:find_by).and_return(instructor)
        allow(TeamsUser).to receive(:team_id).and_return(1)
        allow(SignedUpTeam).to receive(:topic_id).and_return(1)
        allow(SignUpTopic).to receive(:new_topic_from_suggestion).and_return(true)
        allow_any_instance_of(SuggestionController).to receive(:notification).and_return(true)
        request_params = { id: 1, approve_suggestion: true }
        user_session = { user: instructor }
        get :submit, params: request_params, session: user_session, xhr: true
        expect(flash[:success]).to eq 'The suggestion was successfully approved.'
      end
    end
  end

  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'shows suggestion details' do
      allow(Suggestion).to receive(:find).with(1).and_return(build(:suggestion))
      allow(Team).to receive(:find).with(1).and_return(team)
      allow(TeamsParticipant).to receive(:where).with(team_id: 1).and_return([team_participant])
      get :show, params: { id: 1 }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    it 'creates a new suggestion' do
      post :create, params: { suggestion: { title: 'Test Suggestion', description: 'Test Description' } }
      expect(response).to redirect_to(suggestion_path(1))
    end
  end

  describe 'GET #edit' do
    it 'renders the edit template' do
      allow(Suggestion).to receive(:find).with(1).and_return(build(:suggestion))
      get :edit, params: { id: 1 }
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    it 'updates a suggestion' do
      allow(Suggestion).to receive(:find).with(1).and_return(build(:suggestion))
      patch :update, params: { id: 1, suggestion: { title: 'Updated Suggestion' } }
      expect(response).to redirect_to(suggestion_path(1))
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys a suggestion' do
      allow(Suggestion).to receive(:find).with(1).and_return(build(:suggestion))
      delete :destroy, params: { id: 1 }
      expect(response).to redirect_to(suggestions_path)
    end
  end

  describe 'GET #list' do
    it 'lists suggestions' do
      allow(Suggestion).to receive(:all).and_return([build(:suggestion)])
      get :list
      expect(response).to render_template(:list)
    end
  end

  describe 'GET #approve' do
    it 'approves a suggestion' do
      allow(Suggestion).to receive(:find).with(1).and_return(build(:suggestion))
      get :approve, params: { id: 1 }
      expect(response).to redirect_to(suggestion_path(1))
    end
  end

  describe 'GET #reject' do
    it 'rejects a suggestion' do
      allow(Suggestion).to receive(:find).with(1).and_return(build(:suggestion))
      get :reject, params: { id: 1 }
      expect(response).to redirect_to(suggestion_path(1))
    end
  end
end
