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
    #@team_reviewed = User.find_by_id(Participant.find_by_id(@map.reviewee_id))
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

    @sugg1 = 0.0
    @error1 = 0.0
    @off1 = 0.0
    @total1 = 0.0
    @total1_average = 0.0
    @sugg1_percentage = 0.0
    @off1_percentage = 0.0
    @error1_percentage = 0.0
    @num1 = 0.0

    @sugg2 = 0.0
    @error2 = 0.0
    @off2 = 0.0
    @total2 = 0.0
    @total2_average = 0.0
    @sugg2_percentage = 0.0
    @off2_percentage = 0.0
    @error2_percentage = 0.0
    @num2 = 0.0

    @assignment_id = params[:assignment_id]
    @reviewer_id = params[:reviewer_id]
    @assignment_name = Assignment.find_by_id(@assignment_id).name

    @response_maps = ResponseMap.where(["reviewed_object_id = ? AND reviewer_id = ?", @assignment_id, @reviewer_id])
    @maps = Array.new
    (0..@response_maps.uniq.count-1).each do |i|
      @maps << @response_maps[i][:id]
    end

    @response_id1 = Array.new
    (0..@maps.count-1).each do |i|
      @responses1 = Response.where ("map_id = #{@maps[i]} AND round = 1")
      (0..@responses1.count-1).each do |j|
        @response_id1 << @responses1[j][:id]
      end
    end

    @response_id2 = Array.new
    (0..@maps.count-1).each do |i|
      @responses2 = Response.where ("map_id = #{@maps[i]} AND round = 2")
      (0..@responses2.count-1).each do |j|
        @response_id2 << @responses2[j][:id]
      end
    end

    @metrics1 = Array.new
    @response_id1.each {
        |response|
      @metrics1 << ReviewMetric.where(response_id: response).first
    }

    @metrics2 = Array.new
    @response_id2.each {
        |response|
      @metrics2 << ReviewMetric.where(response_id: response).first
    }

    (0..@metrics1.count-1).each do |i|
      if @metrics1[i][:suggestion_count] > 0
        @sugg1 = @sugg1 + 1
      end
      if @metrics1[i][:error_count] > 0
        @error1 = @error1 + 1
      end
      if @metrics1[i][:offensive_count] > 0
        @off1 = @off1 + 1
      end

      @total1 = @total1 + @metrics1[i][:total_word_count]

      @num1 = @num1 + 1
    end

    if @num1 > 0

      @sugg1_percentage = (@sugg1/@num1)*100
      @error1_percentage = (@error1/@num1)*100
      @off1_percentage = (@off1/@num1)*100
      @total1_average = (@total1/@num1)

    end

    (0..@metrics2.count-1).each do |i|
      if @metrics2[i][:suggestion_count] > 0
        @sugg2 = @sugg2 + 1
      end
      if @metrics2[i][:error_count] > 0
        @error2 = @error2 + 1
      end
      if @metrics2[i][:offensive_count] > 0
        @off2 = @off2 + 1
      end

      @total2 = @total2 + @metrics2[i][:total_word_count]

      @num2 = @num2 + 1
    end

    if @num2 > 0

      @sugg2_percentage = (@sugg2/@num2)*100
      @error2_percentage = (@error2/@num2)*100
      @off2_percentage = (@off2/@num2)*100
      @total2_average = (@total2/@num2)

    end


  end
end