require 'rails_helper'

describe "graph" do
  let(:graph){Hash[1=>[2,4,5], 2=>[3], 3=>[1], 4=>[], 5=>[]]}

  describe "#cycle_detection" do
    it "finds all cycles" do
      output = CollusionCycle.cycle_detection(graph)
      expect(output).not_to be_nil
      # it "finds_cycle of size 3" do
        cycle = CollusionCycle.get_cycle_of_size_n(output[0],output[1],3)
      # end
      expect(cycle).to eq([[1,2,3]])
    end
  end

  let(:graph_second){Hash[1=>[2,4], 2=>[4], 3=>[1], 4=>[3]]}
  describe "#cycle_detection" do
    it "finds all cycles" do
      output = CollusionCycle.cycle_detection(graph_second)
      puts output[0]
      puts output[1]
      expect(output).not_to be_nil
      # it "finds_cycle of size 3" do
        cycle = CollusionCycle.get_cycle_of_size_n(output[0],output[1],4)
      # end
      puts cycle
      expect(cycle).to eq([[1,2,3,4]])
    end
  end

end

