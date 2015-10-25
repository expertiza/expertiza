require 'rspec'
require_relative '../rails_helper'
#require_relative '../fixtures/ScoreView.yml'
describe 'get_total_score' do
  before(:each) {
    fixtures :ScoreView
  }

  it 'should return weighted total score when sum_of_weights > 0 && max_question_score' do



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
   expect(Answer.get_total_score(:response=>[@responses],:questions=>[@question])).to eq -1

  end

end




describe 'computer_stat' do

  it 'should return current score and scores' do

    #true.should == false
  end
end