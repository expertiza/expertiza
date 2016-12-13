class ResponseTimeController < ApplicationController
  def action_allowed?
    true
  end
  #Three cases :
  #1. When user clicks same link within some time interval and end time of previous instance is nil, update this instance's end time with current param's start time
     # and again form a new object for new click
  #2. start and end time is nil. Means fresh new link
  #3. start and end time is not nil. Means fresh new link
  def record_start_time
    @responsetime_match = ResponseTime.where(map_id: params[:response_time][:map_id], round: params[:response_time][:round], link: params[:response_time][:link])
    if @responsetime_match
      @responsetime_match.each do |responsetime_entry|
        if responsetime_entry.end.nil?
          responsetime_entry.update_attribute('end', params[:response_time][:start])
      end
      end
    end #start and end time is nil. Means fresh new link
    @responsetime = ResponseTime.new(responsetime_params)
    @responsetime.save
    render :nothing => true
  end

  def record_end_time
    @data= params.require(:response_time)
    @linkArray=Array.new
    @responsetime_match = ResponseTime.where(map_id: @data[:map_id], round: @data[:round])
    @responsetime_match.each do |responsetime_entry|
      if responsetime_entry.end.nil?
        @linkArray.push(responsetime_entry.link)
        responsetime_entry.update_attribute('end', @data[:end])
      end
    end   
    respond_to do|format|
      format.json {render json: @linkArray}
    end
end


 def responsetime_params
   params.require(:response_time).permit(:map_id, :round, :link, :start)
 end
 end