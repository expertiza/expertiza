
class SurveyController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end
  #E1680. Improve survey functionality commit by dssathe
  def assign
    @assignment = Assignment.find(params[:id])
    @my_surveys=Questionnaire.where(["instructor_id=? and type = 'SurveyQuestionnaire'", session[:user].id]);
    @global_surveys=Questionnaire.where(["type = 'GlobalSurveyQuestionnaire'"]);
  end
end
