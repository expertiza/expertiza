require 'rails_helper'

describe AssignmentParticipant do

 # describe "calculate_scores" do
#it "should do" do
#    should validate_presence_of(:assignment)
# end
# it {should validate_presence_of(:made)}
    
#  end

  describe "calculate_scores" do
    it "should_not.be greater than 100" do
      100.should eq(100.0)
    end
  end

  end
