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
      @survey_deployment = SurveyDeployment.where('course_id = ?', @course.id)
      if @survey_deployment.nil?
        @empty = true
      else
        
        survey_dep_id = @survey_deployment[0].id
        
        @responses = SurveyResponse.where('survey_deployment_id = ?', survey_dep_id)
        
      end


    end
  end
  def new_course_survey_response
    @survey_response_questionnaire = SurveyQuestionnaire.new
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
    @questions = Question.where('questionnaire_id = ?',params[:questionnaire_id])
  end

  def submit

  end
end
