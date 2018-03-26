require 'rails_helper'
require 'collusion_cycle.rb'

describe CollusionCycle do
  let(:participant1) { build_stubbed(:participant, id: 1 ) }
  let(:participant2) { build_stubbed(:participant, id: 2 ) }
  let(:participant3) { build_stubbed(:participant, id: 3 ) }
  let(:participant4) { build_stubbed(:participant, id: 4 ) }
  let(:response12) { build(:response)}
  let(:response21) { build(:response)}
  let(:response23) { build(:response)}
  let(:response31) { build(:response)}
  let(:response34) { build(:response)}
  let(:response41) { build(:response)}
  let(:colcyc) {CollusionCycle.new}

  context "two_node_cycle" do
    before(:each) do
      allow(participant1).to receive(:reviewers).and_return([participant2])
      allow(response12).to receive(:total_score).and_return(100)
      allow(response21).to receive(:total_score).and_return(90)
    end

    it "no collusion" do
      allow(participant2).to receive(:reviewers).and_return([])
      expect(colcyc.two_node_cycles(participant1)).to eq ([])
    end

    it "Cycle collude but review12 is nil" do
      allow(participant2).to receive(:reviewers).and_return([participant1])
      allow(participant1).to receive(:reviews_by_reviewer).with(participant2).and_return(nil)
      expect(colcyc.two_node_cycles(participant1)).to eq ([])
    end

    it "Cycle collude but review21 is nil" do
      allow(participant2).to receive(:reviewers).and_return([participant1])
      allow(participant1).to receive(:reviews_by_reviewer).with(participant2).and_return(response12)
      allow(participant2).to receive(:reviews_by_reviewer).with(participant1).and_return(nil)
      expect(colcyc.two_node_cycles(participant1)).to eq ([])
    end

    it "Cycle collude and all reviews are not nil" do
      allow(participant2).to receive(:reviewers).and_return([participant1])
      allow(participant1).to receive(:reviews_by_reviewer).with(participant2).and_return(response12)
      allow(participant2).to receive(:reviews_by_reviewer).with(participant1).and_return(response21)
      expect(colcyc.two_node_cycles(participant1)).to eq ([[[participant1, 100],[participant2, 90]]])
    end

  end

  context "three_node_cycles" do
    before(:each) do
      allow(participant1).to receive(:reviewers).and_return([participant2])
      allow(participant2).to receive(:reviewers).and_return([participant3])
      allow(response12).to receive(:total_score).and_return(100)
      allow(response23).to receive(:total_score).and_return(95)
      allow(response31).to receive(:total_score).and_return(90)
    end

    it "no collusion" do
      allow(participant3).to receive(:reviewers).and_return([])
      expect(colcyc.three_node_cycles(participant1)).to eq ([])
    end

    it "Cycle collude but review12 is nil" do
      allow(participant3).to receive(:reviewers).and_return([participant1])
      allow(participant1).to receive(:reviews_by_reviewer).with(participant2).and_return(nil)
      expect(colcyc.three_node_cycles(participant1)).to eq ([])
    end

    it "Cycle collude but review23 is nil" do
      allow(participant3).to receive(:reviewers).and_return([participant1])
      allow(participant1).to receive(:reviews_by_reviewer).with(participant2).and_return(response12)
      allow(participant2).to receive(:reviews_by_reviewer).with(participant3).and_return(nil)
      expect(colcyc.three_node_cycles(participant1)).to eq ([])
    end

    it "Cycle collude but review31 is nil" do
      allow(participant3).to receive(:reviewers).and_return([participant1])
      allow(participant1).to receive(:reviews_by_reviewer).with(participant2).and_return(response12)
      allow(participant2).to receive(:reviews_by_reviewer).with(participant3).and_return(response23)
      allow(participant3).to receive(:reviews_by_reviewer).with(participant1).and_return(nil)
      expect(colcyc.three_node_cycles(participant1)).to eq ([])
    end

    it "Cycle collude and all reviews are not nil" do
      allow(participant3).to receive(:reviewers).and_return([participant1])
      allow(participant1).to receive(:reviews_by_reviewer).with(participant2).and_return(response12)
      allow(participant2).to receive(:reviews_by_reviewer).with(participant3).and_return(response23)
      allow(participant3).to receive(:reviews_by_reviewer).with(participant1).and_return(response31)
      expect(colcyc.three_node_cycles(participant1)).to eq ([[[participant1, 100], [participant2, 95], [participant3, 90]]])
    end
  end

  context "four_node_cycles" do
    before (:each) do
      allow(participant1).to receive(:reviewers).and_return([participant2])
      allow(participant2).to receive(:reviewers).and_return([participant3])
      allow(participant3).to receive(:reviewers).and_return([participant4])
      allow(response12).to receive(:total_score).and_return(100)
      allow(response23).to receive(:total_score).and_return(90)
      allow(response34).to receive(:total_score).and_return(80)
      allow(response41).to receive(:total_score).and_return(70)
    end

    it "no collusion" do
      allow(participant4).to receive(:reviewers).and_return([])
      expect(colcyc.four_node_cycles(participant1)).to eq ([])
    end

    it "Cycle collude but review12 is nil" do
      allow(participant4).to receive(:reviewers).and_return([participant1])
      allow(participant1).to receive(:reviews_by_reviewer).with(participant2).and_return(nil)
      expect(colcyc.four_node_cycles(participant1)).to eq ([])
    end

    it "Cycle collude but review23 is nil" do
      allow(participant4).to receive(:reviewers).and_return([participant1])
      allow(participant1).to receive(:reviews_by_reviewer).with(participant2).and_return(response12)
      allow(participant2).to receive(:reviews_by_reviewer).with(participant3).and_return(nil)
      expect(colcyc.four_node_cycles(participant1)).to eq ([])
    end

    it "Cycle collude but review34 is nil" do
      allow(participant4).to receive(:reviewers).and_return([participant1])
      allow(participant1).to receive(:reviews_by_reviewer).with(participant2).and_return(response12)
      allow(participant2).to receive(:reviews_by_reviewer).with(participant3).and_return(response23)
      allow(participant3).to receive(:reviews_by_reviewer).with(participant4).and_return(nil)
      expect(colcyc.four_node_cycles(participant1)).to eq ([])
    end

    it "Cycle collude but review34 is nil" do
      allow(participant4).to receive(:reviewers).and_return([participant1])
      allow(participant1).to receive(:reviews_by_reviewer).with(participant2).and_return(response12)
      allow(participant2).to receive(:reviews_by_reviewer).with(participant3).and_return(response23)
      allow(participant3).to receive(:reviews_by_reviewer).with(participant4).and_return(response34)
      allow(participant4).to receive(:reviews_by_reviewer).with(participant1).and_return(nil)
      expect(colcyc.four_node_cycles(participant1)).to eq ([])
    end

    it "Cycle collude and all reviews are not nil" do
      allow(participant4).to receive(:reviewers).and_return([participant1])
      allow(participant1).to receive(:reviews_by_reviewer).with(participant2).and_return(response12)
      allow(participant2).to receive(:reviews_by_reviewer).with(participant3).and_return(response23)
      allow(participant3).to receive(:reviews_by_reviewer).with(participant4).and_return(response34)
      allow(participant4).to receive(:reviews_by_reviewer).with(participant1).and_return(response41)
      expect(colcyc.four_node_cycles(participant1)).to eq ([[[participant1, 100],[participant2, 90],[participant3, 80],[participant4, 70]]])
    end

  end

  context "cycle_similarity_score" do
    it "similarity score of 2 node test" do
      cycle = [[participant1, 100], [participant2, 90]]
      expect(colcyc.cycle_similarity_score(cycle)).to eq (10.0)
    end

    it "similarity score of 3 node test" do
      cycle = [[participant1, 100], [participant2, 95], [participant3, 85]]
      expect(colcyc.cycle_similarity_score(cycle)).to eq (10.0)
    end

    it "similarity score of 4 node test" do
      cycle = [[participant1, 100], [participant2, 95], [participant3, 95], [participant4, 90]]
      expect(colcyc.cycle_similarity_score(cycle)).to eq (5.0)
    end
  end

  context "cycle_deviation_score" do
    before(:each) do
      allow(participant1).to receive(:id).and_return(1)
      allow(participant2).to receive(:id).and_return(2)
      allow(participant3).to receive(:id).and_return(3)
      allow(participant4).to receive(:id).and_return(4)
      allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant1)
      allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
      allow(AssignmentParticipant).to receive(:find).with(3).and_return(participant3)
      allow(AssignmentParticipant).to receive(:find).with(4).and_return(participant4)
      allow(participant1).to receive(:review_score).and_return(90)
      allow(participant2).to receive(:review_score).and_return(80)
      allow(participant3).to receive(:review_score).and_return(91)
      allow(participant4).to receive(:review_score).and_return(95)
    end

    it "deviation score for 2 nodes test" do
      cycle = [[participant1, 95], [participant2, 90]]
      expect(colcyc.cycle_deviation_score(cycle)).to eq (7.5)
    end

    it "deviation score for 3 nodes test" do
      cycle = [[participant1, 95], [participant2, 90], [participant3, 91]]
      expect(colcyc.cycle_deviation_score(cycle)).to eq (5.0)
    end

    it "deviation score for 4 nodes test" do
      cycle = [[participant1, 95], [participant2, 90], [participant3, 91], [participant4, 90]]
      expect(colcyc.cycle_deviation_score(cycle)).to eq (5.0)
    end
  end

end
