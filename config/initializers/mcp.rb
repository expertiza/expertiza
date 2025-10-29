# config/initializers/mcp.rb
Rails.application.config.x.mcp = ActiveSupport::OrderedOptions.new
# Dummy IP for draft purposes (change to real MCP endpoint/env var in production)
Rails.application.config.x.mcp.endpoint = ENV.fetch('MCP_ENDPOINT', 'http://192.0.2.10:8080')
# Token used to talk to MCP (dummy by default)
Rails.application.config.x.mcp.token = ENV.fetch('MCP_TOKEN', 'dummy-token-please-change')
# Optional timeout (seconds)
Rails.application.config.x.mcp.request_timeout = ENV.fetch('MCP_REQUEST_TIMEOUT', 30).to_i
