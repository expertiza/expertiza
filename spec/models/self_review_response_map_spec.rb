require 'rails_helper'
describe SelfReviewResponseMap do
#  let(:selfreviewresponsemap) {SelfReviewResponseMap.new id: 6, reviewee_id: 1, reviewed_object_id: 8}
    describe "validations" do
      before(:each) do
        @selfreviewresponsemap = build(:selfreviewresponsemap)
      end
   
      it "selfreviewresponsemap is valid" do
        expect(@selfreviewresponsemap).to be_valid
      end
  end

  describe "#type" do
      it "checks if type is assignment participant" do
        @selfreviewresponsemap = build(:selfreviewresponsemap)
        expect(@selfreviewresponsemap.type).to eq("SelfReviewResponseMap")
        expect(@selfreviewresponsemap.type).not_to eq('Review')
        expect(@selfreviewresponsemap.type).not_to eq('Feedback Review')
      end
  end

  describe "id" do
  #test all the id are stored correctly
    it "should be our exact selfreviewresponsemap's id" do
      @selfreviewresponsemap = build(:selfreviewresponsemap)
      expect(@selfreviewresponsemap.id).to eq(6)
    end
    it "should not be any other selfreviewresponsemap's id" do
      @selfreviewresponsemap = build(:selfreviewresponsemap)
      expect(@selfreviewresponsemap.id).not_to eq(7)
    end
    it "should be our exact reviewee's id" do
      @selfreviewresponsemap = build(:selfreviewresponsemap)
      expect(@selfreviewresponsemap.reviewee_id).to eq(1)
    end
    it "should not be any other reviewee's id" do
      @selfreviewresponsemap = build(:selfreviewresponsemap)
      expect(@selfreviewresponsemap.reviewee_id).not_to eq(2)
    end
  end


end