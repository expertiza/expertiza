# require 'assignment_helper'
require 'rails_helper'
include AssignmentHelper

describe LotteryController do  
  describe "#run_intelligent_assignmnent" do
            it "webservice call should be successful" do
                dat=double("data")
                rest=double("RestClient")
                result = RestClient.get 'http://www.google.com',  :content_type => :json, :accept => :json
                expect(result.code).to eq(200)

            end
  end
end
