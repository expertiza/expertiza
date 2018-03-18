class LogMessage
  def initialize(generator, unity_id, message, req=nil)
    @generator = generator
    @unity_id = unity_id
    @message = message
    @oip = req.remote_ip if req
    @req_id = req.uuid if req
  end

  def generator
    @generator
  end

  def unity_id
    @unity_id
  end

  def message
    @message
  end

  def oip
    @oip
  end

  def req_id
    @req_id
  end
end