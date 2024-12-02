module GithubMetricsHelper
  include Chartjs::ChartHelpers::Implicit

  # Creates the bar graph for the GitHub metrics data.
  # Links the authors with their GitHub data and assigns
  # them a color. Supports up to 6 different colors and will loop if it goes over.
  def display_bar_chart(parsed_metrics, authors, dates)
    bar_chart_metrics = []
    color = %w[#4e79a7 #f28e2b #e15759 #76b7b2 #59a14f #edc948 #af7aa1 #ff9da7]
    i = 0
    authors.each do |author|
      username = expertiza_username(author)
      author_metrics = {}
      author_metrics['label'] = username
      author_metrics['data'] = parsed_metrics[author[0]].values
      author_metrics['backgroundColor'] = color[i]
      author_metrics['borderWidth'] = 1
      bar_chart_metrics.push(author_metrics)
      i += 1
      i = 0 if i > 5
    end

    bar_chart_body = {
      labels: dates,
      datasets: bar_chart_metrics
    }
    bar_chart bar_chart_body, chart_options
  end

  # Creates a pie chart for the total commits by authors.
  def display_piechart(parsed_metrics, authors, dates)
    piechart_body = {
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
      username = expertiza_username(author)
      piechart_body[:labels] << username
      piechart_body[:datasets][0][:data] << parsed_metrics[author[0]].values.sum
      piechart_body[:datasets][0][:backgroundColor] << colors[index % colors.length]
    end
  
    piechart_body.to_json
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

  # There may or may not be an associated username in expertiza related to the github account if
  # a team member accidentally pushed to their repoistory with the wrong account, in this case
  # use the github name assosicated with that account instead of the expertiza username
  def expertiza_username(author)
    github_association = GithubAssociation.find_by_github_user(author[1])
    GithubAssociation.find_by_github_user(author[1]) ? GithubAssociation.find_by_github_user(author[1]).expertiza_username : author[0]
  end
end
