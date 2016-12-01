class SurveyController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end
  #E1680. Improve survey functionality commit by dssathe
  def assign
    @my_surveys=Questionnaire.all;
    @global_surveys=Questionnaire.all;
  end
end
