# moves data of reviews in each round from a current round
module ReviewMappingChartsHelper
  def initialize_chart_elements(reviewer)
    round = 0
    labels = []
    reviewer_data = []
    all_reviewers_data = []
    avg_vol_per_round(reviewer, round, labels, reviewer_data, all_reviewers_data)
    labels.push 'Total'
    reviewer_data.push reviewer.overall_avg_vol
    all_reviewers_data.push @all_reviewers_overall_avg_vol
    [labels, reviewer_data, all_reviewers_data]
  end

  # display avg volume for all reviewers per round
  def avg_vol_per_round(reviewer, round, labels, reviewer_data, all_reviewers_data)
    @num_rounds.times do |rnd|
      next unless @all_reviewers_avg_vol_per_round[rnd] > 0
      round += 1
      labels.push round
      reviewer_data.push reviewer.avg_vol_per_round[rnd]
      all_reviewers_data.push @all_reviewers_avg_vol_per_round[rnd]
    end
  end

  # The data of all the reviews is displayed in the form of a bar chart
  def display_volume_metric_chart(reviewer)
    labels, reviewer_data, all_reviewers_data = initialize_chart_elements(reviewer)
    data = volume_metric_chart_data(labels, reviewer_data, all_reviewers_data)
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
    data = display_tagging_interval_chart_data(intervals, interval_mean)
    options = provide_tagging_options
    line_chart data, options
  end

  # Calculate mean, min, max, variance, and stand deviation for tagging intervals
  def calculate_key_chart_information(intervals)
    # if someone did not do any tagging in 30 seconds, then ignore this interval
    threshold = 30
    interval_precision = 2 # Round to 2 Decimal Places
    intervals = intervals.select { |v| v < threshold }
    metric_information(intervals, interval_precision)
    # if no Hash object is returned, the UI handles it accordingly
  end

  def metric_information(intervals, interval_precision)
    # Get Metrics once tagging intervals are available
    return nil if intervals.empty?

    metrics = {}
    # calculate various metric values
    metrics[:mean] = calculate_mean(intervals, interval_precision)
    metrics[:min] = intervals.min
    metrics[:max] = intervals.max
    metrics[:variance] = calculate_variance(intervals, metrics[:mean], interval_precision)
    metrics[:stand_dev] = calculate_standard_deviation(metrics[:variance], interval_precision)
    metrics
  end

  def calculate_mean(intervals, interval_precision)
    (intervals.reduce(:+) / intervals.size.to_f).round(interval_precision)
  end

  def calculate_variance(intervals, mean, interval_precision)
    sum = intervals.inject(0) { |accum, i| accum + (i - mean)**2 }
    (sum / intervals.size.to_f).round(interval_precision)
  end

  def calculate_standard_deviation(variance, interval_precision)
    Math.sqrt(variance).round(interval_precision)
  end
end
