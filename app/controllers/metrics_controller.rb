class MetricsController < ApplicationController
  autocomplete :user, :name
  require 'net/http'
  require 'uri'
  require 'json'
  SERVICE_URL = "http://152.7.99.200:5000/".freeze
  VALID_METRICS = %w[reputation suggestions volume sentiment emotions problem].freeze

  def bulk_retrieve_metric(metric, parameters, is_confidence_required)
    metric = metric.downcase
    raise StandardError.new "Call must include a valid web service name." unless VALID_METRICS.include?(metric)
    # if only confidence is required from metric, append string "_confidence" to url
    metric_url = SERVICE_URL + metric + (is_confidence_required ? "_confidence" : "")
    call_webservice(parameters, metric_url)
  end

  def call_webservice(parameters, url)
    uri = URI(url)
    # # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    request_object = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    request_object.body = parameters.to_json
    response_object = http.request(request_object)
    JSON.parse(response_object.body)
  rescue Exception => error
    raise StandardError.new "End of file reached"
  end
end
