describe AssignmentHelper do

  # E1936
  # Both AssignmentHelper#assignment_questionnaire and AssignmentHelper#questionnaire methods are removed from the
  # helpers/assignment_helper.rb since both methods contained duplicate implementation found in the different files
  # models/assignment.rb (Assignment class), models/assignment_form.rb (AssignmentForm class), and others.
  # To avoid all duplicate implementation, these methods are preserved only in the models/assignment_form.rb file and
  # tested there:
  # AssignmentForm#assignment_questionnaire
  # AssignmentForm#questionnaire

  let(:assignment_helper) { Class.new { extend AssignmentHelper } }
  let(:questionnaire) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, scores: [answer]) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:team) { build(:assignment_team) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:questionnaire1) { build(:questionnaire, name: "abc", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234) }
  let(:contributor) { build(:assignment_team, id: 1) }
  let(:signed_up_team) { build(:signed_up_team, team_id: contributor.id) }

  describe '#questionnaire_options' do
    it 'throws exception if type argument nil' do
      expect { questionnaire_options(nil) }.to raise_exception(NoMethodError)
    end
  end


end
