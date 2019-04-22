<<<<<<< HEAD
module GradesGithubHelper

	def display_github_metrics(parsed_data, authors, dates)
=======
module GithubMetricsHelper
  def display_github_metrics(parsed_data, authors, dates)
>>>>>>> 640ecd5ec679a7829a606c7e2de946e62636fd99
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
<<<<<<< HEAD
      labels: dates,
      datasets: data_array
=======
        labels: dates,
        datasets: data_array
>>>>>>> 640ecd5ec679a7829a606c7e2de946e62636fd99
    }
    horizontal_bar_chart data, chart_options
  end

<<<<<<< HEAD

  def chart_options
    {
      responsive: true,
      maintainAspectRatio: false,
      width: 100,
      height: 100,
      scales: graph_scales
=======
  def chart_options
    {
        responsive: true,
        maintainAspectRatio: false,
        width: 100,
        height: 100,
        scales: graph_scales
>>>>>>> 640ecd5ec679a7829a606c7e2de946e62636fd99
    }
  end

  def graph_scales
    {
<<<<<<< HEAD
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
=======
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
>>>>>>> 640ecd5ec679a7829a606c7e2de946e62636fd99
