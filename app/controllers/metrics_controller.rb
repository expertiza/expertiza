class MetricsController < ApplicationController
  autocomplete :user, :name
  require 'net/http'
  require 'uri'
  require 'json'
  @@service_url = "https://peerlogic.csc.ncsu.edu/"
  #url for testing peer review web apis, currently hosted at 152.7.98.91
  # @@service_url = "http://152.7.98.91:5000/"

  def bulk_retrieve_metric(metric,parameters,is_confidence_required)
    #getting data for confidence metric
    response = Array.new
    url = ""
    if is_confidence_required
      url = "_confidence"
    end
    case metric.downcase
    when "reputation"
      reputation_metric = call_webservice(parameters, @@service_url + "reputation" + url)
      response = reputation_metric
    when "suggestions"
      suggestion_metric = call_webservice(parameters, @@service_url + "suggestions" + url)
      response = suggestion_metric
    when "volume"
      volume_metric = call_webservice(parameters, @@service_url + "volume")
      response = volume_metric
    when "sentiment"
      sentiment_metric = call_webservice(parameters, @@service_url + "sentiment"+ url)
      response = sentiment_metric
    when "emotions"
      emotions_metric = call_webservice(parameters, @@service_url + "emotions" + url)
      response = emotions_metric
      #problem detection
    when "problem"
      problem_metric = call_webservice(parameters, @@service_url + "problem" + url)
      response = problem_metric
    else
      raise StandardError.new "provide a valid webservice name for which metric is required."
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
    print ("Unable to get metric for " + url + ", following error occurred " + error.to_s)
  end

end