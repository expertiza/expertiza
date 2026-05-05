# config/initializers/mcp.rb
Rails.application.config.x.mcp = ActiveSupport::OrderedOptions.new
# Local default for development; production should override with MCP_ENDPOINT.
Rails.application.config.x.mcp.endpoint = ENV.fetch('MCP_ENDPOINT', 'http://localhost:8000/')
# Token used to talk to MCP (dummy by default)
Rails.application.config.x.mcp.token = ENV.fetch('MCP_TOKEN', 'dev')
# Optional timeout (seconds)
Rails.application.config.x.mcp.request_timeout = ENV.fetch('MCP_REQUEST_TIMEOUT', 30).to_i
