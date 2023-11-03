module ReviewMappingChartsHelper
  # moves data of reviews in each round from a current round
  def initialize_chart_elements(reviewer)
    round = 0
    labels = []
    reviewer_data = []
    all_reviewers_data = []

    # display avg volume for all reviewers per round
    @num_rounds.times do |rnd|
      next unless @all_reviewers_avg_vol_per_round[rnd] > 0

      round += 1
      labels.push round
      reviewer_data.push reviewer.avg_vol_per_round[rnd]
      all_reviewers_data.push @all_reviewers_avg_vol_per_round[rnd]
    end

    labels.push 'Total'
    reviewer_data.push reviewer.overall_avg_vol
    all_reviewers_data.push @all_reviewers_overall_avg_vol
    [labels, reviewer_data, all_reviewers_data]
  end

  # The data of all the reviews is displayed in the form of a bar chart
  def display_volume_metric_chart(reviewer)
    labels, reviewer_data, all_reviewers_data = initialize_chart_elements(reviewer)
    data = map_volume_metric_chart_data(labels, reviewer_data, all_reviewers_data)
    options = provide_volume_metric_options
    horizontal_bar_chart data, options
  end

  # E2082 Generate chart for review tagging time intervals
  def display_tagging_interval_chart(intervals)
    # if someone did not do any tagging in 30 seconds, then ignore this interval
    threshold = 30
    intervals = intervals.select { |v| v < threshold }
    unless intervals.empty?
      interval_mean = intervals.reduce(:+) / intervals.size.to_f
    end
    # build the parameters for the chart
    data = map_display_tagging_interval_chart_data(intervals, interval_mean)
    options = provide_tagging_options
    line_chart data, options
  end

  # Calculate mean, min, max, variance, and stand deviation for tagging intervals
  def calculate_key_chart_information(intervals)
    # if someone did not do any tagging in 30 seconds, then ignore this interval
    threshold = 30
    interval_precision = 2 # Round to 2 Decimal Places
    intervals = intervals.select { |v| v < threshold }

    # Get Metrics once tagging intervals are available
    unless intervals.empty?
      metrics = {}
      metrics[:mean] = (intervals.reduce(:+) / intervals.size.to_f).round(interval_precision)
      metrics[:min] = intervals.min
      metrics[:max] = intervals.max
      sum = intervals.inject(0) { |accum, i| accum + (i - metrics[:mean])**2 }
      metrics[:variance] = (sum / intervals.size.to_f).round(interval_precision)
      metrics[:stand_dev] = Math.sqrt(metrics[:variance]).round(interval_precision)
      metrics
    end
    # if no Hash object is returned, the UI handles it accordingly
  end
end
