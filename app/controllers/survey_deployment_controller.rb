
class SurveyDeploymentController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  def new
    @surveys = SurveyQuestionnaire.where("type in ('CourseEvaluationQuestionnaire', 'SurveyQuestionnaire')").map {|u| [u.name, u.id] }
    @course = Course.where(instructor_id: session[:user].id).map {|u| [u.name, u.id] }
    @total_students = CourseParticipant.where(parent_id: @course[0][1]).count
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
    @survey_deployment = SurveyDeployment.new(param_test.merge(global_survey_id: global_id))
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

  def reminder_thread
    # Check status of  reminder thread
    @reminder_thread_status = "Running"
    unless MiddleMan.get_worker(session[:reminder_key])
      @reminder_thread_status = "Not Running"
    end
  end

  def toggle_reminder_thread
    # Create reminder thread using BackgroundRb or kill it if its already running
    if MiddleMan.get_worker(session[:reminder_key])
      MiddleMan.delete_worker(session[:reminder_key])
      session[:reminder_key] = nil
    else
      session[:reminder_key] = MiddleMan.new_worker class: :reminder_worker, args: {num_reminders: 3} # 3 reminders for now
    end
    redirect_to action: 'reminder_thread'
  end
end
