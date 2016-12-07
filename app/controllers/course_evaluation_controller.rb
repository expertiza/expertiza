class CourseEvaluationController < ApplicationController
  def action_allowed?
    current_role_name.eql?("Student")
  end

  def list # list course evaluations for a user
    unless session[:user] # Check for a valid user
      redirect_to '/'
      return
    end
    deployments = Participants.where(user_id: session[:user].id)
    @surveys = []
    deployments.each do |sd|
      if sd.type == 'AssignmentParticipant'
        @assignment = Assignment.find(sd.parent_id)
       
        if !@assignment.survey_id.nil?
           @surveys << [Questionnaire.find(@assignment.survey_id)]
        end
        
        if !@assignment.global_survey_id.nil?
           @surveys << [Questionnaire.find(@assignment.global_survey_id)]
        end
      end
      
      if sd.type == 'AssignmentParticipant'
        @course = Course.find(sd.parent_id)
       
        if !@course.survey_id.nil?
           @surveys << [Questionnaire.find(@course.survey_id)]
        end
        
        if !@course.global_survey_id.nil?
           @surveys << [Questionnaire.find(@course.global_survey_id)]
        end
      end
      
      # survey_deployment = SurveyDeployment.find(sd.survey_deployment_id)
      # if Time.now > survey_deployment.start_date && Time.now < survey_deployment.end_date
       # @surveys << [Questionnaire.find(survey_deployment.course_evaluation_id), sd.survey_deployment_id, survey_deployment.end_date, survey_deployment.course_id]
      #end
        
    end
  end
end
