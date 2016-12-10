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
        logger.warn ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>In search action"

        logger.warn "Parameters Received:"
        logger.warn "User ID "+params[:UserID]
        logger.warn "User Type "+params[:UType]
        logger.warn "Event Type "+params[:EType]
        logger.warn "From DT "+params[:time][:from]
        logger.warn "From DT "+params[:time][:to]
        @logArray = Array.new
        filePath = "#{Rails.root}/log/events.log"
        File.open(filePath,'r') do |file|
            file.each_line do |line|
            date_str = line[4..22]
            split_line = line.split('&');
            if(split_line[1]!=nil)
              split_details = split_line[1].split('|')
              le = LogEntry.new(split_details[3],date_str,split_details[4],split_details[2]);
              puts "+ adding entry "+le.time+" "+le.userid
               @logArray<<le
            end
          end
        end
        logger.warn "Array length is "+ @logArray.size.to_s

        logger.warn "Printing object array:"

        @logArray.each do |i|
          logger.warn "inside loop..."
          logger.warn ">>>>>time: "+i.time+" userid: "+i.userid+" usertype: "+i.user_type+" eventtype: "+i.event_type
        end

        render('view_logs')
end



end