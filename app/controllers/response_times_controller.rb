class ResponseTimesController < ApplicationController
  def action_allowed?
    true
  end

  def response_start_time
    map_id = params[:response_time][:map_id]
    round = params[:response_time][:round]
    link = params[:response_time][:link]
    start_at = params[:response_time][:start_at]
    # check if this link is already opened and timed
    @response_time_records = ResponseTime.where(map_id: map_id, round: round, link: link)
    # if opened, end these records with current time
    if @response_time_records
      @response_time_records.each do |time_record|
        if time_record.end_at.nil?
          time_record.update_attribute('end_at', start_at)
        end
      end
    end
    # create new response time record for current link
    @response_time = ResponseTime.new(response_time_params)
    @response_time.save
  end

  def response_end_time
    @data = params.require(:response_time)
    @response_time_records = ResponseTime.where(map_id: @data[:map_id], round: @data[:round], link: @data[:link])
    @response_time_records.each do |time_record|
      if time_record.end_at.nil?
        time_record.update_attribute('end', @data[:end_at])
        break
      end
    end
  end

  private
    # Only allow a trusted parameter "white list" through.
    def response_time_params
      params.require(:response_time).permit(:map_id, :link, :round, :start_at, :end_at)
    end
end
