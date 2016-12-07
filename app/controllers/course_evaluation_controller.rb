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
    @assignment_surveys = []
    @global_surveys = []
    @course_evaluation_surveys = [] 
    deployments.each do |sd|
      # for assignment participants, find the questionnaire assigned to that 
      # assignment and add the details to list according to 
      
      @is_survey_submitted = 0
      @is_global_survey_submitted = 0
      @survey_response_id = nil
      @global_survey_response_id = nil
      response_map = []
      response_map = ResponseMap.where(["reviewed_object_id = ? and reviewer_id = ?" , sd.parent_id , session[:user].id])
      if response_map.size > 0
        response_map.each do |rm|
          @response = Response.where(map_id = rm.id)
          if !@response.nil?
            if rm.type == 'SurveyResponseMap'
              @is_survey_submitted = @response.is_submitted
              @survey_response_id = @response.id
            end
            if rm.type == 'GlobalSurveyResponseMap'
              @is_global_survey_submitted = @response.is_submitted
              @global_survey_response_id = @response.id
            end  
          end  
        end
      end  
      
      
      if sd.type == 'AssignmentParticipant'
        @assignment = Assignment.find(sd.parent_id)
        
        # add survey assigned to the assignment in the respective survey list
        if !@assignment.survey_id.nil?
           @assignment_surveys << [Questionnaire.find(@assignment.survey_id) , @assignment.id, @is_survey_submitted, @survey_response_id] 
        end
        # add global survey assigned to the assignment in the respective survey list
        if !@assignment.global_survey_id.nil?
           @global_surveys << [Questionnaire.find(@assignment.global_survey_id) , @assignment.id, @is_global_survey_submitted, @global_survey_response_id]
        end
      end
      
      # same for the course participant, except find the course object instead of assignment object
      if sd.type == 'CourseParticipant'
        @course = Course.find(sd.parent_id)
       
        if !@course.survey_id.nil?
           @course_evaluation_surveys << [Questionnaire.find(@course.survey_id) , @course.id, @is_survey_submitted, @survey_response_id]
        end
        
        if !@course.global_survey_id.nil?
           @global_surveys << [Questionnaire.find(@course.global_survey_id) , @course.id , @is_global_survey_submitted, @global_survey_response_id]
        end
      end
      
      # survey_deployment = SurveyDeployment.find(sd.survey_deployment_id)
      # if Time.now > survey_deployment.start_date && Time.now < survey_deployment.end_date
       # @surveys << [Questionnaire.find(survey_deployment.course_evaluation_id), sd.survey_deployment_id, survey_deployment.end_date, survey_deployment.course_id]
      #end
        
    end
  end
end
