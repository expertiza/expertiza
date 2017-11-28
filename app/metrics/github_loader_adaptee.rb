class GithubLoaderAdaptee < MetricLoaderAdapter

  SOURCES = Rails.configuration.github_sources 

  def self.can_load?(params) 
    team, assignment, url = params.values_at(:team, :assignment, :url)
    tests = [!team.nil?, !assignment.nil?, !url.nil?, GithubMetricsFetcher.supports_url?(url)]
    tests.inject(true){ |sum, a| sum && a }
  end

  def self.load_metric(params)
    team, assignment, url = params.values_at(:team, :assignment, :url)
    team_filter_lam = make_team_filter(team) 
    
    metric_db_data = Metric.includes(:metric_data_points).where(team_id: team.id, 
      assignment_id: assignment.id, 
      source: MetricDataPointType.sources[:github],
      remote_id: url )
    
    if metric_db_data.nil?
      metric_db_data = []
      metrics = GithubMetricsFetcher.new({:url => url,
        :team_filter => team_filter_lam})
    else 
      flattened_data = to_map(metric_db_data)
      commit_list = flattened_data.map { |t| t[:commit_id] }
      commit_filter = lambda { |commit_id| !commit_list.include?(commit_id) }
      metrics = GithubMetricsFetcher.new({:url => url, :commit_filter => commit_filter, 
        :team_filter => team_filter_lam})
    end

    metrics.fetch_content
    metric_data = metric_db_data + metrics.commits[:data].map { |m| 
      create_metric(team, assignment, metrics.repo, m)
    }
    
    metric_data
  end

  def self.flatten_all(metrics)
    metrics.map{ |m| flatten(m)} 
  end

  def self.to_map(metric_data) 
    metric_data.map{ |n| 
      n.metric_data_points.map{ |m| 
        [m.metric_data_point_type.name.to_sym,  m.value]
      }.to_h
    }
  end

  private

  def self.make_team_filter(team) 
    github_ids = team.users.map{ |u| u.github_id }
    user_emails = team.users.map{ |u| u.email }

    lambda { |email, login| github_ids.include?(login) || user_emails.include?(email) }
  end

  def self.create_metric(team, assignment, project, commit)
    new_metric = Metric.create(
      team_id: team.id,
      assignment_id: assignment.id,
      source: :github,
      remote_id: :url,
      uri: "#{project}:commit:#{commit[:commit_id]}"
    )
    
    points = create_points(new_metric, commit)
    new_metric
  end

  def self.create_points(new_metric, commit)
    commit.keys.map { | m |
      data_type = MetricDataPointType.where(:name => m, 
        :source => MetricDataPointType.sources[:github])
      if ! data_type.empty?
        new_metric.metric_data_points.create(
          metric_data_point_type_id: data_type.first.id,
          value: commit[m]
        )
      else
        nil
      end
    }.select { |u| ! u.nil? }
  end

  
end