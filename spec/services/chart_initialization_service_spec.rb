require 'rails_helper'

describe ChartInitializationService do
  # Create a reviewer double with necessary methods
  let(:reviewer) do
    double('Reviewer', 
      avg_vol_per_round: [10, 15, 20],
      overall_avg_vol: 15
    )
  end
  
  let(:num_rounds) { 3 }
  let(:all_reviewers_avg_vol_per_round) { [8, 12, 16] }
  let(:all_reviewers_overall_avg_vol) { 12 }
  
  let(:service) do
    described_class.new(
      reviewer,
      num_rounds,
      all_reviewers_avg_vol_per_round,
      all_reviewers_overall_avg_vol
    )
  end

  describe '#initialize' do
    it 'sets instance variables correctly' do
      expect(service.reviewer).to eq(reviewer)
      expect(service.num_rounds).to eq(num_rounds)
      expect(service.all_reviewers_avg_vol_per_round).to eq(all_reviewers_avg_vol_per_round)
      expect(service.all_reviewers_overall_avg_vol).to eq(all_reviewers_overall_avg_vol)
    end
  end

  describe '#initialize_chart_elements' do
    context 'when all rounds have positive average volumes' do
      it 'returns expected labels, reviewer data, and all reviewers data' do
        labels, reviewer_data, all_reviewers_data = service.initialize_chart_elements
        
        # Check labels include all rounds plus "Total"
        expect(labels).to eq([1, 2, 3, 'Total'])
        
        # Check reviewer data includes volumes for all rounds plus overall
        expect(reviewer_data).to eq([10, 15, 20, 15])
        
        # Check all reviewers data includes volumes for all rounds plus overall
        expect(all_reviewers_data).to eq([8, 12, 16, 12])
      end
    end
    
    context 'when some rounds have zero average volume' do
      let(:all_reviewers_avg_vol_per_round) { [8, 0, 16] }
      
      it 'skips rounds with zero average volume and renumbers remaining rounds' do
        labels, reviewer_data, all_reviewers_data = service.initialize_chart_elements
        
        # Check labels include only rounds with positive volume but renumbered sequentially
        expect(labels).to eq([1, 2, 'Total'])  # Round 2 is skipped but round 3 becomes label "2"
        
        # Check reviewer data includes only values from rounds with positive volume
        expect(reviewer_data).to eq([10, 20, 15])  # Values from rounds 1 and 3, then overall
        
        # Check all reviewers data includes only values from rounds with positive volume
        expect(all_reviewers_data).to eq([8, 16, 12])  # Values from rounds 1 and 3, then overall
      end
    end
    
    context 'when all rounds have zero average volume' do
      let(:all_reviewers_avg_vol_per_round) { [0, 0, 0] }
      
      it 'returns only "Total" in labels' do
        labels, reviewer_data, all_reviewers_data = service.initialize_chart_elements
        
        # Check only "Total" is included in labels
        expect(labels).to eq(['Total'])
        
        # Check only overall volumes are included
        expect(reviewer_data).to eq([15])
        expect(all_reviewers_data).to eq([12])
      end
    end
  end

  describe 'edge cases' do
    context 'with zero rounds' do
      let(:num_rounds) { 0 }
      
      it 'returns only "Total" in labels' do
        labels, reviewer_data, all_reviewers_data = service.initialize_chart_elements
        
        expect(labels).to eq(['Total'])
        expect(reviewer_data).to eq([15])
        expect(all_reviewers_data).to eq([12])
      end
    end
    
    context 'with negative values' do
      let(:reviewer) do
        double('Reviewer', 
          avg_vol_per_round: [-5, 15, -10],
          overall_avg_vol: 0
        )
      end
      let(:all_reviewers_avg_vol_per_round) { [8, 12, 16] }
      
      it 'handles negative reviewer volumes correctly' do
        labels, reviewer_data, all_reviewers_data = service.initialize_chart_elements
        
        expect(labels).to eq([1, 2, 3, 'Total'])
        expect(reviewer_data).to eq([-5, 15, -10, 0])
        expect(all_reviewers_data).to eq([8, 12, 16, 12])
      end
    end
  end

  describe 'performance' do
    it 'handles large number of rounds efficiently' do
      reviewer_large = double('Reviewer')
      allow(reviewer_large).to receive(:avg_vol_per_round).and_return(Array.new(1000, 10))
      allow(reviewer_large).to receive(:overall_avg_vol).and_return(10)
      
      all_reviewers_avg_vol_large = Array.new(1000, 8)
      
      service_large = described_class.new(
        reviewer_large,
        1000,
        all_reviewers_avg_vol_large,
        8
      )
      
      require 'benchmark'
      time = Benchmark.measure do
        service_large.initialize_chart_elements
      end
      
      # Should be very fast even with 1000 rounds
      expect(time.real).to be < 0.5
    end
  end
end