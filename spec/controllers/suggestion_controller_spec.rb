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
  let(:suggestion1){build(:suggestion, id:1, assignment_id:1,title:'oss topic', description:'add oss topic', status:'Initiated', unityID:'student2065',signup_preference:'Y')}
  let(:assignment_questionnaire) { build(:assignment_questionnaire, id: 1, questionnaire: questionnaire) }

  before(:each) do
    stub_current_user(student, student.role.name, student.role)
  end
  describe '#student_view' do
    it 'renders assignments#student_view' do
      get :student_view, id: 1
      expect(response).to render_template(:student_view)
    end
  end
end