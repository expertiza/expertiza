#require 'assignment_helper'
require 'rails_helper'
include AssignmentHelper

describe LotteryController do
  describe "#run_intelligent_bid" do
    before(:each) do
      @assignment = Assignment.where(name: 'assignment1').first || Assignment.new({
                                                                                      "id"=> "101",
                                                                                      "name"=>"My assignment",
                                                                                      "is_intelligent"=>1
                                                                                  })
    end

    it "the assignment is intelligent" do
      @assignment.is_intelligent==1
    end

    it "the assignment is not intelligent"do
      @assignment.is_intelligent!=1
    end
  end

end