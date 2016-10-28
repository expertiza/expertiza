require 'rails_helper'
describe MetareviewResponseMap do
  let(:metareviewresponsemap) {MetareviewResponseMap.new id: 6, reviewee_id: 1, reviewed_object_id: 8}
 


  describe "#new" do
    it "Validate response instance creation with valid parameters" do
      expect(metareviewresponsemap.class).to be(MetareviewResponseMap)
    end
  end

  describe "id" do
  #test all the id are stored correctly
  	it "should be our exact metareviewresponsemap's id" do
      expect(metareviewresponsemap.id).to eq(6)
    end
    it "should not be any other metareviewresponsemap's id" do
      expect(metareviewresponsemap.id).not_to eq(7)
    end
    it "should be our exact reviewee's id" do
      expect(metareviewresponsemap.reviewee_id).to eq(1)
    end
    it "should not be any other reviewee's id" do
      expect(metareviewresponsemap.reviewee_id).not_to eq(2)
    end
  end

  describe "title" do
  #test the title to be stored correctly
    it "should be Teammate Review" do
      expect(metareviewresponsemap.get_title).to eq('Metareview')
    end
    it "should not be Review" do
      expect(metareviewresponsemap.get_title).not_to eq('Review')
    end
    it "should not be Feedback Review" do
      expect(metareviewresponsemap.get_title).not_to eq('Feedback Review')
    end
  end
end