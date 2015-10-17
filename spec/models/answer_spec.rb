require 'rspec'
require_relative '../rails_helper'

describe 'get_total_score' do
  before(:each) do
    @responses=mock_model(Response,:id=> 1,:map_id=>1,:additional_comment=>"additional_comment",:version_num=>1)
    @score=mock(ScoreView,type: 'Criterion', q1_id: @question.questionnaire_id, s_response_id: @responses.id,
                      question_weight:1,s_score:5,q1_max_question_score:5)
=begin
  let(:map_id) { double("map_id") }
  let(:additional_comment) { double("additional_comment") }
  let(:version_num) { double ("version_num")}

  let(:responses) { Response.new(
      map_id:map_id,
      additional_comment: additional_comment,
      version_num: version_num

  )}
  let(:txt) { double("txt") }
  let(:weight) { double("weight") }
  let(:questionnaire) { double ("questionnaire")}
  let(:type) { double("type") }
  let(:break_before) { double("break_before") }
  let(:question) { Question.new(
      txt:txt,
      weight: weight,
      questionnaire: questionnaire,
      type:type,
      break_before:break_before

  )}
=end
  #@response = params[:response].last
  end
=begin
  it 'should return weighted total score when sum_of_weights > 0 && max_question_score' do



  end
=end

  it 'should return -1 when sum_of_weights <= 0 or max_question_score does not exist' do
=begin
    @responses=Response.new
    @responses.created_at = DateTime.current
    @responses.updated_at = DateTime.current
    @responses.map_id=1
    @responses.additional_comment="additional_comment"
    @responses.version_num=1
    @responses.save
=end

    @question=Question.new(
        txt:"qusetionaaaaa",
        weight: 1,
        questionnaire_id: 200,
        type:"Criterion",
        break_before:true

    )


   expect(Answer.get_total_score(:response=>[@responses],:questions=>[@question])).to eq -1

  end

end




describe 'computer_stat' do

  it 'should return current score and scores' do

    #true.should == false
  end
end