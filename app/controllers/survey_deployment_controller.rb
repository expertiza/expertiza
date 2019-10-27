class SurveyDeploymentController < ApplicationController
  include SurveyDeploymentHelper
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  def survey_deployment_types
    %w[AssignmentSurveyDeployment
       CourseSurveyDeployment]
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
      flash[:error] = "Unexpected type. Check your dates! Dates should be in the future. "
    end

    if params[:type]
      @survey_deployment_type = params[:type]
      @survey_type = params[:type].sub("Deployment", "Questionnaire")
    end

    # Get the list of surveys that match the deployment type
    case @survey_type
    when "AssignmentSurveyQuestionnaire"
      @surveys = Questionnaire.where(type: "AssignmentSurveyQuestionnaire").map {|u| [u.name, u.id] }
    when "CourseSurveyQuestionnaire"
      @surveys = Questionnaire.where(type: "CourseSurveyQuestionnaire").map {|u| [u.name, u.id] }
    else
      flash[:error] = "Unexpected type. Check your dates! Dates should be in the future."
      redirect_to '/tree_display/list'
    end
  end

  def new_assignment_deployment
    @parent = Assignment.find(params[:id])
    @total_students = AssignmentParticipant.where(parent_id: @parent.id).count
  end

  def new_course_deployment
    @parent = Course.find(params[:id])
    @total_students = CourseParticipant.where(parent_id: @parent.id).count
  end

  def param_test
    params.require(:survey_deployment).permit(:questionnaire_id, :start_date, :end_date, :parent_id)
  end

  def create
    if params[:add_global_survey]
      global = GlobalSurveyQuestionnaire.find_by(private: false)
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
      redirect_to '/tree_display/list'
    end
  end

  def list
    @survey_deployments = SurveyDeployment.all
    @survey_questionnaires = {}
    @survey_deployments.each do |sd|
      corresp_questionnaire_name = Questionnaire.find(sd.questionnaire_id).name
      @survey_questionnaires[sd.id] = corresp_questionnaire_name
    end
  end

  # This delete does not test if any response_map or response has been created.
  # Therefore it may bring in dirty data.
  def delete
    survey_deployment = SurveyDeployment.find(params[:id])
    survey_deployment.response_maps.each(&:destroy)
    GlobalSurveyResponseMap.where(reviewee_id: params[:id]).each(&:destroy)
    survey_deployment.destroy
    redirect_to action: 'list'
  end

  # Creates pie charts for visualizing survey responses to Criterion and Checkbox questions
  def generate_statistics
    @sd = SurveyDeployment.find(params[:id])
    questionnaire = if params[:global_survey] == 'true'
                      Questionnaire.find(@sd.global_survey_id)
                    else
                      Questionnaire.find(@sd.questionnaire_id)
                    end
    @range_of_scores = (questionnaire.min_question_score..questionnaire.max_question_score).to_a
    @questions = Question.where(questionnaire_id: questionnaire.id)
    responses_for_all_questions = []
    @questions.each do |question|
      responses_for_all_questions << get_responses_for_question_in_a_survey_deployment(question.id, @sd.id)
    end
    # @chart_data_table is passed to the JavaScript code in the view
    # Google Charts requires a 2-D Data Table to create a chart, @chart_data_table is 3-D because there are multiple charts
    @chart_data_table = []
    responses_for_all_questions.each do |response|
      data_table_row = []
      data_table_row << %w[Label Number]
      label_value = @range_of_scores.first
      response.each_with_index do |response_value, _index|
        data_table_row << [label_value.to_s, response_value]
        label_value += 1
      end
      @chart_data_table << data_table_row
    end
  end

  # Allows for children to redirect to this controller
  def self.inherited(child)
    child.instance_eval do
      def model_name
        SurveyDeployment.model_name
      end
    end
    super
  end

  def pending_surveys
    unless session[:user] # Check for a valid user
      redirect_to '/'
      return
    end
    @surveys = [] # Get all the course survey deployments for this user
    [CourseParticipant, AssignmentParticipant].each do |participant_type| # Get all the participant(course or assignment) entries for this user
      participants = participant_type.where(user_id: session[:user].id)
      next unless participants
      participants.each do |p|
        survey_deployment_type = (participant_type == CourseParticipant ? CourseSurveyDeployment : AssignmentSurveyDeployment)
        survey_deployments = survey_deployment_type.where(parent_id: p.parent_id)
        next unless survey_deployments
        survey_deployments.each do |survey_deployment|
          next unless survey_deployment && Time.zone.now > survey_deployment.start_date && Time.zone.now < survey_deployment.end_date
          @surveys <<
              ['survey' => Questionnaire.find(survey_deployment.questionnaire_id),
               'survey_deployment_id' => survey_deployment.id,
               'start_date' => survey_deployment.start_date,
               'end_date' => survey_deployment.end_date,
               'parent_id' => p.parent_id,
               'participant_id' => p.id,
               'global_survey_id' => survey_deployment.global_survey_id]
        end
      end
    end
  end

  # This method should be moved to survey_deployment_controller.rb
  def view_responses
    sd = SurveyDeployment.find(params[:id])
    @questionnaire = Questionnaire.find(sd.questionnaire_id)
    @questions = Question.where(questionnaire_id: @questionnaire.id)
    response_map_list = ResponseMap.where(reviewee_id: sd.id)
    # retrieve all the answers on this survey based on survey_response_maps and questions
    @all_answers = list_answers(@questions, response_map_list)
    @global_survey_present = false

    if sd.global_survey_id
      @global_survey_present = true
      @global_questionnaire = Questionnaire.find(sd.global_survey_id)
      @global_questions = Question.where(questionnaire_id: @global_questionnaire.id)
      # retrieve all the answers on the global survey based on this survey deploment.
      # Please note that, for a survey deployment which requires taking a global survey,
      # there will be two different response_maps.
      @global_answers = list_answers(@global_questions, response_map_list)
    end
  end

  private

  # this method should be moved to another place with view_responses.
  def list_answers(questions, response_map_list)
    all_answers = []
    questions.each do |question|
      answers = []
      response_map_list.each do |response_map|
        response_list = Response.where(map_id: response_map.id)
        response_list.each do |response|
          an_answer = Answer.where(question_id: question.id, response_id: response.id).first
          answers << an_answer if an_answer.present?
        end
      end
      all_answers << answers unless answers.empty?
    end
    all_answers
  end
end
