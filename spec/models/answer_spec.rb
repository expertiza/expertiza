require 'rspec'
require_relative '../rails_helper'
#require_relative '../fixtures/ScoreView.yml'
describe 'get_total_score' do
  before(:each) {
    
  }

  it 'should return weighted total score when sum_of_weights > 0 && max_question_score' do
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
        break_before:true

    )

   score = ScoreView.new(:type =>'Criterion', :q1_id=> @question.questionnaire_id, :s_response_id=>@responses.id, :question_weight=>1,:s_score=>5,:q1_max_question_score=>5)
   ScoreView.stub(:where).and_return( [score] )
   expect(Answer.get_total_score(:response=>[@responses],:questions=>[@question])).to eq 100

  end


  it 'should return -1 when sum_of_weights <= 0 or max_question_score does not exist' do


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
        break_before:true

    )

=begin
    questionnaireData=double('ScoreView',:type =>'Criterion', :q1_id=> @question.questionnaire_id, :s_response_id =>@responses.id,
                 :question_weight=>1,:s_score=>5,:q1_max_question_score=>5)
=end
   
   #score = ScoreView.new(:type =>'Criterion', :q1_id=> @question.questionnaire_id, :s_response_id =>@responses.id, :question_weight=>1,:s_score=>5,:q1_max_question_score=>5)
   #allow(score).to receive(:where).with({:type =>'Criterion', :q1_id=> @question.questionnaire_id, :s_response_id =>@responses.id}).and_return([ScoreView.new(:type =>'Criterion', :q1_id=> @question.questionnaire_id, :s_response_id =>@responses.id, :question_weight=>1,:s_score=>5,:q1_max_question_score=>5)])
   #ScoreView.stub(:where).and_return( [score] )
   expect(Answer.get_total_score(:response=>[@responses],:questions=>[@question])).to eq -1

  end

end

describe 'computer_stat' do
  context "when invalid is 1" do
    before { Answer.instance_variable_set(:@invalid, 1) }
      it 'should return current score and scores' do
      scores = {max:-999999999, min:999999999}
      Answer.stub(:get_total_score).and_return( 100 )
      expect(Answer.compute_stat(nil, nil, scores, 5)).to eq [0, scores]
    end
  end

  context "when invalid is 0" do
    before { Answer.instance_variable_set(:@invalid, 0) }
      it 'should return current score and scores' do
      scores = {max:-999999999, min:999999999}
      Answer.stub(:get_total_score).and_return( 100 )
      expect(Answer.compute_stat(nil, nil, scores, 5)).to eq [100, scores]
    end
  end
end
