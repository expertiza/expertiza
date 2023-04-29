module ReviewChartHelper
    # moves data of reviews in each round from a current round
    def initialize_chart_elements(reviewer)
        labels, reviewer_data, all_reviewers_data = [], [], []
        @num_rounds.times do |rnd|
        next if @all_reviewers_avg_vol_per_round[rnd] <= 0
        labels << (rnd + 1)
        reviewer_data << reviewer.avg_vol_per_round[rnd]
        all_reviewers_data << @all_reviewers_avg_vol_per_round[rnd]
        end
        labels << 'Total'
        reviewer_data << reviewer.overall_avg_vol
        all_reviewers_data << @all_reviewers_overall_avg_vol
        [labels, reviewer_data, all_reviewers_data]
    end

    # The data of all the reviews is displayed in the form of a bar chart
    def display_volume_metric_chart(reviewer)
        labels, reviewer_data, all_reviewers_data = initialize_chart_elements(reviewer)
        data = {
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
        options = {
        legend: { position: 'top', labels: { usePointStyle: true } },
        width: '200', height: '125',
        scales: {
            yAxes: [
            { stacked: true, id: 'bar-y-axis1', barThickness: 10 },
            {
                display: false, stacked: true, id: 'bar-y-axis2',
                barThickness: 15, type: 'category',
                categoryPercentage: 0.8, barPercentage: 0.9,
                gridLines: { offsetGridLines: true }
            }
            ],
            xAxes: [
            { stacked: false, ticks: { beginAtZero: true, stepSize: 50, max: 400 } }
            ]
        }
        }
        horizontal_bar_chart(data, options)
    end

    # E2082 Generate chart for review tagging time intervals
    def display_tagging_interval_chart(intervals)
        threshold = 30
        intervals = intervals.select { |v| v < threshold }
        interval_mean = intervals.sum / intervals.size.to_f unless intervals.empty?
        data = {
        labels: [*1..intervals.length],
        datasets: [
            { backgroundColor: 'rgba(255,99,132,0.8)', data: intervals, label: 'time intervals' },
            *(!intervals.empty? && [{ data: [interval_mean] * intervals.length, label: 'Mean time spent' }])
        ]
        }
        options = {
        width: '200', height: '125',
        scales: { yAxes: [{ stacked: false, ticks: { beginAtZero: true } }], xAxes: [{ stacked: false }] }
        }
        line_chart(data, options)
    end


    # Calculate mean for tagging intervals
    def calculate_mean(intervals, interval_precision)
        mean = intervals.sum / intervals.size.to_f
        mean.round(interval_precision)
    end
    
    # Calculate variance for tagging intervals
    def calculate_variance(intervals, interval_precision)
        mean = intervals.sum / intervals.size.to_f
        variance = intervals.sum { |v| (v - mean) ** 2 } / intervals.size.to_f
        variance.round(interval_precision)
    end
    
    # Calculate standard deviation for tagging intervals
    def calculate_standard_deviation(intervals, interval_precision)
        mean = intervals.sum / intervals.size.to_f
        variance = intervals.sum { |v| (v - mean) ** 2 } / intervals.size.to_f
        Math.sqrt(variance).round(interval_precision)
    end
    


    # Calculate mean, min, max, variance, and stand deviation for tagging intervals
    def calculate_key_chart_information(intervals)
        threshold = 30
        interval_precision = 2
        valid_intervals = intervals.select { |v| v < threshold }
        return nil if valid_intervals.empty?
    
        {
            mean: calculate_mean(valid_intervals, interval_precision),
            min: valid_intervals.min,
            max: valid_intervals.max,
            variance: calculate_variance(valid_intervals, interval_precision),
            stand_dev: calculate_standard_deviation(valid_intervals, interval_precision)
        }
    end
  end