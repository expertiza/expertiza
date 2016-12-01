

class SurveyController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end
  #E1680. Improve survey functionality commit by dssathe
  def assign
    @assignment = Assignment.find(params[:id])
    #Dummy row created which will be selected by default
    @first_row=Questionnaire.new;
    @first_row.name="Select a Global Survey";
    @first_row.id=0;
    @my_surveys=Questionnaire.where(["instructor_id=? and type = 'SurveyQuestionnaire'", session[:user].id]);
    @global_surveys = Questionnaire.where(["type = 'GlobalSurveyQuestionnaire'"]);
    @global_surveys << @first_row
    @global_surveys.sort{ |p1, p2| p1.id <=> p2.id }
   
  end
end
