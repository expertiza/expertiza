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
end
