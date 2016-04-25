class CourseSurveyController < ApplicationController
  def action_allowed?
    current_role_name.eql?("Student")
  end

  def list
    unless session[:user] #Check for a valid user
      redirect_to '/'
      return
    end
   @questionnaires = CourseQuestionnaire.where("course_id = ?", params[:course_id])
    #@questionnaires = Questionnaire.all
 end
end