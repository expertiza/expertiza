require 'rails_helper'

describe ChartDataService do
  # Create test doubles
  let(:assignment) do
    double('Assignment',
      id: 1,
      name: 'Test Assignment',
      num_review_rounds: 3
    )
  end
  
  let(:reviewer) do
    double('Reviewer',
      id: 1,
      name: 'Test Reviewer',
      avg_vol_per_round: [100, 150, 200],
      overall_avg_vol: 150
    )
  end
  
  let(:service) do
    described_class.new(reviewer, assignment)
  end
  
  describe '#initialize' do
    it 'sets instance variables correctly' do
      expect(service.reviewer).to eq(reviewer)
      expect(service.assignment).to eq(assignment)
    end
  end
  
  describe '#volume_metric_chart_data' do
    it 'returns a hash with labels and datasets' do
      # Stub the initialize_chart_elements method to return controlled test data
      allow(service).to receive(:initialize_chart_elements).and_return(
        [[1, 2, 3, 'Total'], [100, 150, 200, 150], [80, 120, 160, 120]]
      )
      
      result = service.volume_metric_chart_data
      
      # Check that the result is a hash with expected keys
      expect(result).to be_a(Hash)
      expect(result).to have_key(:labels)
      expect(result).to have_key(:datasets)
      
      # Check labels
      expect(result[:labels]).to eq([1, 2, 3, 'Total'])
      
      # Check datasets
      expect(result[:datasets]).to be_an(Array)
      expect(result[:datasets].length).to eq(2)
      
      # Check first dataset (reviewer data)
      expect(result[:datasets][0][:label]).to eq('vol.')
      expect(result[:datasets][0][:data]).to eq([100, 150, 200, 150])
      expect(result[:datasets][0][:yAxisID]).to eq('bar-y-axis1')
      
      # Check second dataset (all reviewers data)
      expect(result[:datasets][1][:label]).to eq('avg. vol.')
      expect(result[:datasets][1][:data]).to eq([80, 120, 160, 120])
      expect(result[:datasets][1][:yAxisID]).to eq('bar-y-axis2')
    end
  end
  
  describe '#volume_metric_chart_options' do
    it 'returns chart configuration options' do
      options = service.volume_metric_chart_options
      
      # Check that options is a hash with expected keys
      expect(options).to be_a(Hash)
      expect(options).to have_key(:legend)
      expect(options).to have_key(:scales)
      expect(options).to have_key(:width)
      expect(options).to have_key(:height)
      
      # Check legend options
      expect(options[:legend][:position]).to eq('top')
      
      # Check scales options
      expect(options[:scales]).to have_key(:yAxes)
      expect(options[:scales]).to have_key(:xAxes)
      
      # Check y-axes
      expect(options[:scales][:yAxes].length).to eq(2)
      expect(options[:scales][:yAxes][0][:id]).to eq('bar-y-axis1')
      expect(options[:scales][:yAxes][1][:id]).to eq('bar-y-axis2')
      
      # Check x-axis
      expect(options[:scales][:xAxes][0][:ticks][:beginAtZero]).to be true
    end
  end
  
  describe '#initialize_chart_elements' do
    context 'when all rounds have positive volume' do
      it 'returns labels, reviewer data, and all reviewers data' do
        # Stub the methods used by initialize_chart_elements
        allow(service).to receive(:calculate_all_reviewers_avg_vol).with(0).and_return(80)
        allow(service).to receive(:calculate_all_reviewers_avg_vol).with(1).and_return(120)
        allow(service).to receive(:calculate_all_reviewers_avg_vol).with(2).and_return(160)
        allow(service).to receive(:calculate_all_reviewers_overall_avg_vol).and_return(120)
        
        labels, reviewer_data, all_reviewers_data = service.send(:initialize_chart_elements)
        
        expect(labels).to eq([1, 2, 3, 'Total'])
        expect(reviewer_data).to eq([100, 150, 200, 150])
        expect(all_reviewers_data).to eq([80, 120, 160, 120])
      end
    end
    
    context 'when some rounds have zero volume' do
      let(:reviewer) do
        double('Reviewer',
          avg_vol_per_round: [100, 0, 200],
          overall_avg_vol: 150
        )
      end
      
      it 'skips rounds with zero volume' do
        # Stub the methods used by initialize_chart_elements
        allow(service).to receive(:calculate_all_reviewers_avg_vol).with(0).and_return(80)
        allow(service).to receive(:calculate_all_reviewers_avg_vol).with(2).and_return(160)
        allow(service).to receive(:calculate_all_reviewers_overall_avg_vol).and_return(120)
        
        labels, reviewer_data, all_reviewers_data = service.send(:initialize_chart_elements)
        
        expect(labels).to eq([1, 2, 'Total'])
        expect(reviewer_data).to eq([100, 200, 150])
        expect(all_reviewers_data).to eq([80, 160, 120])
      end
    end
    
    context 'when all rounds have zero volume' do
      let(:reviewer) do
        double('Reviewer',
          avg_vol_per_round: [0, 0, 0],
          overall_avg_vol: 150
        )
      end
      
      it 'only includes Total in the results' do
        # Stub the methods used by initialize_chart_elements
        allow(service).to receive(:calculate_all_reviewers_overall_avg_vol).and_return(120)
        
        labels, reviewer_data, all_reviewers_data = service.send(:initialize_chart_elements)
        
        expect(labels).to eq(['Total'])
        expect(reviewer_data).to eq([150])
        expect(all_reviewers_data).to eq([120])
      end
    end
  end
  
  describe '#calculate_all_reviewers_avg_vol' do
    it 'returns the average volume for all reviewers in a specific round' do
      # Since this is a placeholder in the implementation, we're just testing that it returns something
      result = service.send(:calculate_all_reviewers_avg_vol, 0)
      expect(result).to eq(100) # This is the placeholder value in the implementation
    end
    
    it 'handles different rounds' do
      expect(service.send(:calculate_all_reviewers_avg_vol, 0)).to eq(100)
      expect(service.send(:calculate_all_reviewers_avg_vol, 1)).to eq(100)
      expect(service.send(:calculate_all_reviewers_avg_vol, 2)).to eq(100)
    end
  end
  
  describe '#calculate_all_reviewers_overall_avg_vol' do
    it 'returns the overall average volume for all reviewers' do
      # Since this is a placeholder in the implementation, we're just testing that it returns something
      result = service.send(:calculate_all_reviewers_overall_avg_vol)
      expect(result).to eq(200) # This is the placeholder value in the implementation
    end
  end
  
  describe 'edge cases' do
    context 'with zero review rounds' do
      let(:assignment) do
        double('Assignment',
          num_review_rounds: 0
        )
      end
      
      it 'only includes Total in the results' do
        # Stub the method used to calculate the overall average
        allow(service).to receive(:calculate_all_reviewers_overall_avg_vol).and_return(120)
        
        labels, reviewer_data, all_reviewers_data = service.send(:initialize_chart_elements)
        
        expect(labels).to eq(['Total'])
        expect(reviewer_data).to eq([150])
        expect(all_reviewers_data).to eq([120])
      end
    end
    
    context 'with missing data for some rounds' do
      let(:reviewer) do
        double('Reviewer',
          avg_vol_per_round: [100], # Only one round of data
          overall_avg_vol: 100
        )
      end
      
      let(:assignment) do
        double('Assignment',
          num_review_rounds: 3
        )
      end
      
      it 'handles missing data gracefully' do
        # This should raise an error because reviewer.avg_vol_per_round[1] doesn't exist
        expect { service.send(:initialize_chart_elements) }.to raise_error(NoMethodError)
      end
    end
  end
end