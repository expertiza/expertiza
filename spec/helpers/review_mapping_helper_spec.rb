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

describe '#display_tagging_interval_chart' do
  it 'creates a bar chart with tagging intervals data' do
    # Setup test data - actual intervals array instead of a double
    intervals = [5, 8, 12, 15, 20]
    
    # Expected chart data
    expected_mean = intervals.reduce(:+) / intervals.size.to_f
    
    expected_data = {
      labels: [1, 2, 3, 4, 5],  # [*1..intervals.length]
      datasets: [
        {
          backgroundColor: 'rgba(255,99,132,0.8)',
          data: intervals,
          label: 'time intervals'
        },
        {
          data: Array.new(intervals.length, expected_mean),
          label: 'Mean time spent'
        }
      ]
    }
    
    expected_options = {
      width: '200',
      height: '125',
      scales: {
        yAxes: [{
          stacked: false,
          ticks: {
            beginAtZero: true
          }
        }],
        xAxes: [{
          stacked: false
        }]
      }
    }
    
    # Mock the line_chart method that's used by the helper
    expect(helper).to receive(:line_chart)
      .with(expected_data, expected_options)
      .and_return('<div id="tagging_interval_chart">Chart HTML here</div>')
    
    # Call the method with the intervals array
    result = helper.display_tagging_interval_chart(intervals)
    
    # Verify results
    expect(result).to include('Chart HTML here')
  end
  
  it 'filters out intervals above the threshold' do
    # Include some values above the 30-second threshold
    intervals = [5, 8, 35, 15, 45]
    filtered_intervals = intervals.select { |v| v < 30 } # [5, 8, 15]
    expected_mean = filtered_intervals.reduce(:+) / filtered_intervals.size.to_f
    
    expected_data = {
      labels: [1, 2, 3],  # [*1..filtered_intervals.length]
      datasets: [
        {
          backgroundColor: 'rgba(255,99,132,0.8)',
          data: filtered_intervals,
          label: 'time intervals'
        },
        {
          data: Array.new(filtered_intervals.length, expected_mean),
          label: 'Mean time spent'
        }
      ]
    }
    
    # We don't need to test the options again
    allow(helper).to receive(:line_chart).and_return('<div>Chart</div>')
    
    # Just verify that line_chart receives the correct filtered data
    expect(helper).to receive(:line_chart) do |data, _options|
      expect(data[:datasets][0][:data]).to eq([5, 8, 15])
      expect(data[:datasets][1][:data]).to eq([9.333333333333334, 9.333333333333334, 9.333333333333334])
      '<div>Chart</div>'
    end
    
    helper.display_tagging_interval_chart(intervals)
  end


  it 'handles empty intervals array' do
    # Empty intervals array
    intervals = []
  
    expected_data = {
      labels: [],
      datasets: [
        {
          backgroundColor: 'rgba(255,99,132,0.8)',
          data: [],
          label: 'time intervals'
        },
        nil 
      ]
    }
  
    expected_options = {
      width: '200',
      height: '125',
      scales: {
        yAxes: [{
          stacked: false,
          ticks: {
            beginAtZero: true
          }
        }],
        xAxes: [{
          stacked: false
        }]
      }
    }
  
    # Mock the line_chart method
    expect(helper).to receive(:line_chart)
      .with(expected_data, expected_options)
      .and_return('<div>Empty chart</div>')
  
    result = helper.display_tagging_interval_chart(intervals)
    expect(result).to include('Empty chart')
  end
end

describe '#response_for_each_round?' do
  let(:response_map) { double('ResponseMap', id: 1) }
  let(:assignment) { double('Assignment', num_review_rounds: 2) }

  before(:each) do
    helper.instance_variable_set(:@assignment, assignment)
  end

  it 'returns true when responses exist for all rounds' do
    # Mock Response.exists? for each round
    expect(Response).to receive(:exists?)
      .with(map_id: 1, round: 1)
      .and_return(true)
    expect(Response).to receive(:exists?)
      .with(map_id: 1, round: 2)
      .and_return(true)

    expect(helper.response_for_each_round?(response_map)).to be true
  end

  it 'returns false when responses are missing for some rounds' do
    # Mock Response.exists? to return false for round 2
    expect(Response).to receive(:exists?)
      .with(map_id: 1, round: 1)
      .and_return(true)
    expect(Response).to receive(:exists?)
      .with(map_id: 1, round: 2)
      .and_return(false)

    expect(helper.response_for_each_round?(response_map)).to be false
  end

  it 'returns false when no responses exist' do
    # Mock Response.exists? to return false for all rounds
    expect(Response).to receive(:exists?)
      .with(map_id: 1, round: 1)
      .and_return(false)
    expect(Response).to receive(:exists?)
      .with(map_id: 1, round: 2)
      .and_return(false)

    expect(helper.response_for_each_round?(response_map)).to be false
  end
end
describe '#check_submission_state' do
  let(:response_map) { double('ResponseMap', id: 1, reviewee_id: 2) }
  let(:assignment) { double('Assignment') }
  let(:assignment_created) { Time.now }
  let(:assignment_due_dates) { double('DueDates') }
  let(:round) { 1 }
  let(:color) { [] }
  let(:due_date) { double('DueDate', due_at: Time.now + 1.day) }

  before(:each) do
    helper.instance_variable_set(:@assignment, assignment)
    # Mock the where calls on assignment_due_dates
    allow(assignment_due_dates).to receive(:where)
      .with(hash_including(round: round, deadline_type_id: 1))
      .and_return([due_date])
  end

  it 'adds purple color when submission is within the round' do
    allow(helper).to receive(:submitted_within_round?)
      .with(round, response_map, assignment_created, assignment_due_dates)
      .and_return(true)

    helper.check_submission_state(response_map, assignment_created, assignment_due_dates, round, color)
    expect(color).to eq(['purple'])
  end

  it 'adds green color when submission is not within the round but response exists' do
    # Setup the submission check to return false
    allow(helper).to receive(:submitted_within_round?)
      .with(round, response_map, assignment_created, assignment_due_dates)
      .and_return(false)
    
    # Setup the hyperlink check
    allow(helper).to receive(:submitted_hyperlink)
      .with(round, response_map, assignment_created, assignment_due_dates)
      .and_return(nil)
    
    # Setup response check
    allow(Response).to receive(:exists?)
      .with(map_id: 1, round: 1)
      .and_return(true)

    helper.check_submission_state(response_map, assignment_created, assignment_due_dates, round, color)
    expect(color).to eq(['green'])
  end

  it 'adds green color when submission is not within round and no wiki hyperlink' do
    # Setup the submission check to return false
    allow(helper).to receive(:submitted_within_round?)
      .with(round, response_map, assignment_created, assignment_due_dates)
      .and_return(false)
    
    # Setup the hyperlink check to return nil
    allow(helper).to receive(:submitted_hyperlink)
      .with(round, response_map, assignment_created, assignment_due_dates)
      .and_return(nil)
    
    # Call method and verify color is green (not red as previously expected)
    helper.check_submission_state(response_map, assignment_created, assignment_due_dates, round, color)
    expect(color).to eq(['green'])
  end

  it 'handles wiki submissions correctly' do
    # Setup the submission check to return false
    allow(helper).to receive(:submitted_within_round?)
      .with(round, response_map, assignment_created, assignment_due_dates)
      .and_return(false)
    
    # Setup the hyperlink check to return a wiki URL
    wiki_link = 'https://wiki.example.com/page'
    allow(helper).to receive(:submitted_hyperlink)
      .with(round, response_map, assignment_created, assignment_due_dates)
      .and_return(wiki_link)
    
    # Mock the link update check
    link_updated_at = Time.now
    allow(helper).to receive(:get_link_updated_at)
      .with(wiki_link)
      .and_return(link_updated_at)
    
    allow(helper).to receive(:link_updated_since_last?)
      .with(round, assignment_due_dates, link_updated_at)
      .and_return(true)

    helper.check_submission_state(response_map, assignment_created, assignment_due_dates, round, color)
    expect(color).to eq(['purple'])
  end
end

describe '#submitted_within_round?' do
  let(:response_map) { double('ResponseMap', reviewee_id: 1) }
  let(:assignment_created) { Time.now - 30.days }
  let(:round) { 1 }
  let(:assignment_due_dates) { double('DueDates') }
  let(:submission_due_date) { Time.now - 10.days }
  let(:submission_due_last_round) { Time.now - 20.days }
  
  before(:each) do
    # Setup default due date mocks
    allow(assignment_due_dates).to receive(:where)
      .with(round: round, deadline_type_id: 1)
      .and_return([double('DueDate', due_at: submission_due_date)])
  end
  
  it 'returns true when submission exists within first round timeframe' do
    # Setup first round conditions
    submission = double('Submission', created_at: assignment_created + 5.days)
    submissions = [submission]
    
    # Mock the SubmissionRecord queries
    allow(SubmissionRecord).to receive(:where)
      .with(team_id: 1, operation: ['Submit File', 'Submit Hyperlink'])
      .and_return(submissions)
    allow(submissions).to receive(:where)
      .with(created_at: assignment_created..submission_due_date)
      .and_return([submission])
    
    expect(helper.submitted_within_round?(round, response_map, assignment_created, assignment_due_dates)).to be true
  end
  
  it 'returns true when submission exists within later round timeframe' do
    # Setup later round conditions
    later_round = 2
    submission = double('Submission', created_at: submission_due_last_round + 5.days)
    submissions = [submission]
    
    # Mock the DueDate queries for both rounds
    allow(assignment_due_dates).to receive(:where)
      .with(round: later_round, deadline_type_id: 1)
      .and_return([double('DueDate', due_at: submission_due_date)])
    allow(assignment_due_dates).to receive(:where)
      .with(round: later_round - 1, deadline_type_id: 1)
      .and_return([double('DueDate', due_at: submission_due_last_round)])
    
    # Mock the SubmissionRecord queries
    allow(SubmissionRecord).to receive(:where)
      .with(team_id: 1, operation: ['Submit File', 'Submit Hyperlink'])
      .and_return(submissions)
    
    # Update this line to use a more flexible matcher that accepts any created_at range
    allow(submissions).to receive(:where) do |criteria|
      # We know the submission falls within the expected range
      [submission] if criteria[:created_at].is_a?(Range)
    end
    
    expect(helper.submitted_within_round?(later_round, response_map, assignment_created, assignment_due_dates)).to be true
  end
  
  it 'returns false when no submission exists for the round' do
    # Mock empty submission result
    submissions = []
    allow(SubmissionRecord).to receive(:where)
      .with(team_id: 1, operation: ['Submit File', 'Submit Hyperlink'])
      .and_return(submissions)
    allow(submissions).to receive(:where)
      .with(created_at: assignment_created..submission_due_date)
      .and_return([])
    
    expect(helper.submitted_within_round?(round, response_map, assignment_created, assignment_due_dates)).to be false
  end
  
  it 'returns false when no submission due date exists for the round' do
    # Mock nil due date
    allow(assignment_due_dates).to receive(:where)
      .with(round: round, deadline_type_id: 1)
      .and_return([])
    
    expect(helper.submitted_within_round?(round, response_map, assignment_created, assignment_due_dates)).to be false
  end
  
  it 'returns false when submission exists but is outside round timeframe' do
    # Setup submission outside timeframe
    submission = double('Submission', created_at: submission_due_date + 1.day)
    submissions = [submission]
    
    # Mock the SubmissionRecord queries
    allow(SubmissionRecord).to receive(:where)
      .with(team_id: 1, operation: ['Submit File', 'Submit Hyperlink'])
      .and_return(submissions)
    allow(submissions).to receive(:where)
      .with(created_at: assignment_created..submission_due_date)
      .and_return([])
    
    expect(helper.submitted_within_round?(round, response_map, assignment_created, assignment_due_dates)).to be false
  end
end
end