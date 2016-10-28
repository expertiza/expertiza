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
  end
end
