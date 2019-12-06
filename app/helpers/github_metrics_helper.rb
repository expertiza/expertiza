require 'securerandom'
module GithubMetricsHelper
  def display_github_metrics(gitVariable, graph_type, timeline_type, due_date)
    parsed_data = gitVariable[:parsed_data]
    authors = gitVariable[:authors]
    dates = gitVariable[:dates]
    dates_to_week = Set[]

    submission_week = if ['Unknown', 'Finished'].include? due_date
                        nil
                      else
                        DateTime.parse(due_date).strftime('%V')
                      end

    dates.each do |date|
      dates_to_week.add(DateTime.parse(date).strftime('%V'))
    end
    @y_axis_label = ''
    if timeline_type == GithubMetric::timeline_types['week'].to_s
      @y_axis_label = 'Weeks to submission'
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
      color = %w[#ed1c1c99 #ffea0099 #00ff0899 #00e5ff99 #ff007799 #0d00ff99 #7d4a5699 #77c9c899]
      i = 0
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
        data_object['backgroundColor'] = color[i]
        data_object['borderWidth'] = 1
        case graph_type
        when GithubMetric::graph_types['number of commits'].to_s
          data_object['data'] = no_of_commits_data
          data_object['stack'] = 1
        when GithubMetric::graph_types['lines added'].to_s
          data_object['data'] = no_of_lines_added_data
          data_object['stack'] = 2
        when GithubMetric::graph_types['lines deleted'].to_s
          data_object['data'] = no_of_lines_deleted_data
          data_object['stack'] = 3
        else
          #do nothing
        end
        data_array.push(data_object)
        i += 1
        i = 0 if i > 7
      end

      if submission_week.present?
        dates_to_week = dates_to_week.map { |week| submission_week.to_i - week.to_i }
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
      color = %w[red yellow blue gray green magenta]
      i = 0
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
        data_object['backgroundColor'] = color[i]
        data_object['borderWidth'] = 1
        case graph_type
        when GithubMetric::graph_types['number of commits'].to_s
          data_object['data'] = no_of_commits_data
          data_object['stack'] = 1
        when GithubMetric::graph_types['lines added'].to_s
          data_object['data'] = no_of_lines_added_data
          data_object['stack'] = 2
        when GithubMetric::graph_types['lines deleted'].to_s
          data_object['data'] = no_of_lines_deleted_data
          data_object['stack'] = 3
        else
          #do nothing
        end
        data_array.push(data_object)
        i += 1
        i = 0 if i > 7
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
            display: true,
            labelString: @y_axis_label
          }
        }
      ],
      xAxes: [
        {
          stacked: true,
          ticks: {
            beginAtZero: true
          },
          barThickness: 60,
          scaleLabel: {
            display: true,
            labelString: 'Count'
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

