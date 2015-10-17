require 'rspec'
require_relative '../rails_helper'

describe 'get_total_score' do

  @response = params[:response].last
  it 'should return weighted total score when sum_of_weights > 0 && max_question_score' do




  end

  it 'should return -1 when sum_of_weights <= 0 or max_question_score does not exist' do



  end

end




describe 'computer_stat' do

  it 'should return current score and scores' do

    true.should == false
  end
end