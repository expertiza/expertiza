require 'spec_helper'

describe ReviewMappingHelper, type: :helper do

  describe 'get_team_colour' do
    before(:each) do
      @assignment = create(:assignment)
      @response_map = create(:review_response_map)
    end

    it 'should return \'red\' if response_map does not exist in Responses' do
      colour = get_team_colour(@response_map)
      expect(colour).to eq('red')
    end

    it 'should not return \'red\' if response_map exists in Responses' do
      create(:response, response_map: @response_map)
      colour = get_team_colour(@response_map)
      expect(colour).not_to eq('red')
    end
  end

end
