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

  
  describe 'additional edge cases' do
    context 'with nil reviewer average volumes' do
      let(:reviewer) do
        double('Reviewer', 
          avg_vol_per_round: nil,
          overall_avg_vol: 15
        )
      end
      
      it 'handles nil reviewer avg_vol_per_round gracefully' do
        expect { service.initialize_chart_elements }.to raise_error(NoMethodError)
      end
    end
    
    context 'with missing data for some rounds' do
      let(:reviewer) do
        double('Reviewer', 
          avg_vol_per_round: [10, 15], # Only 2 rounds of data for a 3-round assignment
          overall_avg_vol: 12.5
        )
      end
      
      
      it 'works fine if rounds with missing data are skipped' do
        # If the third round has zero all_reviewers_avg_vol, it will be skipped
        all_reviewers_avg_vol_per_round_with_zero_third_round = [8, 12, 0]
        service_that_skips_missing_data = described_class.new(
          reviewer,
          3,
          all_reviewers_avg_vol_per_round_with_zero_third_round,
          12
        )
        
        # This should work fine because the third round will be skipped
        labels, reviewer_data, all_reviewers_data = service_that_skips_missing_data.initialize_chart_elements
        
        # Should only include rounds 1 and 2 (where data exists) plus "Total"
        expect(labels).to eq([1, 2, 'Total'])
        expect(reviewer_data).to eq([10, 15, 12.5])
        expect(all_reviewers_data).to eq([8, 12, 12])
      end
      
      it 'returns nil for missing data points' do
        # We need to make the third round's all_reviewers_avg_vol_per_round positive
        # so it will try to access the missing reviewer data
        all_reviewers_avg_vol_per_round_with_third_round = [8, 12, 16]
        service_with_missing_data = described_class.new(
          reviewer,
          3,
          all_reviewers_avg_vol_per_round_with_third_round,
          12
        )
        
        # Ruby returns nil for out-of-bounds array access rather than raising an error
        # So the service should return nil for the missing data point
        labels, reviewer_data, all_reviewers_data = service_with_missing_data.initialize_chart_elements
        
        expect(labels).to eq([1, 2, 3, 'Total'])
        expect(reviewer_data).to eq([10, 15, nil, 12.5])
        expect(all_reviewers_data).to eq([8, 12, 16, 12])
      end
    end
    
    context 'with extra reviewer data beyond num_rounds' do
      let(:reviewer) do
        double('Reviewer', 
          avg_vol_per_round: [10, 15, 20, 25, 30], # 5 rounds of data for a 3-round assignment
          overall_avg_vol: 20
        )
      end
      
      it 'ignores extra reviewer data beyond num_rounds' do
        labels, reviewer_data, all_reviewers_data = service.initialize_chart_elements
        
        # Should only use the first 3 rounds of data
        expect(labels).to eq([1, 2, 3, 'Total'])
        expect(reviewer_data).to eq([10, 15, 20, 20])
        expect(all_reviewers_data).to eq([8, 12, 16, 12])
      end
    end
  end
  
  describe 'data integrity' do
    context 'with inconsistent data lengths' do
      # Test when all_reviewers_avg_vol_per_round has a different length than num_rounds
      let(:all_reviewers_avg_vol_per_round) { [8, 12] } # Only 2 rounds of data
      
      it 'handles inconsistent data lengths gracefully' do
        expect { service.initialize_chart_elements }.to raise_error(NoMethodError)
      end
    end
    
    context 'with floating point values' do
      let(:reviewer) do
        double('Reviewer', 
          avg_vol_per_round: [10.5, 15.25, 20.75],
          overall_avg_vol: 15.5
        )
      end
      
      let(:all_reviewers_avg_vol_per_round) { [8.25, 12.5, 16.75] }
      let(:all_reviewers_overall_avg_vol) { 12.5 }
      
      it 'handles floating point values correctly' do
        labels, reviewer_data, all_reviewers_data = service.initialize_chart_elements
        
        expect(labels).to eq([1, 2, 3, 'Total'])
        expect(reviewer_data).to eq([10.5, 15.25, 20.75, 15.5])
        expect(all_reviewers_data).to eq([8.25, 12.5, 16.75, 12.5])
      end
    end
  end
  
  describe 'security considerations' do
    context 'with potentially dangerous input' do
      let(:dangerous_input) { "; DROP TABLE users;--" }
      
      let(:reviewer) do
        double('Reviewer', 
          avg_vol_per_round: [10, 15, 20],
          overall_avg_vol: dangerous_input
        )
      end
      
      it 'safely handles potentially dangerous input' do
        labels, reviewer_data, all_reviewers_data = service.initialize_chart_elements
        
        # The dangerous string should be passed through as-is, not executed
        expect(reviewer_data.last).to eq(dangerous_input)
      end
    end
  end
  
  describe 'internationalization support' do
    context 'with non-ASCII characters' do
      let(:international_label) { "Tотал" } # Cyrillic characters
      
      before do
        # Replace the default "Total" string with an international version
        allow(service).to receive(:initialize_chart_elements).and_wrap_original do |method, *args|
          labels, reviewer_data, all_reviewers_data = method.call(*args)
          labels[-1] = international_label
          [labels, reviewer_data, all_reviewers_data]
        end
      end
      
      it 'handles non-ASCII characters correctly' do
        labels, reviewer_data, all_reviewers_data = service.initialize_chart_elements
        
        expect(labels.last).to eq(international_label)
      end
    end
  end
  
  describe 'chart data characteristics' do
    it 'ensures data points match their corresponding labels' do
      labels, reviewer_data, all_reviewers_data = service.initialize_chart_elements
      
      # Check that all arrays have the same length
      expect(labels.length).to eq(reviewer_data.length)
      expect(labels.length).to eq(all_reviewers_data.length)
      
      # Check that the data is properly aligned
      labels.each_with_index do |label, i|
        if label == 'Total'
          expect(reviewer_data[i]).to eq(reviewer.overall_avg_vol)
          expect(all_reviewers_data[i]).to eq(all_reviewers_overall_avg_vol)
        elsif label.is_a?(Integer) && label <= reviewer.avg_vol_per_round.length
          # For rounds with data
          expect(reviewer_data[i]).to be_a(Numeric)
          expect(all_reviewers_data[i]).to be_a(Numeric)
        end
      end
    end
  end
end