require 'rails_helper'

describe 'ReviewResponseMap' do

  before(:each) do
    @review_response= build(:review_response_map)
  end

  describe "#validity" do
    it "should have a valid reviewee_id" do
      expect(@review_response.reviewee_id).to be_instance_of(Fixnum)
    end
    end
end
