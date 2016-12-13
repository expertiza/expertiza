

class SurveyController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end
  #E1680. Improve survey functionality commit by dssathe
  @assignment
  def assign
    @assignment = Assignment.find(params[:id])
    #Dummy row created which will be selected by default

    # If survey is already assigned to the assignment, 
    # flash warning to the user that he/she is attempting 
    # to overwrite it
    if !@assignment.survey_id.nil?
      flash[:error] = "You are attempting to overwrite existing assignment survey"
    end

    @first_row=Questionnaire.new;
    @first_row.name="Select a Global Survey";
    @first_row.id=0;
    @my_surveys=Questionnaire.where(["instructor_id=? and type = 'SurveyQuestionnaire'", session[:user].id]);
    @global_surveys = Questionnaire.where(["type = 'GlobalSurveyQuestionnaire'"]);
    # Currently last row in the collection but should be selected by default.
    @global_surveys<<@first_row
  end
  
  def assign_survey
    assignment_id = params[:assignment_id]
    # get the survey id from select tag
    selected_survey_id = params[:my_survey]
    # get the questionnaire object from the id
    # @selected_survey_questionnaire = Questionnaire.find(selected_survey_id)
    
    selected_global_survey_id = params[:global_survey]

    @assignment = Assignment.find(assignment_id)

    #Update the Survey Id with the selected Survey Id
    @assignment[:survey_id] = selected_survey_id
    @assignment.update!(@assignment_params)
    
    if selected_global_survey_id == 0
      #Update the Global Survey Id with the selected Global Survey Id
      @assignment[:global_survey_id] = selected_global_survey_id
      @assignment.update!(@assignment_params)
      flash[:success] = selected_global_survey_id
    end 
    
    flash[:success] = 'Survey has been successfuly assigned'
    # redirect back to the same page with same assignment id
    redirect_to action: "assign", id: assignment_id
    
  end
end
