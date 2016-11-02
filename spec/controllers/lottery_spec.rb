# require 'assignment_helper'
require 'rails_helper'
include AssignmentHelper

describe LotteryController do
  describe "#run_intelligent_bid" do
    it "the assignment is intelligent" do
      assignment = double("Assignment")
      allow(assignment).to receive(:is_intelligent) { 1 }
      expect(assignment.is_intelligent).to eq(1)
    end
  end
end
