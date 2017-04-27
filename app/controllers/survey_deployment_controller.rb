
class SurveyDeploymentController < ApplicationController
  include SurveyDeploymentHelper
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  def new
    @surveys = Questionnaire.where("type in ('CourseEvaluationQuestionnaire', 'SurveyQuestionnaire', 'GlobalSurveyQuestionnaire')").map {|u| [u.name, u.id] }
    @course = Course.where(instructor_id: session[:user].id).map {|u| [u.name, u.id] }
    @total_students = CourseParticipant.where(parent_id: @course[0][1]).count
  end

  def param_test
    params.require(:survey_deployment).permit(:course_evaluation_id,:num_of_students,:start_date,:end_date,:validate_survey_deployment)

  end

  def create
    @survey_deployment = SurveyDeployment.new(param_test)
    if params[:random_subset]["value"] == "1"
      @survey_deployment.num_of_students = User.where(role_id: Role.student.id).length * rand
    end
    if @survey_deployment.save
      redirect_to action: 'list'
    else
      @surveys = Questionnaire.where(type: 'CourseEvaluationQuestionnaire').map {|u| [u.name, u.id] }
      @course = Course.where(instructor_id: session[:user].id).map {|u| [u.name, u.id] }
      @total_students = CourseParticipant.where(parent_id: @course[0][1]).count
      render(action: 'new')
    end
  end

  def list
    @survey_deployments = SurveyDeployment.all
    @surveys = {}
    @survey_deployments.each do |sd|
      if(sd.course_evaluation_id.nil?)
        corresp_questionnaire_name = "Nil"
      else
        corresp_questionnaire_name = Questionnaire.find(sd.course_evaluation_id).name
      end
      @surveys[sd.id] = corresp_questionnaire_name

    end
  end

  def delete
    SurveyDeployment.find(params[:id]).destroy
    SurveyParticipant.where(survey_deployment_id: params[:id]).each(&:destroy)
    SurveyResponse.where(survey_deployment_id: params[:id]).each(&:destroy)
    redirect_to action: 'list'
  end

  def add_participants(num_of_participants, survey_deployment_id) # Add participants
    users = User.where(role_id: Role.student.id)
    users_rand = users.sort_by { rand } # randomize user list
    num_of_participants.times do |i|
      survey_participant = SurveyParticipant.new
      survey_participant.user_id = users_rand[i].id
      survey_participant.survey_deployment_id = survey_deployment_id
      survey_participant.save
    end
  end

  def generate_statistics
    @sd = SurveyDeployment.find(params[:id])
    questionnaire = Questionnaire.find(@sd.course_evaluation_id)
    @range_of_scores = (questionnaire.min_question_score..questionnaire.max_question_score).to_a
    @questions = Question.where(questionnaire_id: questionnaire.id)
    responses_for_all_questions = []
    @questions.each do |question|
      responses_for_all_questions << get_responses_for_question_in_a_survey_deployment(question.id, @sd.id)
    end
    @chart_data_table = []
    responses_for_all_questions.each_with_index do |response, index|
      data_table_row = []
      data_table_row << ['Label', 'Number']
      response.each_with_index do |response_value, index|
        data_table_row << [index.to_s, response_value]
      end
      @chart_data_table << data_table_row
    end
  end
end
