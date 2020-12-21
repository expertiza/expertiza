require 'spec_helper'

describe ReviewMappingHelper, type: :helper do

  let(:response) { build(:response, map_id: 2, visibility: 'public') }
  let(:review_response_map) { build(:review_response_map, id: 2) }

  describe '#visibility_public?' do

    it 'should return true if visibility is public or published' do
      allow(Response).to receive(:where).with(map_id: 2, visibility: ['public','published']).and_return(response)
      allow(response).to receive(:exists?).and_return(true)
      expect(helper.visibility_public?(review_response_map)).to be true
    end
  end

  describe 'test calculate_key_chart_information' do
    it 'should return new Hash if intervals are not empty' do
      intervals = [1.00,2.00,3.00,4.00,5.00,6.00]
      result = helper.calculate_key_chart_information(intervals)
      expect(result).to be_a_kind_of(Hash) 
      expect(result[:mean]).to eq(3.50)
      expect(result[:min]).to eq(1.00)
      expect(result[:max]).to eq(6.00)
      expect(result[:variance]).to eq(2.92)
      expect(result[:stand_dev]).to eq(1.71)
    end
  end

  describe 'test calculate_key_chart_information' do
    it 'should return nil if intervals are empty' do
      intervals = []
      result = helper.calculate_key_chart_information(intervals)
      expect(result).to be_nil
    end
  end

end
