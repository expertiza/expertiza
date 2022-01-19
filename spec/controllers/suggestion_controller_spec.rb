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
  let(:student) { build(:student, id: 1)}
  let(:questionnaire) { build(:questionnaire, id: 666) }
  let(:suggestion){build(:suggestion, id: 1)}
  let(:comment){build(:comment)}
  let(:assignment_questionnaire) { build(:assignment_questionnaire, id: 1, questionnaire: questionnaire) }
  let(:suggestion_comment) {build(:suggestion_comment)}

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Suggestion).to receive(:find).with('1').and_return(suggestion)

  end

  describe '#student_view' do
    it 'renders suggestions#student_view' do
      stub_current_user(student, student.role.name, student.role)
      get :student_view, id: 1
      expect(response).to render_template(:student_view)
    end
  end

  describe '#student_edit' do
      it 'renders suggestions#student_edit' do
        stub_current_user(student, student.role.name, student.role)
        get :student_edit, id: 1
        expect(response).to render_template(:student_edit)
      end
  end

  describe '#update_suggestion' do
    it "checks updated is saved" do
      allow(Suggestion).to receive(:find).and_return(suggestion)
      params = {id: 1,suggestion:{title:'new title', description: 'new description', signup_preference:'N'} }
      post :update_suggestion, params
      expect(response).to render_template('suggestion/new?id=1')
    end
  end



  describe '#add_comment' do
    it 'adds a participant' do
      allow(Assignment).to receive(:find).with('1').and_return(assignment)
      allow(User).to receive(:find_by).with(name: student.name).and_return(student)
      allow(SuggestionComment).to receive(:new).and_return(suggestion_comment)
      allow_any_instance_of(SuggestionComment).to receive(:save).and_return(true)
      params = { id:1, comment:{vote:"Y", comments:"comments"}}
      session = {user: instructor}
      xhr :get, :add_comment, params, session
      expect(flash[:notice]).to eq 'Your comment has been successfully added.'
    end
  end

  describe '#reject_suggestion' do
    it 'reject a suggestion' do
      allow(Suggestion).to receive(:find).and_return(suggestion)
      allow_any_instance_of(Suggestion).to receive(:update_attributes).and_return(true)
      get :reject_suggestion, id: 1
      expect(flash[:notice]).to eq 'The suggestion has been successfully rejected.'
    end
  end
end