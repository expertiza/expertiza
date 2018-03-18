# expertiza_logger.rb
class ExpertizaLogFormatter < Logger::Formatter
  # This method is invoked when a log event occurs
  def call(_severity, _timestamp, _progname, msg)
    if msg.is_a?(LogMessage)
      "TST=[#{_timestamp}] SVT=[#{_severity}] PNM=[#{_progname}] OIP=[#{msg.oip}] RID=[#{msg.req_id}] CTR=[#{msg.generator}] UID=[#{msg.unity_id}] MSG=[#{filter(msg.message)}]\n"
    else
      "TST=[#{_timestamp}] SVT=[#{_severity}] PNM=[#{_progname}] OIP=[] RID=[] CTR=[] UID=[] MSG=[#{filter(msg)}]\n"
    end
  end

  def filter(msg)
    msg.gsub("\n",'  ')
  end
end

class ExpertizaLogger
  def self.info(message=nil)
    @info_log ||= Logger.new("#{Rails.root}/log/expertiza_info.log")
    self.add_formatter @info_log
    @info_log.info(message) unless message.nil?
  end
  def self.warn(message=nil)
    @warn_log ||= Logger.new("#{Rails.root}/log/expertiza_warn.log")
    self.add_formatter @warn_log
    @warn_log.warn(message) unless message.nil?
  end
  def self.error(message=nil)
    @error_log ||= Logger.new("#{Rails.root}/log/expertiza_error.log")
    self.add_formatter @error_log
    @error_log.error(message) unless message.nil?
  end
  def self.fatal(message=nil)
    @fatal_log ||= Logger.new("#{Rails.root}/log/expertiza_fatal.log")
    self.add_formatter @fatal_log
    @fatal_log.fatal(message) unless message.nil?
  end
  def self.debug(message=nil)
    @debug_log ||= Logger.new("#{Rails.root}/log/expertiza_debug.log")
    self.add_formatter @debug_log
    @debug_log.debug(message) unless message.nil?
  end

  def self.add_formatter(log)
    log.formatter ||= ExpertizaLogFormatter.new
  end
end
