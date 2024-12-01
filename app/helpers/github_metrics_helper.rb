module GithubMetricsHelper
  include Chartjs::ChartHelpers::Implicit

  # Creates the bar graph for the GitHub metrics data.
  # Links the authors with their GitHub data and assigns
  # them a color. Supports up to 6 different colors and will loop if it goes over.
  def display_github_metrics(parsed_data, authors, dates)
    data_array = []
    color = %w[#4e79a7 #f28e2b #e15759 #76b7b2 #59a14f #edc948 #af7aa1 #ff9da7]
    i = 0
    authors.each do |author|
      github_association = GithubAssociation.find_by_github_user(author[1])
      expertiza_username = GithubAssociation.find_by_github_user(author[1]) ? GithubAssociation.find_by_github_user(author[1]).expertiza_username : author[0]
      data_object = {}
      data_object['label'] = expertiza_username
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
    bar_chart data, chart_options
  end

  # Creates a pie chart for the total commits by authors.
  def display_totals_piechart(parsed_data, authors, dates)
    data = {
      labels: [],
      datasets: [
        {
          data: [],
          backgroundColor: [],
          borderWidth: 1
        }
      ]
    }
  
    colors = %w[#4e79a7 #f28e2b #e15759 #76b7b2 #59a14f #edc948 #af7aa1 #ff9da7]
    authors.each_with_index do |author, index|
      github_association = GithubAssociation.find_by_github_user(author[1])
      expertiza_username = GithubAssociation.find_by_github_user(author[1]) ? GithubAssociation.find_by_github_user(author[1]).expertiza_username : author[0]
      data[:labels] << expertiza_username
      data[:datasets][0][:data] << parsed_data[author[0]].values.sum
      data[:datasets][0][:backgroundColor] << colors[index % colors.length]
    end
  
    data.to_json
  end

  # Defines the general settings of the GitHub metrics chart.
  def chart_options
    {
      responsive: true,
      maintainAspectRatio: false,
      width: 100,
      height: 100,
      scales: graph_scales,
      indexAxis: 'y' # Set the index axis to make the bars horizontal
    }
  end

  # Defines the labels and display of the data on the GitHub metrics chart.
  def graph_scales
    {
      x: {
        stacked: true,
        ticks: {
          beginAtZero: true
        },
        title: {
          display: true,
          text: '# of Commits'
        },
        barThickness: 30
      },
      y: {
        stacked: true,
        ticks: {
          beginAtZero: true
        },
        title: {
          display: true,
          text: 'Submission timeline'
        },
        barThickness: 30
      }
    }
  end

  # Sorts each author's commits based on date.
  def sort_commit_dates
    @dates.each_key do |date|
      @parsed_data.each_value do |commits|
        commits[date] ||= 0
      end
    end
    @parsed_data.each do |author, commits|
      @parsed_data[author] = Hash[commits.sort_by { |date, _commit_count| date }]
      @total_commits += commits.values.sum
    end
  end
end
