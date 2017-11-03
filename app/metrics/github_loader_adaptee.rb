class GithubLoaderAdaptee < MetricLoaderAdapter

  SOURCES = Rails.configuration.github_sources 

  def self.can_load?(params) 
    team, assignment, url = params.values_at(:team, :assignment, :url)
    
    not team.nil? and not assignment.nil? and not url.nil? and GithubMetricsFetcher.supports_url?(url)
  end

  def self.load_metric(params)
    team, assignment, url = params.values_at(:team, :assignment, :url)
    metric_db_data = Metric.find_by(team_id: team.id, 
      assignment_id: assignment.id, 
      metric_source: :github,
      remote_id: url )

    if metric_data.nil?
      metric_db_data = []
      metrics = GithubMetricsFetcher.new({"url" => metric_id})
    else 
      flattened_data = flatten(metric_db_data)
      last_commit_date = flattened_data.sort_by{ |t| -t[:commit_date] }.head
      metrics = GithubMetricsFetcher.new({"url" => metric_id, 
        "last_commit_date" => last_commit_date })
    end

    metrics.fetch_content
    metric_data = metric_db_data + metrics.commits.map { |m| create_metric(team, assignment, metrics.project, m)}
    
    metric_data
  end

  private

  def self.create_metric(team, assignment, project, commit)
    new_metric = Metric.create(
      team_id: team.id,
      assignment_id: assignment.id,
      metric_source: :github,
      remote_id: :url,
      uri: "#{project}:commit:#{commit[:id]}"
    )
    
    points = create_points(new_metric, commit)
    new_metric.metric_data_points = points
    new_metric
  end

  def self.create_points(new_metric, commit)
    commit.keys.map { | m |
      type = MetricDataType.find_by(:name => m).head

      if not type.nil?
        new_metric.metric_data_points.create(
          metric_data_type: type,
          value: m[k]
        )
      end
    }
  end

  def self.flatten(metric_data) 
    metric_data.map{ |n| 
      n.metric_data_points.map{ |m| 
        [m[:name],  m[:value]]
      }.to_h
    }
  end
end