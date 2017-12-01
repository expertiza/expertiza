class TrelloLoaderAdaptee < MetricLoaderAdapter
	SOURCES = Rails.configuration.trello_source

	def self.can_load?(params)
		team, assignment, url = params.values_at(:team, :assignment, :url)
		tests = [!team.nil?, !assignment.nil?, !url.nil?, TrelloMetricsFetcher.supports_url?(url)]
		tests.inject(true){ |sum, a| sum && a }
	end

	def self.load_metric(params)
		team, assignment, url = params.values_at(:team, :assignment, :url)
		team_filter_lam = make_team_filter(team)

		metric_db_data = Metric.includes(:metric_data_points).where(team_id: team.id,
			assignment_id: assignment.id,
			source: MetricDataPointType.sources[:trello],
			remote_id: url )

		metric_db_data = [] if metric_db_data.nil?
		metrics = TrelloMetricsFetcher.new({:url => url,
			:team_filter => team_filter_lam})

		metrics.fetch_content
		new_metric = create_metric(team, assignment, metrics.board_id, metric_db_data.count + 1, metrics)
		# metric_data = metric_db_data + metrics.commits[:data].map { |m|
		# 	create_metric(team, assignment, metrics.board_id, metric_db_data.count + 1)
		# }
		return metric_db_data << new_metric
	end

	def self.create_metric(team, assignment, board_id, version, metrics)
		new_metric = Metric.create(
			team_id: team.id,
			assignment_id: assignment.id,
			source: :trello,
			remote_id: :url,
			uri: "#{board_id}:#{version}"
		)
		create_points(new_metric, metrics)
		return new_metric
	end

	def self.create_points(new_metric, metrics)
		total_items = metrics.total_items
		checked_items = metrics.checked_items
		data_type = MetricDataPointType.where(
			:name => "total_items",
			:source => MetricDataPointType.sources[:trello]
		)
		if !data_type.empty?
			new_metric.metric_data_points.create(
				metric_data_point_type_id: data_type.first.id,
				value: total_items.to_s
			)
		end

		data_type = MetricDataPointType.where(
			:name => "checked_items",
			:source => MetricDataPointType.sources[:trello]
		)
		if !data_type.empty?
			new_metric.metric_data_points.create(
				metric_data_point_type_id: data_type.first.id,
				value: checked_items.to_s
			)
		end
	end

	def self.make_team_filter(team)
		trello_names = team.users.map{ |u| u.trello_name }
		user_emails = team.users.map{ |u| u.email }

		lambda { |email, login| trello_names.include?(login) || user_emails.include?(email) }
	end

	def self.to_map(metric_data)
    metric_data.map{ |n|
      n.metric_data_points.map{ |m|
        [m.metric_data_point_type.name.to_sym, m.value]
      }.to_h
    }
	end
end
