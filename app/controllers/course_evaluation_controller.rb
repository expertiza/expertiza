class CourseEvaluationController < ApplicationController
  def action_allowed?
    current_role_name.eql?("Student")
  end
    
  # create a response map and redirect to response controller 
  def create_response_map
    # replace 'Questionnaire' part in type by 'ResponseMap'
    @type=params[:type].sub("Questionnaire","ResponseMap")
    # set attributes in response map and save the record
    @res_map=ResponseMap.new(reviewed_object_id: params[:parent_id], reviewee_id: params[:parent_id], reviewer_id:session[:user].id, type: @type )
    @res_map.save!
    # call response controller with the newly created responsemap id and return type
    redirect_to controller: "response" , action: "new" , id: @res_map.id, return: @res_map.type
    
  end

  def list # list course evaluations for a user
    unless session[:user] # Check for a valid user
      redirect_to '/'
      return
    end
    # get all the instances of logged in user from participants table
    deployments = Participant.where(user_id: session[:user].id)
    # create lists of tuples which will contain survey_id and assignment_id
    # there will be seperate list for each of the survey type
    @assignmentsurveys = []
    @globalsurveys = []
    @courseevaluationsurveys = [] 
    deployments.each do |sd|
      # for assignment participants, find the questionnaire assigned to that 
      # assignment and add the details to list according to 
      if sd.type == 'AssignmentParticipant'
        @assignment = Assignment.find(sd.parent_id)
        
        # add survey assigned to the assignment in the respective survey list
        if !@assignment.survey_id.nil?
           @assignmentsurveys << [Questionnaire.find(@assignment.survey_id) , @assignment.id ] 
        end
        # add global survey assigned to the assignment in the respective survey list
        if !@assignment.global_survey_id.nil?
           @globalsurveys << [Questionnaire.find(@assignment.global_survey_id) , @assignment.id ]
        end
      end
      
      # same for the course participant, except find the course object instead of assignment object
      if sd.type == 'CourseParticipant'
        @course = Course.find(sd.parent_id)
       
        if !@course.survey_id.nil?
           @courseevaluationsurveys << [Questionnaire.find(@course.survey_id) , @course.id ]
        end
        
        if !@course.global_survey_id.nil?
           @globalsurveys << [Questionnaire.find(@course.global_survey_id) , @course.id ]
        end
      end
      
      # survey_deployment = SurveyDeployment.find(sd.survey_deployment_id)
      # if Time.now > survey_deployment.start_date && Time.now < survey_deployment.end_date
       # @surveys << [Questionnaire.find(survey_deployment.course_evaluation_id), sd.survey_deployment_id, survey_deployment.end_date, survey_deployment.course_id]
      #end
        
    end
  end
end
