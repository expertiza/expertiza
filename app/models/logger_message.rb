class LoggerMessage
  attr_reader :generator, :unity_id, :message, :oip, :req_id, :log_map
  def initialize(generator, unity_id, message, req = nil, log_map = nil)
    @generator = generator
    @unity_id = unity_id
    @message = message
    @oip = req.remote_ip if req
    @req_id = req.uuid if req
    @log_map = log_map if log_map
  end
end
