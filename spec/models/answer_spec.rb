require 'rspec'
require_relative '../rails_helper'

#Unit test for 'compute_scores'
describe 'compute_scores' do
  context 'when assessment is not nil' do
    it 'should return valid scores' do
      question=Question.new(
          txt: "qusetionaaaaa",
          weight: 1,
          questionnaire_id: 200,
          type: "Criterion",
          break_before: true)
      assessment = 'Assessment'
      scores1 = {max: 100, min: 100, avg: 100}
      allow(Answer).to receive(:compute_stat).and_return([100, scores1])
      expect(Answer.compute_scores([assessment], [question])).to eq scores1
    end
  end

  context 'when assessment is nil' do
    it 'should return nil for score hash' do
      scores2 = {max: nil, min: nil, avg: nil}
      expect(Answer.compute_scores(nil, nil)).to eq scores2
    end
  end
end



#Unit test for 'computer_quiz_scores'
describe 'compute_quiz_scores' do
  before(:each) {
    allow_message_expectations_on_nil
  }

  context 'when responses is not nil' do
    it 'should return valid scores' do
      responses=Response.new
      responses.id=1000
      responses.created_at = DateTime.current
      responses.updated_at = DateTime.current
      responses.map_id=1
      responses.additional_comment="additional_comment"
      responses.version_num=1
            
      allow(QuizQuestionnaire).to receive(:find)
      allow(nil).to receive(:questions)
      allow(nil).to receive(:reviewed_object_id)
      allow(Answer).to receive(:get_total_score).and_return(100)
      scores1 = {max: 100, min: 100, avg: 100}
      expect(Answer.compute_quiz_scores([responses])).to eq scores1
    end
  end

  context 'when responses is empty' do
    it 'should return nil for score hash' do
      responses = []
      scores2 = {max: nil, min: nil, avg: nil}
      expect(Answer.compute_quiz_scores(responses)).to eq scores2
    end
  end
end



#Unit test for 'get_total_score'
describe 'get_total_score' do
  before(:each) {
    allow(Answer).to receive(:submission_valid?)
    @responses=Response.new
    @responses.id=1000
    @responses.created_at = DateTime.current
    @responses.updated_at = DateTime.current
    @responses.map_id=1
    @responses.additional_comment="additional_comment"
    @responses.version_num=1
    @question=Question.new(
        txt: "qusetionaaaaa",
        weight: 1,
        questionnaire_id: 200,
        type: "Criterion",
        break_before: true)
  }

  it 'should return weighted total score when sum_of_weights > 0 && max_question_score' do
    score = ScoreView.new(:type => 'Criterion',
                          :q1_id => @question.questionnaire_id,
                          :s_response_id => @responses.id,
                          :question_weight => 1,
                          :s_score => 5,
                          :q1_max_question_score => 5)
    allow(ScoreView).to receive(:where).and_return([score])
    expect(Answer.get_total_score(:response => [@responses], :questions => [@question])).to eq 100
  end

  it 'should return -1 when sum_of_weights <= 0 or max_question_score does not exist' do
    expect(Answer.get_total_score(:response => [@responses], :questions => [@question])).to eq -1
  end

end

#Unit test for 'compute_stat'
describe 'compute_stat' do
  before(:each) {
    @scores = {max: -999999999, min: 999999999}
    allow(Answer).to receive(:get_total_score).and_return(100)
  }

  context "when invalid is 1" do
    it 'should return current score and scores' do
      Answer.instance_variable_set(:@invalid, 1)
      expect(Answer.compute_stat(nil, nil, @scores, 5)).to eq [0, @scores]
    end
  end

  context "when invalid is 0" do
    it 'should return current score and scores' do
      Answer.instance_variable_set(:@invalid, 0)
      expect(Answer.compute_stat(nil, nil, @scores, 5)).to eq [100, @scores]
    end
  end
end

#Unit test for 'submission valid'
describe 'submission valid' do
  before(:each) {
    allow_message_expectations_on_nil
    late_due = DueDate.new(due_at: Time.parse("2020-10-30"), deadline_type_id: 2)
    early_due = DueDate.new(due_at: Time.parse("2010-10-30"), deadline_type_id: 2)
    sorted_deadlines = [late_due, early_due]

    @responses=Response.new
    @responses.id=1000
    @responses.created_at = DateTime.current
    @responses.updated_at = DateTime.current
    @responses.map_id=1
    @responses.additional_comment="additional_comment"
    @responses.version_num=1

    map=double(:ResponseMap)
    allow(ResponseMap).to receive(:find).and_return(map)
    allow(map).to receive(:reviewed_object_id)
    allow(map).to receive(:reviewee_id)
    allow(DueDate).to receive(:where).and_return(sorted_deadlines)
    allow(sorted_deadlines).to receive(:order).and_return(sorted_deadlines)
    allow(ResubmissionTime).to receive(:where)
    allow(nil).to receive(:order)
    allow(Answer).to receive(:latest_review_deadline)
  }

  it 'invalid should be 1' do
    allow(@responses).to receive(:is_valid_for_score_calculation?).and_return(false)
    expect(Answer.submission_valid?(@responses)).to eq 1
  end

  it 'invalid should be 0' do
    allow(@responses).to receive(:is_valid_for_score_calculation?).and_return(true)
    expect(Answer.submission_valid?(@responses)).to eq 0
  end
end

#Unit test for 'latest review deadline'
describe 'latest review deadline' do
  late_due = DueDate.new(due_at: Time.parse("2020-10-30"), deadline_type_id: 2)
  early_due = DueDate.new(due_at: Time.parse("2010-10-30"), deadline_type_id: 2)
  sorted_deadlines = [late_due, early_due]

  it 'should return early due date' do
    expect(Answer.latest_review_deadline(sorted_deadlines)).to eq early_due.due_at
  end
end
