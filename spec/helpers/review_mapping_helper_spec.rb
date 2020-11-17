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

  describe '#average_of_round' do

    it 'should return correct average' do
      question_answer = {'a'=> 1, 'b'=>2, 'c'=>3} 
      expect(helper.average_of_round(question_answer)).to eq(2)
    end
  end

  describe '#std_of_round' do

    it 'should return correct standard deviation' do
      question_answer = {'a'=> 1, 'b'=>2, 'c'=>3} 
      expect(helper.std_of_round(2, question_answer)).to eq(0.82)
    end
  end
end
