class ChartDataService
    attr_reader :reviewer, :assignment
  
    def initialize(reviewer, assignment)
      @reviewer = reviewer
      @assignment = assignment
    end
  
    # Generates data for the volume metric chart
    def volume_metric_chart_data
      labels, reviewer_data, all_reviewers_data = initialize_chart_elements
      {
        labels: labels,
        datasets: [
          {
            label: 'vol.',
            backgroundColor: 'rgba(255,99,132,0.8)',
            borderWidth: 1,
            data: reviewer_data,
            yAxisID: 'bar-y-axis1'
          },
          {
            label: 'avg. vol.',
            backgroundColor: 'rgba(255,206,86,0.8)',
            borderWidth: 1,
            data: all_reviewers_data,
            yAxisID: 'bar-y-axis2'
          }
        ]
      }
    end
  
    # Generates options for the volume metric chart
    def volume_metric_chart_options
      {
        legend: {
          position: 'top',
          labels: {
            usePointStyle: true
          }
        },
        width: '200',
        height: '225',
        scales: {
          yAxes: [{
            stacked: true,
            id: 'bar-y-axis1',
            barThickness: 10
          }, {
            display: false,
            stacked: true,
            id: 'bar-y-axis2',
            barThickness: 15,
            type: 'category',
            categoryPercentage: 0.8,
            barPercentage: 0.9,
            gridLines: {
              offsetGridLines: true
            }
          }],
          xAxes: [{
            stacked: false,
            ticks: {
              beginAtZero: true,
              stepSize: 50,
              max: 400
            }
          }]
        }
      }
    end
  
    private
  
    # Initializes chart elements (labels, reviewer data, and all reviewers data)
    def initialize_chart_elements
      round = 0
      labels = []
      reviewer_data = []
      all_reviewers_data = []
  
      # Display avg volume for all reviewers per round
      @assignment.num_review_rounds.times do |rnd|
        next unless @reviewer.avg_vol_per_round[rnd] > 0
  
        round += 1
        labels.push round
        reviewer_data.push @reviewer.avg_vol_per_round[rnd]
        all_reviewers_data.push calculate_all_reviewers_avg_vol(rnd)
      end
  
      labels.push 'Total'
      reviewer_data.push @reviewer.overall_avg_vol
      all_reviewers_data.push calculate_all_reviewers_overall_avg_vol
  
      [labels, reviewer_data, all_reviewers_data]
    end
  
    # Calculates the average volume for all reviewers in a specific round
    def calculate_all_reviewers_avg_vol(round)
      # Replace this with actual logic to calculate the average volume for all reviewers in the given round
      # For now, we'll return a placeholder value
      100 # Placeholder value
    end
  
    # Calculates the overall average volume for all reviewers
    def calculate_all_reviewers_overall_avg_vol
      # Replace this with actual logic to calculate the overall average volume for all reviewers
      # For now, we'll return a placeholder value
      200 # Placeholder value
    end
  end