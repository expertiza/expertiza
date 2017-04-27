
class SurveyDeploymentController < ApplicationController
  include SurveyDeploymentHelper
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  def survey_deployment_types
    ["AssignmentSurveyDeployment",
    "CourseSurveyDeployment"]
  end

  def survey_deployment_type
    params[:type].constantize if params[:type].in? survey_deployment_types
  end

  def new
    case params[:type]
      when "AssignmentSurveyDeployment"
        new_assignment_deployment
      when "CourseSurveyDeployment"
        new_course_deployment
      else
        flash[:error] = "Unexpected type " + params[:type]
    end
    @survey_type = params[:type]
    @surveys = SurveyQuestionnaire.where("type in ('SurveyQuestionnaire')").map {|u| [u.name, u.id] }
  end

  def new_assignment_deployment
    @parent = Assignment.find_by_id( params[:id])
    @total_students = AssignmentParticipant.where(parent_id: @parent.id).count
  end

  def new_course_deployment
    @parent = Course.find_by_id( params[:id])
    puts @parent.id
    @total_students = CourseParticipant.where(parent_id: @parent.id).count
  end

  def param_test
    params.require(:survey_deployment).permit(:questionnaire_id,:start_date,:end_date,:validate_survey_deployment,:parent_id,:num_of_students)
  end

  def create
    if params[:add_global_survey]
      global = GlobalSurveyQuestionnaire.find_by_private(false)
      if global.nil?
        flash[:error] = "No global survey available"
        return redirect_to action: 'new'
      else
          global_id = global.id
      end
    else
      global_id = nil
    end
    @survey_deployment = survey_deployment_type.new(param_test.merge(global_survey_id: global_id))
    if @survey_deployment.save
      redirect_to action: 'list'
    else
      flash[:error] = @survey_deployment.errors.full_messages.to_sentence
      redirect_to action: 'new'
    end
  end

  def list
    @survey_deployments = SurveyDeployment.all
    @surveys = {}
    @survey_deployments.each do |sd|
      if(sd.questionnaire_id.nil?)
        corresp_questionnaire_name = "Nil"
      else
        corresp_questionnaire_name = Questionnaire.find(sd.questionnaire_id).name
      end
      @surveys[sd.id] = corresp_questionnaire_name

    end
  end

  def delete
    SurveyDeployment.find(params[:id]).destroy
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

  #Allows for children to rediect to this controller
  def self.inherited(child)
    child.instance_eval do
      def model_name
        SurveyDeployment.model_name
      end
    end
    super
  end

end
