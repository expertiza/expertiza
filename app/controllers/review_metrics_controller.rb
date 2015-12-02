class ReviewMetricsController < ApplicationController

  def action_allowed?

    case params[:action]

      when 'list'
        true
      else
      ['Instructor',
       'Teaching Assistant',
       'Administrator'].include? current_role_name
      end
  end

  def list

    @map_id = params[:id]
    @map = ResponseMap.find_by_id(@map_id)
    @assignment = Assignment.find_by_id(@map.reviewed_object_id).name
    @team_reviewed = User.find_by_id(Participant.find_by_id(@map.reviewee_id))
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

  def aggregate
    @assignment = Assignment.find(params[:assignment_id]).name
  end

end
