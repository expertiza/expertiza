# custom_logger.rb
class CustomLogger < Logger
  def format_message(_severity, _timestamp, _progname, msg)
    "#{msg}\n"
  end
end
