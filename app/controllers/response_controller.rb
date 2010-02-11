class ResponseController < ApplicationController
  helper :wiki
  helper :submitted_content
  helper :file
  
  def view
    @response = Response.find(params[:id])
    @map = @response.map
    get_content  
  end   
  
  def delete    
    @response = Response.find(params[:id])
    map_id = @response.map.id
    @response.delete
    redirect_to :action => 'redirection', :id => map_id, :return => params[:return], :msg => "The response was deleted."
  end
  
  def edit    
    @header = "Edit"
    @next_action = "update"
    
    @return = params[:return]
    @response = Response.find(params[:id]) 
    @modified_object = @response.id
    @map = @response.map           
    get_content    
    @review_scores = Array.new
    @questions.each{
      | question |
      @review_scores << Score.find_by_response_id_and_question_id(@response.id, question.id)
    }
    render :action => 'response'
  end  
  
  def update
    @response = Response.find(params[:id])
    @myid = @response.id
    msg = ""
    begin 
        @myid = @response.id
      @map = @response.map
      @response.update_attribute('additional_comment',params[:review][:comments])
      
      @questionnaire = @map.questionnaire
      questions = @questionnaire.questions

      params[:responses].each_pair do |k,v|
        score = Score.find_by_response_id_and_question_id(@response.id, questions[k.to_i].id)
        score.update_attribute('score',v[:score])
        score.update_attribute('comments',v[:comment])
      end    
   update_cache(@myid)
    rescue
      msg = "#{@map.get_title} was not saved."
    end

    begin
       ResponseHelper.compare_scores(@response, @questionnaire)
   #   ScoreCache.update_cache(@response.id)
       update_cache(@myid)
      msg = "#{@map.get_title} was successfully saved -- #{@myid}."
    rescue
      msg = "An error occurred while saving the response: "+$!
    end
    redirect_to :controller => 'response', :action => 'saving', :id => @map.id, :return => params[:return], :msg => msg
  end  
  
  def new_feedback
    review = Response.find(params[:id])
    if review
      reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id, review.map.assignment.id)
      map = FeedbackResponseMap.find_by_reviewed_object_id_and_reviewer_id(review.id, reviewer.id)
      if map.nil?
        map = FeedbackResponseMap.create(:reviewed_object_id => review.id, :reviewer_id => reviewer.id, :reviewee_id => review.map.reviewer.id)
      end
      redirect_to :action => 'new', :id => map.id, :return => "feedback"
    else
      redirect_to :back
    end
  end
  
  def new
    @header = "New"
    @next_action = "create"    
    @feedback = params[:feedback]
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @modified_object = @map.id
    get_content    
    render :action => 'response'
  end
  
  def create     
    @map = ResponseMap.find(params[:id])
    @res = 0
    msg = ""
    #begin      
      @response = Response.create(:map_id => @map.id, :additional_comment => params[:review][:comments])
      @res = @response.id
      @questionnaire = @map.questionnaire
      questions = @questionnaire.questions     
      params[:responses].each_pair do |k,v|
        score = Score.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
      end  
    #rescue
    #  msg = "#{@map.get_title} was not saved. Cause: "+$!
    #end
    
    #begin
      ResponseHelper.compare_scores(@response, @questionnaire)
      update_cache(@res)
      msg = "#{@map.get_title} was successfully saved."
    #rescue
    #  @response.delete
    #  msg = "#{@map.get_title} was not saved. Cause: "+$!
    #end
    redirect_to :controller => 'response', :action => 'saving', :id => @map.id, :return => params[:return], :msg => msg
  end      
  
  def saving
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @msg = params[:msg]
  end
  
  def redirection
    @map = ResponseMap.find(params[:id])
    if params[:return] == "feedback"
      redirect_to :controller => 'grades', :action => 'view_my_scores', :id => @map.reviewer.id
    elsif params[:return] == "teammate"
      redirect_to :controller => 'student_team', :action => 'view', :id => @map.reviewer.id
    elsif params[:return] == "instructor"
      redirect_to :controller => 'grades', :action => 'view', :id => @map.assignment.id
    else
      redirect_to :controller => 'student_review', :action => 'list', :id => @map.reviewer.id
    end 
  end
  
  private
    
  def get_content    
    @title = @map.get_title 
    @assignment = @map.assignment
    @participant = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id,@assignment.id)    
    @files = @participant.get_submitted_files()
    @questionnaire = @map.questionnaire
    @questions = @questionnaire.questions
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score     
  end
def update_cache(rid)
 
  presenceflag = 0
   @ass_id = 0
   @userset = []
   @team = 0
   @team_number = 0
   @teamass = 0
   @reviewmap = Response.find(rid).map_id
   @rm = ResponseMap.find(@reviewmap)
   @participant1 = AssignmentParticipant.new
    @the_object_id = 90
    @map_type = @rm.type.to_s
    @t_score = 0
    @t_min = 0
    @teammember = TeamsUser.new
    @t_max = 0
    @myfirst = "before"
    
   
    
    #if (@map_type == "ParticipantReviewResponseMap")
      if(@map_type == "TeamReviewResponseMap")
                @ass_id = @rm.reviewed_object_id
                @assignment1 = Assignment.find(@ass_id)
                @teammember =  TeamsUser.find(:first, :conditions => ["team_id = ?",@rm.reviewee_id])
                @participant1 = AssignmentParticipant.find(:first, :conditions =>["user_id = ? and parent_id = ?", @teammember.user_id, @ass_id])
                @the_object_id = @teammember.team_id
       
     else
                @participant1 = AssignmentParticipant.find(@rm.reviewee_id)
                @the_object_id = @participant1.id
                @assignment1 = Assignment.find(@participant1.parent_id)
                @ass_id = @assignment1.id

 
     end
        
            
            
    
    
            @questions = Hash.new    
            questionnaires = @assignment1.questionnaires
            questionnaires.each{
                     |questionnaire|
                     @questions[questionnaire.symbol] = questionnaire.questions
              } 
           @allscores = @participant1.get_scores( @questions)
             
            @scorehash = get_my_scores(@allscores, @map_type) 
          
            
                @p_score = @scorehash[:avg]               
                @p_min = @scorehash[:min]
                @p_max = @scorehash[:max]
            
            sc = ScoreCache.find(:first,:conditions =>["assignment_id = ? and object_id = ? and object_type = ?", @ass_id , @the_object_id, @map_type ])
          if ( sc == nil)
               presenceflag = 1
               @msgs = "first entry"
                sc = ScoreCache.new
                sc.object_id = @the_object_id
                sc.assignment_id = @ass_id
                sc.range = @p_min.to_s + "-" + @p_max.to_s
                 sc.score = @p_score
                if @thiscourse != nil
                  sc.course_id = @thiscourse.id
                end
                sc.object_type = @map_type                        
                
                sc.save
            # make another new tuple for new score
            else
              if @thiscourse != nil
                  sc.course_id = @thiscourse.id
               end
                sc.range = @p_min.to_s + "-" + @p_max.to_s
                sc.score = @p_score
                presenceflag = 2
                sc.update
            #look for a consolidated score and change
            end               
 
    
    
    
    
    #########################
    end
    
    
 
    
    
  
  
  def get_my_scores( scorehash, map_type)
    
     @p_score = 0
     @p_min = 0  
     @p_max = 0
     
#  ParticipantReviewResponseMap - Review mappings for single user assignments
#  TeamReviewResponseMap - Review mappings for team based assignments
#  MetareviewResponseMap - Metareview mappings
#  TeammateReviewResponseMap - Review mapping between teammates
#  FeedbackResponseMap - Feedback from author to reviewer
 
 
     if(map_type == "ParticipantReviewResponseMap")
            
            if (scorehash[:review])
                @p_score = scorehash[:review][:scores][:avg]               
                @p_min = scorehash[:review][:scores][:min]
                @p_max = scorehash[:review][:scores][:max]
            end
      elsif (map_type == "TeamReviewResponseMap")
           if (scorehash[:review])
                @p_score = scorehash[:review][:scores][:avg]               
                @p_min = scorehash[:review][:scores][:min]
                @p_max = scorehash[:review][:scores][:max]
            end
 
        elsif (map_type == "TeammateReviewResponseMap")
           if (scorehash[:review])
                @p_score = scorehash[:teammate][:scores][:avg]               
                @p_min = scorehash[:teammate][:scores][:min]
                @p_max = scorehash[:teammate][:scores][:max]
            end
    
      elsif (map_type == "MetareviewResponseMap")
            if (scorehash[:metareview])
                @p_score = scorehash[:metareview][:scores][:avg]               
                @p_min = scorehash[:metareview][:scores][:min]
                @p_max = scorehash[:metareview][:scores][:max]
            end
      elsif (map_type == "FeedbackResponseMap")
         if (scorehash[:feedback])
                @p_score = scorehash[:feedback][:scores][:avg]               
                @p_min = scorehash[:feedback][:scores][:min]
                @p_max = scorehash[:feedback][:scores][:max]
            end
       end 
     @scoreset = Hash.new
     @scoreset[:avg] = @p_score
     @scoreset[:min] = @p_min
     @scoreset[:max] = @p_max
     return @scoreset
  end
  
   
    
  
    
  
  
end
