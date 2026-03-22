# app/services/mcp_server_client.rb
require 'net/http'
require 'uri'
require 'json'

class MCPServerClient
  def initialize(endpoint: Rails.configuration.x.mcp.endpoint, token: Rails.configuration.x.mcp.token, timeout: Rails.configuration.x.mcp.request_timeout)
    @base_uri = URI(endpoint)
    @token = token
    @timeout = timeout
  end

  # POST /v1/reviews
  # payload: Hash (will be converted to JSON)
  # Returns parsed JSON response or raises on HTTP error
  def send_review(payload)
    post("api/v1/reviews", payload)
  end

  # GET /api/v1/reviews/finalized/:expertiza_response_id
  # Returns { total_finalized_score: int or null, student_feedback: string or null }
  def get_finalized_review(expertiza_response_id)
    get("api/v1/reviews/finalized/#{expertiza_response_id}")
  end

  # GET /api/v1/reviews/finalized/:expertiza_response_id/detailed-evaluation
  # Returns rubric-style detailed evaluation with per-dimension scores and reasoning.
  def get_detailed_evaluation(expertiza_response_id)
    get("api/v1/reviews/finalized/#{expertiza_response_id}/detailed-evaluation")
  end

  private

  def get(path)
    request(Net::HTTP::Get, path)
  end

  def post(path, payload)
    request(Net::HTTP::Post, path, payload.to_json)
  end

  def request(klass, path, body = nil)
    uri = @base_uri + path
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.read_timeout = @timeout
    http.open_timeout = @timeout

    req = klass.new(uri)
    req['Content-Type'] = 'application/json'
    req['Accept'] = 'application/json'
    req['X-API-Key'] = @token if @token.present?
    req.body = body if body
    
    Rails.logger.info("[MCP] → #{klass.name} #{uri} body=#{body.inspect}")
    resp = http.request(req)
    Rails.logger.info("[MCP] ← #{resp.code} #{uri} body=#{resp.body.to_s[0, 500]}")

    case resp
    when Net::HTTPSuccess
      begin
        return JSON.parse(resp.body) unless resp.body.nil? || resp.body.strip.empty?
        return {}
      rescue JSON::ParserError
        raise "MCP returned non-JSON response"
      end
    else
      # bubble up a meaningful error for caller
      raise "MCP request failed: #{resp.code} - #{resp.body}"
    end
  end
end
