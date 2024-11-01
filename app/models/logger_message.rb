class LoggerMessage
  attr_reader :generator, :unity_id, :message, :oip, :req_id
  def initialize(generator, unity_id, message, req = nil)
    @generator = generator
    @unity_id = unity_id
    @message = message
    @oip = req.remote_ip if req
    @req_id = req.uuid if req
  end
end
