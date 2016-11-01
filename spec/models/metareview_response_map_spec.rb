require 'rails_helper'
describe "MetareviewResponseMap" do
  #let(:metareviewresponsemap) {MetareviewResponseMap.new id: 6, reviewee_id: 1, reviewed_object_id: 8}
 
   describe "validations" do
      before(:each) do
        @metareviewresponsemap = build(:metareviewresponsemap)
      end
   
      it "metareviewresponsemap is valid" do
        expect(@metareviewresponsemap).to be_valid
      end
  end

  describe "#type" do
      it "checks if type is assignment participant" do
        metareviewresponsemap = build(:metareviewresponsemap)
        expect(metareviewresponsemap.type).to eq("MetareviewResponseMap")
        expect(metareviewresponsemap.type).not_to eq('Review')
        expect(metareviewresponsemap.type).not_to eq('Feedback Review')
      end
  end

  describe "id" do
  #test all the id are stored correctly
  	it "should be our exact metareviewresponsemap's id" do
      metareviewresponsemap = build(:metareviewresponsemap)
      expect(metareviewresponsemap.id).to eq(6)
    end
    it "should not be any other metareviewresponsemap's id" do
      metareviewresponsemap = build(:metareviewresponsemap)
      expect(metareviewresponsemap.id).not_to eq(7)
    end
    it "should be our exact reviewee's id" do
      metareviewresponsemap = build(:metareviewresponsemap)
      expect(metareviewresponsemap.reviewee_id).to eq(1)
    end
    it "should not be any other reviewee's id" do
      metareviewresponsemap = build(:metareviewresponsemap)
      expect(metareviewresponsemap.reviewee_id).not_to eq(2)
    end
    it "should be our exact reviewed_object_id" do
      metareviewresponsemap = build(:metareviewresponsemap)
      expect(metareviewresponsemap.reviewed_object_id).to eq(8)
    end
    it "should not be any other reviewed_object_id" do
      metareviewresponsemap = build(:metareviewresponsemap)
      expect(metareviewresponsemap.reviewed_object_id).not_to eq(2)
    end
  end
end