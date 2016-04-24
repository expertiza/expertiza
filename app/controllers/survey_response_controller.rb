class SurveyResponseController < ResponseController
  def view_responses
    @type = params[:type]
    if @type == "assignment"
      @assignment = Assignment.find(params[:id])
      @responses = SurveyResponse.where('assignment_id = ?',params[:id])
      response_length = @responses.length
      if response_length == 0
        @empty = true
      end
    end
  end
end