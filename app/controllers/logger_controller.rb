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
            line = line.chop
            date_str = line[4..22]
            split_line = line.split('&');
            if(split_line[1]!=nil)
              split_details = split_line[1].split('|')
              le = LogEntry.new(split_details[3],date_str,split_details[4],split_details[2],'');
              logger.warn "+ adding user id #{le.userid}"
               @logArray<<le
            end
          end
        end

        logger.warn "Array length is "+ @logArray.size.to_s
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
            line = line.chop
            logger.warn ">>LINE "+line
            date_str = line[4..22]
            split_line = line.split('&');
            if(split_line[1]!=nil)
              split_details = split_line[1].split('|')
              desc = ''
              if(split_details[5]!= nil)
                desc = split_details[5]
                logger.warn ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>DESC "+desc
              else
                logger.warn "no fifth field"
              end

              le = LogEntry.new(split_details[3],date_str,split_details[4],split_details[2],desc);
              logger.warn "*************+ adding desc #{le.desc}"
               @logArray<<le
            end
          end
        end

        logger.warn "Array length is "+ @logArray.size.to_s

        

        #Filter the logs based on userType
        if(params[:UType]!='All')
          tempArr = Array.new(@logArray)
          logger.warn "Filtering based on user type #{params[:UType]}"
          @logArray = tempArr.select{|entry| entry.user_type == params[:UType]}
          logger.warn "filtered array contains #{@logArray.size}"
        end


        #Filter the logs based on userID
        if(params[:UserID]!='')
          tempArr = Array.new(@logArray)
          logger.warn "Filtering based on user ID #{params[:UserID]}"
          @logArray = tempArr.select{|entry| entry.userid == params[:UserID]}
          logger.warn "filtered array contains #{@logArray.size}"
        end

        #Filter the logs based on event type
        if(params[:EType]!='All')
          tempArr = Array.new(@logArray)
          logger.warn "Filtering based on event type #{params[:EType]}"
          @logArray = tempArr.select{|entry| entry.event_type == params[:EType]}
          logger.warn "filtered array contains #{@logArray.size}"
        end

        #Filter the logs based on from time
        if(params[:time][:from]!='')
          tempArr = Array.new(@logArray)
          logger.warn "Filtering based on from time #{params[:time][:from]}"
          @logArray = tempArr.select{|entry| entry.time >= params[:time][:from]}
          logger.warn "filtered array contains #{@logArray.size}"
        end

        #Filter the logs based on to time
        if(params[:time][:to]!='')
          tempArr = Array.new(@logArray)
          logger.warn "Filtering based on to time #{params[:time][:to]}"
          @logArray = tempArr.select{|entry| entry.time <= params[:time][:to]}
          logger.warn "filtered array contains #{@logArray.size}"
        end

        #DEBUGGING STATEMENTS
        logger.warn "Printing object array:-------------------------------"
        @logArray.each do |i|
          logger.warn "inside loop..."
          logger.warn ">>>>>time: "+i.time+" userid: "+i.userid+" usertype: "+i.user_type+" desc: "+i.desc
        end


        render('view_logs')
end



end