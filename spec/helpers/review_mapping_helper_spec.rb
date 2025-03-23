require 'rails_helper'

describe ReviewMappingHelper do
  describe '#get_certain_review_and_feedback_response_map' do
    it 'sets feedback_response_maps and review_responses instance variables' do
      # Setup test data
      author = double('Participant', id: 1, user_id: 1)
      team_id = 1
      review_response_map_id = 1
      response = double('Response', id: 1)
      feedback_response_map = double('FeedbackResponseMap', id: 1)
      
      # Set up required instance variables
      helper.instance_variable_set(:@all_review_response_ids, [1])
      helper.instance_variable_set(:@id, 1)
      
      # Create expectations for called methods
      expect(TeamsUser).to receive(:team_id).with(1, 1).and_return(team_id)
      expect(ReviewResponseMap).to receive(:where)
                                .with(['reviewed_object_id = ? and reviewee_id = ?', 1, team_id])
                                .and_return(double(pluck: [review_response_map_id]))
      expect(Response).to receive(:where)
                        .with(['map_id IN (?)', [review_response_map_id]])
                        .and_return([response])
      expect(FeedbackResponseMap).to receive(:where)
                                   .with(['reviewed_object_id IN (?) and reviewer_id = ?', [1], 1])
                                   .and_return([feedback_response_map])
      
      # Call the method
      helper.get_certain_review_and_feedback_response_map(author)
      
      # Verify instance variables are set correctly
      expect(helper.instance_variable_get(:@feedback_response_maps)).to eq([feedback_response_map])
      expect(helper.instance_variable_get(:@team_id)).to eq(team_id)
      expect(helper.instance_variable_get(:@review_response_map_ids)).to eq([review_response_map_id])
      expect(helper.instance_variable_get(:@review_responses)).to eq([response])
      expect(helper.instance_variable_get(:@rspan)).to eq(1)
    end
  end

  describe '#initialize_chart_elements' do
    it 'skips rounds with zero volume' do
      # Setup test data
      reviewer = double('ReviewMetricsQuery', avg_vol_per_round: [0, 10, 0, 15])
      assignment = double('Assignment', num_review_rounds: 4)
      
      # Set up required instance variables
      helper.instance_variable_set(:@assignment, assignment)
      helper.instance_variable_set(:@num_rounds, 4)
      helper.instance_variable_set(:@all_reviewers_avg_vol_per_round, [3.0, 5.0, 8.0, 10.0])
      helper.instance_variable_set(:@all_reviewers_overall_avg_vol, 15.0)
      
      # Create a mock ChartInitializationService that returns expected values
      chart_service = double('ChartInitializationService')
      expect(ChartInitializationService).to receive(:new)
        .with(reviewer, 4, [3.0, 5.0, 8.0, 10.0], 15.0)
        .and_return(chart_service)
      
      # Define expected return values
      expected_labels = [1, 3, 'Total']
      expected_reviewer_data = [10, 15, 25]
      expected_all_reviewers_data = [5.0, 10.0, 15.0]
      
      # Mock the initialize_chart_elements method on the service
      expect(chart_service).to receive(:initialize_chart_elements)
        .and_return([expected_labels, expected_reviewer_data, expected_all_reviewers_data])
      
      # Call the method
      labels, reviewer_data, all_reviewers_data = helper.initialize_chart_elements(reviewer)
      
      # Verify the chart elements
      expect(labels).to eq(expected_labels)
      expect(reviewer_data).to eq(expected_reviewer_data)
      expect(all_reviewers_data).to eq(expected_all_reviewers_data)
    end
  end
  describe '#create_report_table_header' do
    it 'renders the report table header partial with given headers' do
      # Setup test data
      headers = { name: "Name", score: "Score" }
      
      # Expect the render method to be called with the right parameters
      expect(helper).to receive(:render)
                      .with(partial: 'report_table_header', locals: { headers: headers })
                      .and_return('rendered table header')
      
      # Call the method
      result = helper.create_report_table_header(headers)
      
      # Verify the result
      expect(result).to eq('rendered table header')
    end
    
    it 'renders the report table header with default headers when none provided' do
      # Expect the render method to be called with empty headers
      expect(helper).to receive(:render)
                      .with(partial: 'report_table_header', locals: { headers: {} })
                      .and_return('rendered default table header')
      
      # Call the method with no arguments
      result = helper.create_report_table_header
      
      # Verify the result
      expect(result).to eq('rendered default table header')
    end
  end

  describe '#get_css_style_for_calibration_report' do
    it 'returns the correct CSS class for differences 0-3' do
      expect(helper.get_css_style_for_calibration_report(0)).to eq('c5')
      expect(helper.get_css_style_for_calibration_report(1)).to eq('c4')
      expect(helper.get_css_style_for_calibration_report(2)).to eq('c3')
      expect(helper.get_css_style_for_calibration_report(3)).to eq('c2')
    end
  
    it 'returns the correct CSS class for negative differences' do
      expect(helper.get_css_style_for_calibration_report(-1)).to eq('c4')
      expect(helper.get_css_style_for_calibration_report(-2)).to eq('c3')
      expect(helper.get_css_style_for_calibration_report(-3)).to eq('c2')
    end
  
    it 'returns c1 class for differences greater than 3 or less than -3' do
      expect(helper.get_css_style_for_calibration_report(4)).to eq('c1')
      expect(helper.get_css_style_for_calibration_report(10)).to eq('c1')
      expect(helper.get_css_style_for_calibration_report(-4)).to eq('c1')
      expect(helper.get_css_style_for_calibration_report(-10)).to eq('c1')
    end
  end
describe '#get_data_for_review_report' do
  it 'returns response maps and rspan for a given reviewer and reviewed object' do
    # Setup test data
    reviewer_id = 1
    reviewed_object_id = 2
    type = "ReviewResponseMap"
    assignment = double("Assignment", id: 3)
    
    # Expected return values
    response_maps = [double("ResponseMap", id: 1)]
    rspan = 5
    
    # Create mock for the ReviewReportService
    review_report_service = double("ReviewReportService")
    expect(ReviewReportService).to receive(:new).with(assignment).and_return(review_report_service)
    expect(review_report_service).to receive(:get_data_for_review_report)
                                .with(reviewed_object_id, reviewer_id, type, assignment)
                                .and_return([response_maps, rspan])
    
    # Call the method
    result_maps, result_rspan = helper.get_data_for_review_report(reviewed_object_id, reviewer_id, type, assignment)
    
    # Verify results
    expect(result_maps).to eq(response_maps)
    expect(result_rspan).to eq(rspan)
  end
end
describe '#display_volume_metric_chart' do
  it 'creates a bar chart with reviewer and all reviewers data' do
    # Setup test data
    reviewer = double('ReviewMetricsQuery')
    assignment = double('Assignment')
    
    # Expected chart data
    chart_data = {
      labels: [1, 2, 'Total'],
      datasets: [
        {
          label: 'Reviewer',
          data: [10, 15, 25],
          backgroundColor: 'rgba(255,99,132,0.8)'
        },
        {
          label: 'All reviewers',
          data: [8, 12, 20],
          backgroundColor: 'rgba(54,162,235,0.8)'
        }
      ]
    }
    
    # Mock the chart data service
    chart_data_service = double('ChartDataService')
    expect(ChartDataService).to receive(:new)
      .with(reviewer, assignment)
      .and_return(chart_data_service)
    
    expect(chart_data_service).to receive(:volume_metric_chart_data).and_return(chart_data)
    expect(chart_data_service).to receive(:volume_metric_chart_options).and_return({responsive: true})
    
    # Set up required instance variables
    helper.instance_variable_set(:@assignment, assignment)
    
    # Mock the bar_chart method that's likely used by the helper
    expect(helper).to receive(:bar_chart)
      .with(chart_data, {responsive: true})
      .and_return('<div id="volume_metric_chart">Chart HTML here</div>')
    
    # Call the method with the reviewer parameter
    result = helper.display_volume_metric_chart(reviewer)
    
    # Verify results - check that the result contains expected content
    expect(result).to include('Chart HTML here')
  end
end

describe '#get_team_color' do
  let(:response_map) { double('ResponseMap', id: 1, reviewed_object_id: 1, reviewee_id: 2) }
  let(:reviewer) { double('Reviewer', review_grade: nil) }
  
  before do
    assignment = double('Assignment', created_at: Time.now - 10.days, num_review_rounds: 2)
    helper.instance_variable_set(:@assignment, assignment)
    allow(response_map).to receive(:reviewer).and_return(reviewer)
    # Create test data for the detailed implementation
    @assignment_created = assignment.created_at
    @due_dates = double('DueDates')
    allow(DueDate).to receive(:where).and_return(@due_dates)
  end

  context 'when calling the 1-argument version' do
    it 'returns red if response does not exist' do
      allow(Response).to receive(:exists?).with(map_id: response_map.id).and_return(false)
      expect(helper.get_team_color(response_map)).to eq('red')
    end
    
    it 'returns brown if reviewer has review grade' do
      allow(Response).to receive(:exists?).with(map_id: response_map.id).and_return(true)
      allow(reviewer).to receive(:review_grade).and_return('some_grade')
      expect(helper.get_team_color(response_map)).to eq('brown')
    end
    
    it 'returns blue if response exists for each round' do
      allow(Response).to receive(:exists?).with(map_id: response_map.id).and_return(true)
      allow(helper).to receive(:response_for_each_round?).with(response_map).and_return(true)
      expect(helper.get_team_color(response_map)).to eq('blue')
    end
    
    it 'calls the 3-argument version when needed' do
      # Setup for the first method that calls the second method
      allow(Response).to receive(:exists?).with(map_id: response_map.id).and_return(true)
      allow(helper).to receive(:response_for_each_round?).with(response_map).and_return(false)
      
      # Create expectation for the second method to be called with specific arguments
      expect(helper).to receive(:get_team_color)
        .with(response_map, @assignment_created, @due_dates)
        .once
        .and_return('purple')
        
      # Now call the first method and check it returns what the second method returned
      expect(helper.get_team_color(response_map)).to eq('purple')
    end
  end
  
  context 'when calling the 3-argument version directly' do
    it 'applies check_submission_state for each round and returns the last color' do
      color_array = []
      
      # Mock the check_submission_state method to update the color array
      expect(helper).to receive(:check_submission_state)
        .with(response_map, @assignment_created, @due_dates, 1, color_array)
        .once
        .and_return(color_array << 'green')
        
      expect(helper).to receive(:check_submission_state)
        .with(response_map, @assignment_created, @due_dates, 2, color_array)
        .once
        .and_return(color_array << 'purple')
      
      # Call the 3-argument version directly
      result = helper.get_team_color(response_map, @assignment_created, @due_dates)
      
      # Verify the result is the last color from the array
      expect(result).to eq('purple')
    end
  end
end





end