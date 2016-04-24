class SurveyResponseController < ResponseController
  def view_responses
    @type = params[:type]
    @course_eval = params[:course_eval]
    if @type == "assignment"
      @assignment = Assignment.find(params[:id])
      @responses = SurveyResponse.where('assignment_id = ?',params[:id])
      response_length = @responses.length
      if response_length == 0
        @empty = true
      end
    elsif @type =="course"
      @course = Course.find(params[:id])
    end
  end
end