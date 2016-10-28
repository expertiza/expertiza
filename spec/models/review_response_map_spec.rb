require 'rails_helper'

describe 'ReviewResponseMap' do

  before(:each) do
    @participant=create(:participant)
    @assignment_questionnaire= create(:assignment_questionnaire)
    @review_response=create(:review_response_map)


  end

  describe "#validity" do
    it "should have a valid reviewee_id" do
      expect(@review_response.reviewee_id).to be_instance_of(Fixnum)
    end
    it "should return review_map with questionnaire id" do
      map=ReviewResponseMap.final_versions_from_reviewer(1)
      expect(map).to be_truthy
      expect(map[:review][:questionnaire_id]).to be(1)
    end
    it "should return the valid questionnaire" do
      review_questionnaire=@review_response.questionnaire 1
      expect(review_questionnaire).to be_instance_of(ReviewQuestionnaire)
      expect(review_questionnaire.id).to be(1)
    end
    it "should return title" do
      expect(@review_response.title).to eql "Review"
    end
    it "should return export_fields" do
      export_fields=ReviewResponseMap.export_fields nil
      expect(export_fields.length).to be(2)
    end
  end
end
