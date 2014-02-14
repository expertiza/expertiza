class ReportsController < ApplicationController
  def view
    @response = Response.find(params[:id])
    return if redirect_when_disallowed(@response)
    @map = @response.map
    get_content
    get_scores
  end

  def new_feedback
    review = Response.find(params[:id])
    if review
      reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id, review.map.assignment.id)
      map = FeedbackResponseMap.find_by_reviewed_object_id_and_reviewer_id(review.id, reviewer.id)
      if map.nil?
        #if no feedback exists by dat user den only create for dat particular response/review
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
    # Check whether this is a custom rubric
    if @map.questionnaire.section.eql? "Custom"
      @question_type = Array.new
      @questions.each{
        | question |
        @question_type << QuestionType.find_by_question_id(question.id)
      }
      @next_action = "create"                                                                 #changed part of code changed from custom create to create
      render :action => 'custom_response'
    else
      render :action => 'response'
    end
  end

  def create
    @next_action = "view"
    @map = Response.find_by_id(params[:id])     #assignment/review/metareview id is in params id
    @res = 0
    msg = ""
    error_msg = ""
    latestResponseVersion(@map.map_id)
    #if previous responses exist increment the version number.
    if @array_not_empty==1
      @sorted=@review_scores.sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }
      @largest_version_num=@sorted[0]
      if (@largest_version_num.version_num==nil)
        @version=1
      else
        @version=@largest_version_num.version_num+1
      end

      #if no previous version is available then initial version number is 1
    else
      @version=1
    end

    @response = Response.find_by_id(params[:id])
    @response.additional_comment = params[:review][:comments]
    @response.version_num = @version
    @response.save

    #@response = Response.create(:map_id => @map.id, :additional_comment => params[:review][:comments],:version_num=>@version)

    @res = @response.response_id
    @questionnaire = @map.questionnaire
    questions = @questionnaire.questions
    params[:responses].each_pair do |k, v|
      score = Score.create(:response_id => @response.response_id, :question_id => questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
    end
  rescue
    error_msg = "Your response was not saved. Cause: "


    begin
      ResponseHelper.compare_scores(@response, @questionnaire)
      ScoreCache.update_cache(@res)
      #@map.save
      msg = "Your response was successfully saved."
    rescue

      @response.delete
      error_msg = "Your response was not saved. Cause: " + $!
    end

    redirect_to :controller => 'response', :action => 'saving', :id => @map.map_id, :return => params[:return], :msg => msg, :error_msg => error_msg, :save_options => params[:save_options]
  end

  def custom_create ###-### Is this used?  It is not present in the master branch.
    @map = ResponseMap.find(params[:id])
    @map.additional_comment = ""
    @map.save
    #@response = Response.create(:map_id => @map.id, :additional_comment => "")
    @res = @response.response_id
    @questionnaire = @map.questionnaire
    questions = @questionnaire.questions
    for i in 0..questions.size-1
      # Local variable score is unused; can it be removed?
      score = Score.create(:response_id => @response.response_id, :question_id => questions[i].id, :score => @questionnaire.max_question_score, :comments => params[:custom_response][i.to_s])
    end
    msg = "#{@map.get_title} was successfully saved."

    saving
  end

  def saving
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @map.notification_accepted = false
    @map.save
    #@map.assignment.id == 561 or @map.assignment.id == 559 or
    if (@map.assignment.id == 562) #Making the automated metareview feature available for one 'ethical analysis 6' assignment only.
      if (params["save_options"].nil? or params["save_options"].empty?) #default it to with metareviews
        params["save_options"] = "WithMeta"
    end
    #calling the automated metareviewer controller, which calls its corresponding model/view
    if (params[:save_options] == "WithMeta")
      redirect_to :controller => 'automated_metareviews', :action => 'list', :id => @map.map_id
    elsif (params[:save_options] == "EmailMeta")
      redirect_to :action => 'redirection', :id => @map.map_id, :return => params[:return], :msg => params[:msg], :error_msg => params[:error_msg]
      # calculate the metareview metrics
      @automated_metareview = AutomatedMetareview.new
      #pass in the response id as a parameter
      @response = Response.find_by_map_id(params[:id])
      @automated_metareview.calculate_metareview_metrics(@response, params[:id])
      #send email to the reviewer with the metareview details
      @automated_metareview.send_metareview_metrics_email(@response, params[:id])
    elsif (params[:save_options] == "WithoutMeta")
      redirect_to :action => 'redirection', :id => @map.map_id, :return => params[:return], :msg => params[:msg], :error_msg => params[:error_msg]
    end
    else
      redirect_to :action => 'redirection', :id => @map.id, :return => params[:return], :msg => params[:msg], :error_msg => params[:error_msg]
    end
  end

  def redirection
    flash[:error] = params[:error_msg] unless params[:error_msg] and params[:error_msg].empty?
    flash[:note] = params[:msg] unless params[:msg] and params[:msg].empty?

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
    @participant = @map.reviewer
    @contributor = @map.contributor
    @questionnaire = @map.questionnaire
    @questions = @questionnaire.questions
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score
  end

  def redirect_when_disallowed(response)
    # For author feedback, participants need to be able to read feedback submitted by other teammates.
    # If response is anything but author feedback, only the person who wrote feedback should be able to see it.
    if response.map.read_attribute(:type) == 'FeedbackResponseMap' && response.map.assignment.team_assignment?
      team = response.map.reviewer.team
      unless team.has_user session[:user]
        redirect_to '/denied?reason=You are not on the team that wrote this feedback'
      else
        return false
      end
      response.map.read_attribute(:type)
    end
    !current_user_id?(response.map.reviewer.user_id)
  end

end
