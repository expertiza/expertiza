describe AssignmentHelper do
  let(:assignment_helper) { Class.new { extend AssignmentHelper } }
  let(:questionnaire) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, scores: [answer]) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:team) { build(:assignment_team) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:questionnaire1) { build(:questionnaire, name: 'abc', private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234) }
  let(:contributor) { build(:assignment_team, id: 1) }
  let(:signed_up_team) { build(:signed_up_team, team_id: contributor.id) }
  let(:teaching_assistant) { build(:teaching_assistant, id: 1) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:admin) { build(:admin) }
  let(:course1) { build(:course, id: 1, name: 'ECE517') }
  let(:course2) { build(:course, id: 2, name: 'ECE506') }
  let(:course3) { build(:course, id: 3, name: 'ECE216') }
  let(:ta_mapping1) { build(:ta_mapping, id: 1, course_id: 1)}
  let(:ta_mapping2) { build(:ta_mapping, id: 2, course_id: 2)}
  describe '#questionnaire_options' do
    it 'throws exception if type argument nil' do
      expect { questionnaire_options(nil) }.to raise_exception(NoMethodError)
    end
  end
  describe '#course_options' do
    context 'when the user is a ta' do
      it 'gets courses associated with the TA' do
        allow(Ta).to receive(:find).and_return(teaching_assistant)
        allow(Course).to receive(:find).with(1).and_return(course1)
        allow(Course).to receive(:find).with(2).and_return(course2)
        allow_any_instance_of(Ta).to receive(:ta_mappings).and_return([ta_mapping1, ta_mapping2])
        stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
        expect(course_options).to eq([["ECE506", 2], ["ECE517", 1]])
      end
    end
    context 'when the user is an admin' do
      it 'gets all courses in expertiza' do
        allow(Course).to receive(:all).and_return([course1, course2, course3])
        stub_current_user(admin, admin.role.name, admin.role)
        expect(course_options).to eq([['-----------', nil], ['ECE216', 3], ['ECE506', 2], ['ECE517', 1]])
      end
    end
    context 'when the user is an instructor' do
      it 'gets the courses associated with the instructor and their TAs' do
        allow(Course).to receive(:where).and_return([course1, course2])
        allow(instructor).to receive(:my_tas).and_return([1])
        allow(Ta).to receive(:find).and_return(teaching_assistant)
        allow_any_instance_of(Ta).to receive(:ta_mappings).and_return([ta_mapping1, ta_mapping2])
        allow(Course).to receive(:find).with(1).and_return(course1)
        allow(Course).to receive(:find).with(2).and_return(course2)
        allow(Instructor).to receive(:find).and_return(instructor)
        stub_current_user(instructor, instructor.role.name, instructor.role)
        expect(course_options).to eq([["-----------", nil], ["ECE506", 2], ["ECE517", 1]])
      end
    end
  end
end
