require 'rails_helper'

describe AssignmentParticipant do

=begin
  describe "review_score" do
    it { ReviewQuestionnaire.should respond_to :review_score }
  end
=end

  it "should be awesome" do
    foo = 3
    foo.should eq(3)
  end

  describe "calculate_Scores" do
    it { is_expected.not_to respond_to(:between?).with(7).arguments }
  end

=begin
  describe "a string" do
    it { is_expected.to respond_to(:length) }
  end
=end
=begin
  it "should know about associated Projects" do
    @user.should respond_to(:Scores)
  end
=end


    it "should do" do
      should validate_presence_of(:assignment)
    end
   # it {should validate_presence_of(:made)}

=begin
    it "should have date_till only if it has date_from"
    its "date_till should be >= date_from"
=end

  describe "calculateScores" do

    it "should_not.be less than 0" do
      5.should >=4
    end
  end

  describe "Calculate_Scores" do
    it "should_not.be greater than 100" do
      100.should eq(100.0)
    end
  end

  end