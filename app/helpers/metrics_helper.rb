module MetricsHelper
  # Fall 2018, E1858
  # Creates the bar graph for the github metrics data.
  # Links the authors with their github data and assigns
  # them a color. Currently supports up to 6 different colors and will
  # loop if it goes over.
  def display_github_metrics(parsed_data, authors, dates)
    data_array = []
    color = %w[red yellow blue gray green magenta]
    i = 0
    authors.each do |author|
      data_object = {}
      data_object['label'] = author[0]
      data_object['data'] = parsed_data[author[0]].values
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

  def display_totals_piechart(parsed_data, authors, dates)
    data_array = []
    color = %w[ff0000 ffff00 0000ff aaaaaa 00ff00 ff00ff]
    i = 0
    authors.each do |author|
      data_object = {}
      data_object[:author] = author[0]
      data_object[:commits] = parsed_data[author[0]].values.inject(0) {|sum, value| sum += value}
      data_object[:color] = color[i]
      data_array.push(data_object)
      i += 1
      i = 0 if i > 4
    end

     link = nil
    GoogleChart::PieChart.new('600x300', '# Commits By Author', false) do |pc|
      data_array.each do |datapoint|
        label = datapoint[:author] + " (" + datapoint[:commits].to_s + ")"
        pc.data label, datapoint[:commits], datapoint[:color]
      end
      link = pc.to_url
    end

      link

  end

  # Fall 2018, E1858
  # Defines the general settings of the github metrics chart
  def chart_options
    {
      responsive: true,
      maintainAspectRatio: false,
      width: 100,
      height: 100,
      scales: graph_scales
    }
  end

  # Fall 2018, E1858
  # Defines the labels and display of the data on the github metrics chart
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
