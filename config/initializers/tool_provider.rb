
include Lti2Commons
include WireLogSupport

NONCE_TIME_TO_LIVE = 300  # seconds
Rails.application.config.nonce_cache = Cache.new :ttl => NONCE_TIME_TO_LIVE

if ActiveRecord::Base.connection.table_exists? 'lti2_tp_registries'
  Rails.application.config.tool_provider_registry = Lti2Tp::ToolProviderRegistry.new
end

wirelog_filename = Rails.application.config.tool_provider_registry.registry['wirelog_filename']
if wirelog_filename.present?
  Rails.application.config.wire_log = WireLog.new "ToolProvider", File.expand_path(wirelog_filename)
else
  Rails.application.config.wire_log = nil
end

# puts("Init tp registry: #{Rails.application.config.tool_provider_registry.registry.inspect}")
# puts("Init tp_deployment_url: #{Rails.application.config.tool_provider_registry.registry['tp_deployment_url']}")