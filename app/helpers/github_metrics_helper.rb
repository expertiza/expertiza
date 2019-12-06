require 'securerandom'
module GithubMetricsHelper
  def display_github_metrics(gitVariable, graph_type, timeline_type)
    parsed_data = gitVariable[:parsed_data]
    authors = gitVariable[:authors]
    dates = gitVariable[:dates]
    dates_to_week = Set[]
    dates.each do |date|
      dates_to_week.add(DateTime.parse(date).strftime('%V'))
    end

    if timeline_type == GithubMetric::timeline_types['By Week'].to_s
      dates_to_week = dates_to_week.sort
      parsed_data_by_week = {}
      parsed_data.each do |author_email, commit_hash|
        week_commits = {}
        dates_to_week.each do |key|
          week_commits[key] = {
            commits: 0,
            additions: 0,
            deletions: 0
          }
        end
        commit_hash.each do |date, commit_object|
          week_number = DateTime.parse(date).strftime('%V')
          week_commits[week_number][:commits] += commit_object[:commits]
          week_commits[week_number][:additions] += commit_object[:additions]
          week_commits[week_number][:deletions] += commit_object[:deletions]
        end
        week_commits = week_commits.sort.to_h
        parsed_data_by_week[author_email] = week_commits
      end

      data_array = []
      authors.each do |author|
        no_of_commits_data = []
        no_of_lines_added_data = []
        no_of_lines_deleted_data = []

        parsed_data_by_week[author].each do |key, commit_object|
          no_of_commits_data << commit_object[:commits]
          no_of_lines_added_data << commit_object[:additions]
          no_of_lines_deleted_data << commit_object[:deletions]
        end

        data_object = {}
        data_object['label'] = author
        data_object['backgroundColor'] = GithubMetricsHelper.color_hex()
        data_object['borderWidth'] = 1
        case graph_type
        when GithubMetric::graph_types['Commit Metrics'].to_s
          data_object['data'] = no_of_commits_data
          data_object['stack'] = 1
        when GithubMetric::graph_types['Lines Added Metrics'].to_s
          data_object['data'] = no_of_lines_added_data
          data_object['stack'] = 2
        when GithubMetric::graph_types['Lines Deleted Metrics'].to_s
          data_object['data'] = no_of_lines_deleted_data
          data_object['stack'] = 3
        else
          data_object['data'] = no_of_commits_data
          data_object['stack'] = 1
        end
        data_array.push(data_object)
      end
      data = {
        labels: dates_to_week,
        datasets: data_array
      }
    else
      parsed_data_by_week = {}
      dates_to_week = dates_to_week.sort
      dates_to_week.each do |week|
        week_data = {}
        authors.each do |author_email|
          week_data[author_email] = {
            commits: 0,
            additions: 0,
            deletions: 0
          }
        end
        parsed_data_by_week[week] = week_data
      end
      parsed_data.each do |author_email, commit_hash|
        commit_hash.each do |date, commit_object|
          week = DateTime.parse(date).strftime('%V')
          parsed_data_by_week[week][author_email][:commits] += commit_object[:commits]
          parsed_data_by_week[week][author_email][:additions] += commit_object[:additions]
          parsed_data_by_week[week][author_email][:deletions] += commit_object[:deletions]
        end
      end
      data_array = []
      dates_to_week.each do |week|
        no_of_commits_data = []
        no_of_lines_added_data = []
        no_of_lines_deleted_data = []

        parsed_data_by_week[week].each do |key, commit_object|
          no_of_commits_data << commit_object[:commits]
          no_of_lines_added_data << commit_object[:additions]
          no_of_lines_deleted_data << commit_object[:deletions]
        end

        data_object = {}
        data_object['label'] = 'Week:' + week
        data_object['backgroundColor'] = GithubMetricsHelper.color_hex()
        data_object['borderWidth'] = 1
        case graph_type
        when GithubMetric::graph_types['Commit Metrics'].to_s
          data_object['data'] = no_of_commits_data
          data_object['stack'] = 1
        when GithubMetric::graph_types['Lines Added Metrics'].to_s
          data_object['data'] = no_of_lines_added_data
          data_object['stack'] = 2
        when GithubMetric::graph_types['Lines Deleted Metrics'].to_s
          data_object['data'] = no_of_lines_deleted_data
          data_object['stack'] = 3
        else
          data_object['data'] = no_of_commits_data
          data_object['stack'] = 1
        end
        data_array.push(data_object)
      end

      data = {
        labels: authors,
        datasets: data_array
      }
    end
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
      yAxes: [
        {
          stacked: true,
          ticks: {
            beginAtZero: true
          },
          barThickness: 30,
          scaleLabel: {
            display: true
          }
        }
      ],
      xAxes: [
        {
          stacked: true,
          ticks: {
            beginAtZero: true,
            maxRotation: 90,
            minRotation: 0
          },
          barThickness: 60,
          scaleLabel: {
            display: true
          }
        }
      ]
    }
  end

  def student_level_github_metrics_summary(commits, authors)

    github_metrics_summary = {}
    authors.each do |author_email|
      github_metrics_summary[author_email] = {
        commits: 0,
        additions: 0,
        deletions: 0,
        changedFiles: 0
      }
    end
    commits.each do |commit|
      github_metrics_summary[commit["author"]["email"]][:commits] += 1
      github_metrics_summary[commit["author"]["email"]][:additions] += commit["additions"]
      github_metrics_summary[commit["author"]["email"]][:deletions] += commit["deletions"]
      github_metrics_summary[commit["author"]["email"]][:changedFiles] += commit["changedFiles"]
    end
    github_metrics_summary
  end
  def self.color_hex(options = {})
    default = { red: rand(255), green: rand(255), blue: rand(255) }
    options = default.merge(options)
    '#%X%X%X' % options.values
  end
end

