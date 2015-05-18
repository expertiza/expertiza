class SurveyResponseController < ApplicationController

  def action_allowed?
    true
  end

  def begin_survey
    unless session[:user] #redirect to homepage if user not logged in
      redirect_to '/'
      return
    end

    @participants = AssignmentParticipant.where( ["user_id = ? and parent_id = ?", session[:user].id, params[:id]])
    if @participants.length == 0   #make sure the user is a participant of the assignment
      redirect_to '/'
      return
    end
  end

  def create

    if params[:course_eval] #Check if its a course evaluation
      @assigned_surveys = Questionnaire.find_all(params[:id])
      @survey = Questionnaire.find(params[:questionnaire_id])
      @questions = @survey.questions
      @course_eval=params[:course_eval]
      return
    end

    unless session[:user] && session[:assignment_id]  #redirect to homepage if user not logged in or session not tied to assignment
      redirect_to '/'
      return
    end

    begin
      @assignment = Assignment.find(params[:id])
      @assigned_surveys = SurveyHelper::get_all_available_surveys(@assignment.id, 1)

      if params[:submit]
        @submit_survey = Questionnaire.find(params[:survey_id])
        @submit_questions = @submit_survey.questions
        @scores = params[:score]
        @comments = params[:comments]
        for question in @submit_questions
          SurveyResponse.get_survey_response( params[:id], params[:survey_id], question.id, params[:email])
        end
      end

      @survey = @assigned_surveys[params[:count].to_i]
      @questions = @survey.questions
  rescue
    redirect_to '/'
    return
  end
end

def submit
  @submitted = true;
  @survey_id = params[:survey_id]
  @survey = Questionnaire.find(@survey_id)
  @questions = @survey.questions
  @scores = params[:score]
  @comments = params[:comments]
  @assignment_id = params[:assignment_id]
    for question in @questions
      SurveyResponseHelper::persist_survey(@survey_id, question.id, @assignment_id, params[:survey_deployment_id], params[:email])
    end


  if !params[:survey_deployment_id]
    surveys = SurveyHelper::get_assigned_surveys(@assignment_id)
  end
end

def view_responses

  if params[:course_eval] # Check if this is a course evaluation
    survey_id=SurveyDeployment.find(params[:id]).course_evaluation_id
    surveys = Questionnaire.where(["id=?", survey_id])
    @assignment=Assignment.new
    @assignment.name="Course Evaluation"
    @assignment.id=params[:id]
    @course_eval=params[:course_eval]
  else
    @assignment = Assignment.find(params[:id])
    surveys = SurveyHelper::get_all_available_surveys(params[:id], session[:user].role_id)
  end
  @responses = []
  @empty = true
  for survey in surveys
    min = survey.min_question_score
    max = survey.max_question_score
    this_response_survey = {}
    this_response_survey[:name] = survey.name
    this_response_survey[:id] = survey.id
    this_response_survey[:questions] = []
    this_response_survey[:empty] = true
    this_response_survey[:avg_labels] = []
    this_response_survey[:avg_values] = []
    this_response_survey[:max] = max
    if !params[:course_eval]

      survey_list = SurveyResponse.get_survey_list(params[:id], survey.id)
    else
      survey_list = SurveyResponse.get_survey_list_with_deploy_id( params[:id], survey.id)
    end
    if survey_list.length > 0
      @empty = false
      this_response_survey[:empty] = false
    end
    for question in survey.questions
      this_response_question = {}
      this_response_question[:name] = question.txt
      this_response_question[:id] = question.id
      this_response_question[:labels] = []
      this_response_question[:values] = []
      this_response_question[:count] = 0
      this_response_question[:average] = 0
      for i in min..max
        if !question.true_false? || i == min || i == max
          if !params[:course_eval]
            list = SurveyResponse.get_survey_list_with_score(params[:id], survey.id, question.id, i)
          elsif params[:course_eval]
            list = SurveyResponse.get_survey_list_with_deploy_id_and_score(params[:id], survey.id, question.id, i)
          end
          if question.true_false?
            if i == min
              this_response_question[:labels] << "False"
            else
              this_response_question[:labels] << "True"
            end
          else
            this_response_question[:labels] << i
          end
          this_response_question[:values] << list.length.to_s
          this_response_question[:average] += i*list.length
        end
      end
      if !params[:course_eval]
        no_of_question = SurveyResponse.get_no_of_questions_with_assignment_id(params[:id], survey.id, question.id)
      else
        no_of_question = SurveyResponse.get_no_of_questions_with_deployment_id(params[:id], survey.id, question.id)
      end
      this_response_question[:count] = no_of_question.length

      if this_response_question[:count] > 0
        @empty = false
        this_response_survey[:empty] = false
        this_response_question[:average] /= this_response_question[:count].to_f
        this_response_survey[:avg_labels] << this_response_question[:name][0..50]
        this_response_survey[:avg_values] << this_response_question[:average]
      end
      this_response_survey[:questions] << this_response_question
    end
    @responses << this_response_survey
  end
end

def comments
  unless params[:course_eval] # Check if survey is a course evaluation
    @responses = SurveyResponse.get_responses_comments_with_assignment_id(params[:assignment_id], params[:survey_id], params[:question_id])
  else
    @responses = SurveyResponse.get_responses_comments_with_deployment_id(params[:assignment_id], params[:survey_id], params[:question_id])
    @course_eval="1"
  end

  @question = Question.find(params[:question_id])
  @survey = Questionnaire.find(params[:survey_id])

  unless params[:course_eval]
    @assignment = Assignment.find(params[:assignment_id])
  else
    @assignment=Assignment.new
    @assignment.name="Course Evaluation"
  end

end
end
