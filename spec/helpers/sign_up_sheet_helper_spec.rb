require 'rails_helper'

describe "SignUpSheetHelper" do

  describe "#get_suggested_topics" do
    it "The get_suggested_topics method should return the suggested topics" do
      @assignment = create(:assignment)
      session[:user] = create(:student)
      topic = helper.get_suggested_topics(@assignment.id)
      expect(topic).to be_empty
    end
  end

end 