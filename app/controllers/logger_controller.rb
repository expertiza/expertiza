class LoggerController < ApplicationController
  
  def action_allowed?
    true
  end


  def view_logs

  	@@event_logger.debug "Entered view action in log manager"
		@@event_logger.debug "Entered view action + Filter Test"
  	filePath = "#{Rails.root}/log/events.log"
  	@logArray = Array.new

  	File.open(filePath,'r') do |file|
  		file.each_line do |line|
    	 @logArray<<line
  		end
	  end
	puts "Array length is "+ @logArray.size.to_s
  end



def search
        puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>In search action"

        puts "Parameters Received:"
        puts "User ID "+params[:UserID]
        puts "User Type "+params[:UserType]
        puts "Event Type "+params[:EType]
        puts "From DT "+params[:time][:from]
         puts "From DT "+params[:time][:to]



        @logArray = Array.new
        render('view_logs')
end



end