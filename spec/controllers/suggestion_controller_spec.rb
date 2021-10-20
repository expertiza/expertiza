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
  let(:suggestion){build(:suggestion)}
  let(:assignment_questionnaire) { build(:assignment_questionnaire, id: 1, questionnaire: questionnaire) }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Suggestion).to receive(:find).with('1').and_return(suggestion)
    stub_current_user(student, student.role.name, student.role)
  end

  describe '#student_view' do
    it 'renders suggestions#student_view' do
      get :student_view, id: 1
      expect(response).to render_template(:student_view)
    end
  end

  describe '#student_edit' do
      it 'renders suggestions#student_edit' do
        get :student_edit, id: 1
        expect(response).to render_template(:student_edit)
      end
  end

  describe '#update_suggestion' do
    it "checks updated is saved" do
      params = {id: 1,suggestion:{title:"new title", description: "new description", signup_preference:"N"} }
      post :update_suggestion, params
      expect(response).to render_template('suggestion/new?id=1')
    end
  end

  describe '#create' do
    let(:comment) { double('OODD', instructor_id: 2, path: '/cs', name: 'xyz') }
    before(:each) do
      allow(Course).to receive(:new).and_return(course_double)
      allow(course_double).to receive(:save).and_return(true)
    end

    it "redirects to the correct url" do
      post :create
      expect(response).to redirect_to root_url
    end
  end

  # describe '#add' do
  #   it 'adds a participant' do
  #     allow(Assignment).to receive(:find).with('1').and_return(assignment)
  #     allow(User).to receive(:find_by).with(name: student.name).and_return(student)
  #     params = {model: 'Assignment', authorization: 'participant', id: 1, user: {name: student.name}}
  #     session = {user: instructor}
  #     xhr :get, :add, params, session
  #     expect(response).to render_template('add.js.erb')
  #   end
  #   it 'does not add a participant for a non-existing user' do
  #     allow(Assignment).to receive(:find).with('1').and_return(assignment)
  #     params = {model: 'Assignment', authorization: 'participant', id: 1, user: {name: 'Aaa'}}
  #     session = {user: instructor}
  #     xhr :get, :add, params, session
  #     expect(flash[:error]).to eq 'The user <b>Aaa</b> does not exist or has already been added.'
  #     expect(response).to render_template('add.js.erb')
  #   end
  # end

end