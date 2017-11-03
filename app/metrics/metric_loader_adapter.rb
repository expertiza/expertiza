class MetricLoaderAdapter
  def can_load?(url)
    raise 'not implemented'
  end

  def load_metric(params)
    raise 'not implemented'
  end
end