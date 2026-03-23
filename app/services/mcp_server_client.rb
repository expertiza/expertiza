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
  # Returns the finalized formative/summative evaluation payload for a response.
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
    response_body = normalize_string_encoding(resp.body.to_s)
    Rails.logger.info("[MCP] ← #{resp.code} #{uri} body=#{response_body[0, 500]}")

    case resp
    when Net::HTTPSuccess
      begin
        return {} if response_body.strip.empty?

        return normalize_parsed_json(JSON.parse(response_body))
      rescue JSON::ParserError
        raise "MCP returned non-JSON response"
      end
    else
      # bubble up a meaningful error for caller
      raise "MCP request failed: #{resp.code} - #{resp.body}"
    end
  end

  def normalize_parsed_json(value)
    case value
    when Hash
      value.each_with_object({}) do |(key, nested_value), normalized_hash|
        normalized_hash[normalize_string_encoding(key)] = normalize_parsed_json(nested_value)
      end
    when Array
      value.map { |item| normalize_parsed_json(item) }
    when String
      normalize_string_encoding(value)
    else
      value
    end
  end

  def normalize_string_encoding(value)
    value.to_s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
  end
end
