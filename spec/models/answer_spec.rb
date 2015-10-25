require 'rspec'
require_relative '../rails_helper'

describe 'get_total_score' do
  before(:each) {
    Answer.stub(:submission_valid?)
    @responses=Response.new
    @responses.id=1000
    @responses.created_at = DateTime.current
    @responses.updated_at = DateTime.current
    @responses.map_id=1
    @responses.additional_comment="additional_comment"
    @responses.version_num=1
    @question=Question.new(
        txt:"qusetionaaaaa",
        weight: 1,
        questionnaire_id: 200,
        type:"Criterion",
        break_before:true)
  }

  it 'should return weighted total score when sum_of_weights > 0 && max_question_score' do
    score = ScoreView.new(:type =>'Criterion', 
                          :q1_id=>@question.questionnaire_id, 
                          :s_response_id=>@responses.id, 
                          :question_weight=>1,
                          :s_score=>5,
                          :q1_max_question_score=>5)
    ScoreView.stub(:where).and_return( [score] )
    expect(Answer.get_total_score(:response=>[@responses],:questions=>[@question])).to eq 100
  end

  it 'should return -1 when sum_of_weights <= 0 or max_question_score does not exist' do
    expect(Answer.get_total_score(:response=>[@responses],:questions=>[@question])).to eq -1
  end

end

describe 'computer_stat' do
  before(:each) {
    @scores = {max:-999999999, min:999999999}
    Answer.stub(:get_total_score).and_return( 100 )
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

describe 'submission valid' do
  before(:each) {
    late_due = DueDate.new(due_at:Time.parse("2020-10-30"), deadline_type_id: 2)
    early_due = DueDate.new(due_at:Time.parse("2010-10-30"), deadline_type_id: 2)
    sorted_deadlines = [late_due, early_due]   

    @responses=Response.new
    @responses.id=1000
    @responses.created_at = DateTime.current
    @responses.updated_at = DateTime.current
    @responses.map_id=1
    @responses.additional_comment="additional_comment"
    @responses.version_num=1

    map=double(:ResponseMap)
    ResponseMap.stub(:find).and_return(map)
    map.stub(:reviewed_object_id)
    map.stub(:reviewee_id)
    DueDate.stub(:where).and_return(sorted_deadlines)
    sorted_deadlines.stub(:order).and_return(sorted_deadlines)
    ResubmissionTime.stub(:where)
    nil.stub(:order)
    Answer.stub(:latest_review_deadline)
  }

  it 'invalid should be 1' do
    @responses.stub( :is_valid_for_score_calculation? ).and_return(false)
    expect(Answer.submission_valid?(@responses)).to eq 1
  end

  it 'invalid should be 0' do
    @responses.stub( :is_valid_for_score_calculation? ).and_return(true)
    expect(Answer.submission_valid?(@responses)).to eq 0
  end
end

describe 'latest review deadline' do
  late_due = DueDate.new(due_at:Time.parse("2020-10-30"), deadline_type_id: 2)
  early_due = DueDate.new(due_at:Time.parse("2010-10-30"), deadline_type_id: 2)
  sorted_deadlines = [late_due, early_due]

  it 'should return early due date' do
    expect(Answer.latest_review_deadline(sorted_deadlines)).to eq early_due.due_at
  end
end
