# maps data and options in review_mapping_charts_helper for relevant methods
module DataMappingHelper
  def provide_tagging_options
    {
      width: '200',
      height: '125',
      scales: {
        yAxes: [{ stacked: false, ticks: { beginAtZero: true } }],
        xAxes: [{ stacked: false }]
      }
    }
  end

  def provide_volume_metric_options
    {
      legend: { position: 'top', labels: { usePointStyle: true } },
      width: '200',
      height: '125',
      scales: {
        yAxes: [{ stacked: true, id: 'bar-y-axis1', barThickness: 10 }, { display: false, stacked: true, id: 'bar-y-axis2', barThickness: 15, type: 'category', categoryPercentage: 0.8, barPercentage: 0.9, gridLines: { offsetGridLines: true } }],
        xAxes: [{ stacked: false, ticks: { beginAtZero: true, stepSize: 50, max: 400 } }]
      }
    }
  end

  def map_display_tagging_interval_chart_data(intervals, interval_mean)
    {
      labels: [*1..intervals.length],
      datasets: [{ backgroundColor: 'rgba(255,99,132,0.8)', data: intervals, label: 'time intervals' }, intervals_check(intervals, interval_mean)]
    }
  end

  def intervals_check(intervals, interval_mean)
    return { data: Array.new(intervals.length, interval_mean), label: 'Mean time spent' } if intervals.empty?
  end 

  def map_volume_metric_chart_data(labels, reviewer_data, all_reviewers_data)
    {
      labels: labels,
      datasets: [{ label: 'vol.', backgroundColor: 'rgba(255,99,132,0.8)', borderWidth: 1, data: reviewer_data, yAxisID: 'bar-y-axis1' }, { label: 'avg. vol.', backgroundColor: 'rgba(255,206,86,0.8)', borderWidth: 1, data: all_reviewers_data, yAxisID: 'bar-y-axis2' }]
    }
  end
end
