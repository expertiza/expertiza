class LoggerController < ApplicationController
  def view_logs

  	@@event_logger.debug"Entered view action in log manager"
  	filePath = "#{Rails.root}/log/events.log"
  	@logArray = Array.new

  	File.open(filePath,'r') do |file|
  		file.each_line do |line|
    	 @logArray<<line
  		end
	end
	puts "Array length is "+ @logArray.size.to_s
  end
end