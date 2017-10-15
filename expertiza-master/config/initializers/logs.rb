logfile = File.open(Rails.root.to_s + '/log/custom.log', 'a')  #create log file
logfile.sync = true  #automatically flushes data to file
CUSTOM_LOGGER = CustomLogger.new(logfile)  #constant accessible anywhere
