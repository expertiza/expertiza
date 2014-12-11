class ResponseController < ApplicationController
  helper :wiki
  helper :submitted_content
  helper :file

  def action_allowed?
    current_user
  end

  def latestResponseVersion
    #get all previous versions of responses for the response map.
    @review_scores=Array.new
    @prev=Response.where(map_id: @map.id)
    for element in @prev
      @review_scores << element
    end
  end

  def get_scores
    @review_scores = []
    @question_type = []
    @questions.each do |question|
      @review_scores << Score
        .where(
          response_id: @response.id,
          question_id:  question.id
        ).first
      @question_type << QuestionType.find_by_question_id(question.id)
    end
  end

  def delete
    @response = Response.find(params[:id])
    return if redirect_when_disallowed(@response) #user cannot delete other people's responses. Needs to be authenticated.
    map_id = @response.map.id
    @response.delete
    redirect_to :action => 'redirection', :id => map_id, :return => params[:return], :msg => "The response was deleted."
  end

  #Determining the current phase and check if a review is already existing for this stage.
  #If so, edit that version otherwise create a new version.
  def rereview
    @map=ResponseMap.find(params[:id])
    get_content
    array_not_empty=0
    @review_scores=Array.new
    @prev=Response.all
    #get all versions and find the latest version
    for element in @prev
      if (element.map.id==@map.map.id)
        array_not_empty=1
        @review_scores << element
      end
    end

    latestResponseVersion
    #sort all the available versions in descending order.
    if @prev.present?
      @sorted=@review_scores.sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }
      @largest_version_num=@sorted[0]
      @latest_phase=@largest_version_num.created_at
      due_dates = DueDate.where(["assignment_id = ?", @assignment.id])
      @sorted_deadlines=Array.new
      @sorted_deadlines=due_dates.sort { |m1, m2| (m1.due_at and m2.due_at) ? m1.due_at <=> m2.due_at : (m1.due_at ? -1 : 1) }
      current_time=Time.new.getutc
      #get the highest version numbered review
      next_due_date=@sorted_deadlines[0]
      #check in which phase the latest review was done.
      for deadline_version in @sorted_deadlines
        if (@largest_version_num.created_at < deadline_version.due_at)
          break
        end
      end
      for deadline_time in @sorted_deadlines
        if (current_time < deadline_time.due_at)
          break
        end
      end
    end
    #check if the latest review is done in the current phase.
    #if latest review is in current phase then edit the latest one.
    #else create a new version and update it.
    # editing the latest review
    if (deadline_version.due_at== deadline_time.due_at)
      #send it to edit here
      @header = "Edit"
      @next_action = "update"
      @return = params[:return]
      @response = Response.where(map_id: params[:id], version_num:  @largest_version_num.version_num).first
      return if redirect_when_disallowed(@response)
      @modified_object = @response.response_id
      @map = @response.map
      get_content
      @review_scores = Array.new
      @questions.each {
          |question|
          @review_scores << Score.where(response_id: @response.response_id, question_id:  question.id).first
      }
      #**********************
      # Check whether this is Jen's assgt. & if so, use her rubric
      if (@assignment.instructor_id == User.find_by_name("jace_smith").id) && @title == "Review"
        if @assignment.id < 469
          @next_action = "update"
          render :action => 'custom_response'
        else
          @next_action = "update"
          render :action => 'custom_response_2011'
        end
      else
        # end of special code (except for the end below, to match the if above)
        #**********************
        render :action => 'response'
      end
    else
      #else create a new version and update it.
      @header = "New"
      @next_action = "create"
      @feedback = params[:feedback]
      @map = ResponseMap.find(params[:id])
      @return = params[:return]
      @modified_object = @map.map_id
      get_content
      #**********************
      # Check whether this is Jen's assgt. & if so, use her rubric
      if (@assignment.instructor_id == User.find_by_name("jace_smith").id) && @title == "Review"
        if @assignment.id < 469
          @next_action = "create"
          render :action => 'custom_response'
        else
          @next_action = "create"
          render :action => 'custom_response_2011'
        end
      else
        # end of special code (except for the end below, to match the if above)
        #**********************
        render :action => 'response'
      end
    end
  end

  def edit
    @header = "Edit"
    @next_action = "update"
    @return = params[:return]
    @response = Response.find(params[:id])
    return if redirect_when_disallowed(@response)

    @map = @response.map
    array_not_empty=0
    @review_scores=Array.new
    @prev=Response.all
    for element in @prev
      if (element.map_id==@map.map_id)
        array_not_empty=1
        @review_scores << element
      end
    end
    if @prev.present?
      @sorted=@review_scores.sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }
      @largest_version_num=@sorted[0]
    end
    @response = Response.where(map_id: @map.map_id, version_num:  @largest_version_num.version_num).first
    @modified_object = @response.response_id
    get_content
    @review_scores = Array.new
    @question_type = Array.new
    @questions.each do |question|
      @review_scores << Score.where(response_id: @response.response_id, question_id:  question.id).first
      @question_type << QuestionType.find_by_question_id(question.id)
    end
    # Check whether this is a custom rubric
    if @map.questionnaire.section.eql? "Custom"
      @next_action = "custom_update"
      render :action => 'custom_response'
    else
      # end of special code (except for the end below, to match the if above)
      #**********************
      render :action => 'response'
    end
    @response.email("update")
  end

  def edit
    @header = "Edit"
    @next_action = "update"
    @return = params[:return]
    @response = Response.find(params[:id])
    return if redirect_when_disallowed(@response)
    @map = @response.map
    @assignment=Assignment.find(@map.reviewed_object_id)
    @questionnaire = @response.questionnaire
    latestResponseVersion()
    if @prev.present?
      #@sorted=@review_scores.sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }
      @sorted=@review_scores.sort
      @largest_version_num=@sorted[0]
    end
    #@response = Response.where(map_id: @map.id, version_num:  @largest_version_num).first
    @response = Response.where(map_id: @map.id).first
    #@modified_object = @response.id
    #get_content()
    #get_scores()
    # Check whether this is a custom rubric
    if @map.questionnaire.section.eql? "Custom"
      render :action => 'custom_response'
    else
      # end of special code (except for the end below, to match the if above)
      render :action => 'response'
    end
  end

  def update ###-### Seems like this method may no longer be used -- not in E806 version of the file
    @response = Response.find(params[:id])
    return if redirect_when_disallowed(@response)
    @myid = @response.response_id
    msg = ""
    begin
      @myid = @response.response_id
      @map = @response.map
      @response.update_attribute('additional_comment', params[:review][:comments])

      @questionnaire = @map.questionnaire
      questions = @questionnaire.questions

      params[:responses].each_pair do |k, v|

        score = Score.where(response_id: @response.id, question_id:  questions[k.to_i].id).first
        unless score
          score = Score.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
        end
        score.update_attribute('score', v[:score])
        score.update_attribute('comments', v[:comment])
      end
    rescue
      msg = "Your response was not saved. Cause:189 #{$!}"
    end

    begin
      ResponseHelper.compare_scores(@response, @questionnaire)
      ScoreCache.update_cache(@response.response_id)

      msg = "Your response was successfully saved."
    rescue
      msg = "An error occurred while saving the response:198 #{$!}"
    end
    redirect_to :controller => 'response', :action => 'saving', :id => @map.map_id, :return => params[:return], :msg => msg, :save_options => params[:save_options]
  end

  def new_feedback
    review = Response.find(params[:id])
    if review
      reviewer = AssignmentParticipant.where(user_id: session[:user].id, parent_id:  review.map.assignment.id).first
      map = FeedbackResponseMap.where(reviewed_object_id: review.id, reviewer_id:  reviewer.id).first
      if map.nil?
        map = FeedbackResponseMap.create(:reviewed_object_id => review.id, :reviewer_id => reviewer.id, :reviewee_id => review.map.reviewer.id)
      end
      redirect_to :action => 'new', :id => map.map_id, :return => "feedback"
    else
      redirect_to :back
    end
  end

  def view
    @response = Response.find(params[:id])
    return if redirect_when_disallowed(@response)
    @map = @response.map
    get_content
    @review_scores = Array.new
    @question_type = Array.new
    @questions.each do |question|
      @review_scores << Score.where(response_id: @map.response_id, question_id:  question.id).first
      @question_type << QuestionType.find_by_question_id(question.id)
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
      @questions.each {
          |question|
        @question_type << QuestionType.find_by_question_id(question.id)
      }
      if !@map.contributor.nil?
        team_member = TeamsUser.find_by_team_id(@map.contributor).user_id
        # Bug: @topic_id is set only in new, not in edit.  So this appears only the 1st time the review is done.-efg
        @topic_id = Participant.where(parent_id: @map.assignment.id, user_id:  team_member).first.topic_id
      end
      if !@topic_id.nil?
        @signedUpTopic = SignUpTopic.find(@topic_id).topic_name
      end
      @next_action = "custom_create"
      render :action => 'custom_response'
    else
      render :action => 'response'
    end
    #end
  end

  def new_feedback
    review = Response.find(params[:id])
    if review
      reviewer = AssignmentParticipant.where(user_id: session[:user].id, parent_id:  review.map.assignment.id).first
      map = FeedbackResponseMap.where(reviewed_object_id: review.id, reviewer_id:  reviewer.id).first
      if map.nil?
        #if no feedback exists by dat user den only create for dat particular response/review
        map = FeedbackResponseMap.create(:reviewed_object_id => review.id, :reviewer_id => reviewer.id, :reviewee_id => review.map.reviewer.id)
      end
      redirect_to :action => 'new', :id => map.id, :return => "feedback"
    else
      redirect_to :back
    end
  end

  def view
    @response = Response.find(params[:id])
    return if redirect_when_disallowed(@response)
    @map = @response.map
    get_content
    get_scores
  end

  def create
    @map = ResponseMap.find(params[:id]) #assignment/review/metareview id is in params id
    @res = 0
    msg = ""
    error_msg = ""
    latestResponseVersion
    @review_scores=Array.new
    @prev=Response.where(map_id: @map.id)
    for element in @prev
      @review_scores << element
    end
    #if previous responses exist increment the version number.
    #if @prev.present?
    #  @sorted=@review_scores.sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }
    #  @largest_version_num=@sorted[0]
    #  @version=@largest_version_num.version_num+1
      #if no previous version is available then initial version number is 1
    #else
    #  @version=1
    #end
    @response = Response.create(:map_id => @map.id, :additional_comment => params[:review][:comments])#,:version_num=>@version)
    #@response = Response.find_by_map_id(@map.id)
    #@response.additional_comment = params[:review][:comments]
    #@response.version_num = @version
    #@response.map = @map
    #if @response.save
      @res = @response.response_id
      @questionnaire = @map.questionnaire
      questions = @questionnaire.questions
      if params[:responses]
        params[:responses].each_pair do |k, v|
          score = Score.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
        end
      end
    #else
    #rescue
    #  flash[:warn] = "Error1: Your response was not saved. Cause:330 #{$!}"
    #end

    ResponseHelper.compare_scores(@response, @questionnaire)
    ScoreCache.update_cache(@res)
    #@map.save
    msg = "Your response was successfully saved."
    @response.email();
    redirect_to :controller => 'response', :action => 'saving', :id => @map.map_id, :return => params[:return], :msg => msg, :error_msg => error_msg, :save_options => params[:save_options]
  end

  def custom_create ###-### Is this used?  It is not present in the master branch.
    @map = ResponseMap.find(params[:id])
    #@map.additional_comment = ""
    @map.save
    @response = Response.create(:map_id => @map.id, :additional_comment => "")
    @res = @response.id
    @questionnaire = @map.questionnaire
    questions = @questionnaire.questions
    for i in 0..questions.size-1
      # Local variable score is unused; can it be removed?
      score = Score.create(:response_id => @response.id, :question_id => questions[i].id, :score => @questionnaire.max_question_score, :comments => params[:custom_response][i.to_s])
    end
    msg = "#{@map.get_title} was successfully saved."

    saving
  end

  def saving
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @map.notification_accepted = false
    @map.save
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
      redirect_to :action => 'redirection', :id => @map.map_id, :return => params[:return], :msg => params[:msg], :error_msg => params[:error_msg]
    end
  end

  def redirection
    flash[:error] = params[:error_msg] unless params[:error_msg] and params[:error_msg].empty?
    flash[:note] = params[:msg] unless params[:msg] and params[:msg].empty?

    @map = Response.find_by_map_id(params[:id])
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
