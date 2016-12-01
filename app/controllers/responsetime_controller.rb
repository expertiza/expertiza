class ResponsetimeController < ApplicationController
  def action_allowed?
    true
  end
  #Three cases :
  #1. When user clicks same link within some time interval and end time of previous instance is nil, update this instance's end time with current param's start time
     # and again form a new object for new click
  #2. start and end time is nil. Means fresh new link
  #3. start and end time is not nil. Means fresh new link
  def record_start_time
    Rails.logger.debug "Hi DER"
    @responsetime_match = Responsetime.where(map_id: params[:responsetime][:map_id], round: params[:responsetime][:round], link: params[:responsetime][:link])
    if @responsetime_match
      @responsetime_match.each do |responsetime_entry|
        if responsetime_entry.end.nil?
          responsetime_entry.update_attribute('end', params[:responsetime][:start])
      end
      end
    end #start and end time is nil. Means fresh new link
    @responsetime = Responsetime.new(responsetime_params)
    @responsetime.save
  end

  def record_end_time
    Rails.logger.debug "Hi DER in end time"
    @responsetime_match = Responsetime.where(map_id: params[:responsetime][:map_id], round: params[:responsetime][:round])
    @responsetime_match.each do |responsetime_entry|
      if responsetime_entry.end.nil?
        responsetime_entry.update_attribute('end', params[:responsetime][:end])
      end
    end
  end

 def responsetime_params
   params.require(:responsetime).permit(:map_id, :round, :link, :start)
 end
 end