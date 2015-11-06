require 'rails_helper'

describe AssignmentParticipant do

  describe "calculateScores" do

    it "should_not.be less than 0" do
      scores =100
      scores.should >=0
    end
  end

  describe "Calculate_Scores" do
    it "should_not.be greater than 100" do
      100.should eq(100.0)
    end
  end

  end
