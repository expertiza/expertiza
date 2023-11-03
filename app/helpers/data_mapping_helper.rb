module DataMappingHelper
  def provide_tagging_options
    options = {
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
  end

  def provide_volume_metric_options
    options = {
      legend: {
        position: 'top',
        labels: {
          usePointStyle: true
        }
      },
      width: '200',
      height: '125',
      scales: {
        yAxes: [
          { stacked: true,
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
        xAxes: [
          {
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

  def map_display_tagging_interval_chart_data(intervals)
    data = {
      labels: [*1..intervals.length],
      datasets: [
        {
          backgroundColor: 'rgba(255,99,132,0.8)',
          data: intervals,
          label: 'time intervals'
        },
        unless intervals.empty?
          {
            data: Array.new(intervals.length, interval_mean),
            label: 'Mean time spent'
          }
        end
      ]
    }
  end

  def map_volume_metric_chart_data(labels,reviewer_data,all_reviewers_data)
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
  end
end