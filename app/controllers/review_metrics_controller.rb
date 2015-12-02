class ReviewMetricsController < ApplicationController

  def action_allowed?

    case params[:action]

      when 'list'
        true
      end

    end

  def list

    @map_id = params[:id]
    @response_id = Array.new
    @metrics = Array.new
    @responses = Response.where ("map_id = #{@map_id}")
    (0..@responses.count-1).each do |i|
      @response_id << @responses[i][:id]
    end

    @response_id.each {
        |response|
      @metrics << ReviewMetric.where(response_id: response).first
    }

  end
end
