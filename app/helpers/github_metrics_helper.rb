module GithubMetricsHelper
  def display_github_metrics(parsed_data, authors, dates)
    data_array = []
    color = %w[red yellow blue gray green magenta]
    i = 0
    authors.each do |author|
      data_object = {}
      data_object['label'] = author
      data_object['data'] = parsed_data[author].values
      data_object['backgroundColor'] = color[i]
      data_object['borderWidth'] = 1
      data_array.push(data_object)
      i += 1
      i = 0 if i > 5
    end

    data = {
        labels: dates,
        datasets: data_array
    }
    horizontal_bar_chart data, chart_options
  end


  def chart_options
    {
        responsive: true,
        maintainAspectRatio: false,
        width: 100,
        height: 100,
        scales: graph_scales
    }
  end

  def graph_scales
    {
        yAxes: [{
                    stacked: true,
                    ticks: {
                        beginAtZero: true
                    },
                    barThickness: 30,
                    scaleLabel: {
                        display: true,
                        labelString: 'Submission timeline'
                    }
                }],
        xAxes: [{
                    stacked: true,
                    ticks: {
                        beginAtZero: true
                    },
                    barThickness: 30,
                    scaleLabel: {
                        display: true,
                        labelString: '# of Commits'
                    }
                }]
    }

  end
end
