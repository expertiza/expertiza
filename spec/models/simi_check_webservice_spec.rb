require 'rails_helper'

describe "SimiCheckWebservice" do

  describe ".new_comparison" do
    context "called with a comparison_name" do
      it "retursn a response with code 200, and body containing the name and new id for this comparison" do
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        expect(response.code).to eql(200)
        expect(json_response["id"]).to be_truthy
      end
    end
  end

  describe ".get_all_comparisons" do
    context "any time called" do
      it "returns a response with code 200 and body containing all comparisons" do
        response = SimiCheckWebService.get_all_comparisons()
        json_response = JSON.parse(response.body)
        expect(response.code).to eql(200)
        expect(json_response["comparisons"]).to be_truthy
      end
    end
  end

end
