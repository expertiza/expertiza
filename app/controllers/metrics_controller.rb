class MetricsController < ApplicationController
  autocomplete :user, :name
  require 'net/http'
  require 'uri'
  require 'json'
  # @@service_url = "https://peerlogic.csc.ncsu.edu/"
  #url for testing peer review web apis, currently hosted at 152.7.98.91
  @@service_url = "http://152.7.98.91:5000/"

  def bulk_retrieve_metric(metric,parameters,is_confidence_required)
    metric = metric.downcase
    if is_valid_metric(metric)
      #if only confidence is required from metric, append string "_confidence" to url
      metric_url = @@service_url + metric + (is_confidence_required ? "_confidence" : "")
      response = call_webservice(parameters, metric_url)
    else
      raise StandardError.new "call must include a valid web service name."
    end
  end

  def is_valid_metric(metric)
    #return true if metric name is valid else return false
    valid_metrics = ['reputation','suggestions','volume', 'sentiment', 'emotions', 'problem']
    valid_metrics.include?(metric)
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
    print ("Unable to get metric for " + url + " ; the following error occurred " + error.to_s)
  end

end