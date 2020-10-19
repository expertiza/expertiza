class MetricsController < ApplicationController
  autocomplete :user, :name
  require 'net/http'
  require 'uri'
  require 'json'
  #url in case web service is deployed in peer logic servers
  # @@service_url = "https://peerlogic.csc.ncsu.edu/"
  #url for testing peer review web apis, currently hosted at 152.7.98.91
  @@service_url = "http://152.7.98.91:5000/"
  #possible metrics that can be called to peer logic web servers.
  Valid_metrics = ['reputation','suggestions','volume', 'sentiment', 'emotions', 'problem']

  def bulk_retrieve_metric(metric,parameters,is_confidence_required)
    metric = metric.downcase
    if Valid_metrics.include?(metric)
      #if only confidence is required from metric, append string "_confidence" to url
      metric_url = @@service_url + metric + (is_confidence_required ? "_confidence" : "")
      response = call_webservice(parameters, metric_url)
    else
      raise StandardError.new "Call must include a valid web service name."
    end
  end

  def call_webservice(parameters, url)
    uri = URI(url)
    # # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    reqestObject = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
    reqestObject.body = parameters.to_json
    responseObject = http.request(reqestObject)
    response = JSON.parse(responseObject.body)
  rescue Exception => error
  end

end