class WikiLoaderAdaptee < MetricLoaderAdapter

	SOURCES = Rails.configuration.wiki_source


	def self.can_load?(params)
		team, assignment, url = params.values_at(:team, :assignment, :url)
  		tests = [!team.nil?, !assignment.nil?, !url.nil?, WikiMetricsFetcher.supports_url?(url)]
  		tests.inject(true){ |sum, a| sum && a }
  	end


  	def self.load_metric(params)
  		team, assignment, url = params.values_at(:team, :assignment, :url)

  		metric_db_data = Metric.includes(:metric_data_points).where(team_id: team.id,
 			assignment_id: assignment.id,
 			source: MetricDataPointType.sources[:wiki],
 			remote_id: url )

  		metric_db_data = [] if metric_db_data.nil?

  		metrics = WikiMetricsFetcher.new({:url => url})

  		metrics.fetch_content

  		new_metric = create_metric(team, assignment, metric_db_data.count + 1, metrics)

  		return metric_db_data  << new_metric
  	end

  	def self.create_metric(team, assignment, version, metrics)
  		new_metric = Metric.create(
  			team_id: team.id,
  			assignment_id: assignment.id,
  			source: :wiki,
  			remote_id: :url,
  			uri: "#{metrics.id}:#{version}"
  			)

  		create_points(new_metric, metrics)

  		return new_metric
  	end

  	def self.create_points(new_metric, metrics)
  		readability = metrics.readability
  		fleschKincaidRe = readability['scores']['FleschKincaidRe']
  		fleschKincaidGl = readability['scores']['FleschKincaidGl']
  		ari = readability['scores']['Ari']
  		colemanLiau = readability['scores']['ColemanLiau']
  		gunningFog = readability['scores']['GunningFog']
  		smog = readability['scores']['Smog']

  		data_type = MetricDataPointType.where(
 			:name => "FleschKincaidRe",
 			:source => MetricDataPointType.sources[:wiki]
 		)

 		if !data_type.empty?
 			new_metric.metric_data_points.create(
				metric_data_point_type_id: data_type.first.id,
				value: fleschKincaidRe.to_s
			)
		end

		data_type = MetricDataPointType.where(
 			:name => "FleschKincaidGl",
 			:source => MetricDataPointType.sources[:wiki]
 		)

 		if !data_type.empty?
 			new_metric.metric_data_points.create(
				metric_data_point_type_id: data_type.first.id,
				value: fleschKincaidGl.to_s
			)
		end

		data_type = MetricDataPointType.where(
 			:name => "Ari",
 			:source => MetricDataPointType.sources[:wiki]
 		)

 		if !data_type.empty?
 			new_metric.metric_data_points.create(
				metric_data_point_type_id: data_type.first.id,
				value: ari.to_s
			)
		end

		data_type = MetricDataPointType.where(
 			:name => "ColemanLiau",
 			:source => MetricDataPointType.sources[:wiki]
 		)

 		if !data_type.empty?
 			new_metric.metric_data_points.create(
				metric_data_point_type_id: data_type.first.id,
				value: colemanLiau.to_s
			)
		end

		data_type = MetricDataPointType.where(
 			:name => "GunningFog",
 			:source => MetricDataPointType.sources[:wiki]
 		)

 		if !data_type.empty?
 			new_metric.metric_data_points.create(
				metric_data_point_type_id: data_type.first.id,
				value: gunningFog.to_s
			)
		end

		data_type = MetricDataPointType.where(
 			:name => "Smog",
 			:source => MetricDataPointType.sources[:wiki]
 		)

 		if !data_type.empty?
 			new_metric.metric_data_points.create(
				metric_data_point_type_id: data_type.first.id,
				value: smog.to_s
			)
		end


		def self.to_map(metric_data)
            metric_data.map{ |n|
                n.metric_data_points.map{ |m|
                	[m.metric_data_point_type.name.to_sym, m.value]
                }.to_h
            }
        end


	end




