#E1731: Some preliminary tests. Need to verify if correct. Also need to add more test cases
require 'rails_helper'
# include GradesHelper


describe LocalDbCalc do
  before(:each) do
    @response_maps = ResponseMap.new
    @response_maps.id = 123456
    @response_maps.save!
  end

  it 'Check if scores stored in db' do
    @scores = LocalDbScore.new
    @scores.score_type = "ReviewLocalDBScore"
    @scores.round = 1
    @scores.score = 75
    @scores.response_map_id = 123456
    @scores.save!
    expect(LocalDbScore.where(response_map_id: 123456)).to exist
  end

end
