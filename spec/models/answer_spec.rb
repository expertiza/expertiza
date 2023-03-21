describe Answer do
  let(:questionnaire) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1) }
  let(:question2) { create(:question, questionnaire: questionnaire, weight: 2, id: 2) }
  let(:response_map) { create(:review_response_map, id: 1, reviewed_object_id: 1) }
  let!(:response_record) { create(:response, id: 1, map_id: 1, response_map: response_map) }
  let!(:answer) { create(:answer, question: question1, response_id: 1) }
  let(:team1) { build(:assignment_team, id: 2, name: 'team has name') }

  describe '# test dependency between question.rb and answer.rb'
  it { should belong_to(:question) }

  describe '#test sql queries in answer.rb' do
    before(:each) do
      @assignment_id = 1
      @reviewee_id = 1
      @q_id = 1
      @round = 1
    end
    it 'returns answer by question record from db which is not empty' do
      expect(Answer.answers_by_question(@assignment_id, @q_id)).not_to be_empty
    end

    it 'returns answers by question for reviewee from the db which is not empty' do
      expect(Answer.answers_by_question_for_reviewee(@assignment_id, @reviewee_id, @q_id)).not_to be_empty
    end

    it 'returns answers by question for reviewee in round from db which is not empty' do
      expect(Answer.answers_by_question_for_reviewee_in_round(@assignment_id, @reviewee_id, @q_id, @round)).not_to be_empty
    end
  end

  # A bug was reported to TAs regarding submission_valid? function.
  # The line 106 in answers.rb enters if sorted deadline is nil but if that is the case, line 113   will throw an error.
  # So the following test cases will make no sense once the bug is fixed. These have to changed.
  describe 'submission valid?' do
    xit 'Checking for when valid due date objects are passed back to @sorted_deadlines' do
      response_record.id = 1
      response_record.additional_comment = 'Test'
      due_date1 = AssignmentDueDate.new
      due_date2 = AssignmentDueDate.new
      due_date1.due_at = Time.new - 24
      due_date2.due_at = Time.new - 24
      due_date1.deadline_type_id = 4
      due_date2.deadline_type_id = 2
      ResubmissionTime1 = Time.new - 24
      ResubmissionTime2 = Time.new - 48
      expect(Answer.submission_valid?(response_record)).to eq nil
    end

    it 'Checking when no due date objects are passed back to @sorted_deadlines' do
      response_record.id = 1
      response_record.additional_comment = 'Test'
      allow(AssignmentDueDate).to receive(:where).and_return(nil)
      allow(AssignmentDueDate).to receive(:order).and_return(nil)
      expect { Answer.submission_valid?(response_record) }.to raise_error
    end
  end
end
