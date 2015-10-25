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
    @questions.each do |question|
      @review_scores << Answer.where(
          response_id: @response.id,
          question_id:  question.id
        ).first
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
          @review_scores << Answer.where(response_id: @response.response_id, question_id:  question.id).first
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

  #Prepare the parameters when student click "Edit"
  def edit
    @header = "Edit"
    @next_action = "update"
    @return = params[:return]
    @response = Response.find(params[:id])
    return if redirect_when_disallowed(@response)

    @map = @response.map
    @contributor = @map.contributor
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

    @modified_object = @response.response_id

    get_content



    @review_scores = Array.new
    @questions.each do |question|
      @review_scores << Answer.where(response_id: @response.response_id, question_id:  question.id).first
    end
    render :action => 'response'
  end

  #Update the response and answers when student "edit" existing response
  def update
    @response = Response.find(params[:id])
    return if redirect_when_disallowed(@response)
    @myid = @response.response_id
    msg = ""
    begin
      @myid = @response.id
      @map = @response.map
      @response.update_attribute('additional_comment', params[:review][:comments])
      if @map.type=="ReviewResponseMap" && @response.round
        @questionnaire = @map.questionnaire(@response.round)
      elsif @map.type=="ReviewResponseMap"
        @questionnaire = @map.questionnaire(nil)
      else
        @questionnaire = @map.questionnaire
      end
      questions = @questionnaire.questions.sort { |a,b| a.seq <=> b.seq }

      params[:responses].each_pair do |k, v|
        score = Answer.where(response_id: @response.id, question_id:  questions[k.to_i].id).first
        unless score
          score = Answer.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :answer => v[:score], :comments => v[:comment])
        end
        score.update_attribute('answer', v[:score])
        score.update_attribute('comments', v[:comment])
      end
    rescue
      msg = "Your response was not saved. Cause:189 #{$!}"
    end
    redirect_to :controller => 'response', :action => 'saving', :id => @map.map_id, :return => params[:return], :msg => msg, :save_options => params[:save_options]
  end

  def new
    @header = "New"
    @next_action = "create"
    @feedback = params[:feedback]
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @modified_object = @map.id

    get_content(true)
    @stage = @assignment.get_current_stage(SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id))
    render :action => 'response'
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

  #view response
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

    #to save the response for ReviewResponseMap, a questionnaire_id is wrapped in the params
    if params[:review][:questionnaire_id]
      @questionnaire = Questionnaire.find(params[:review][:questionnaire_id])
    end

    #to save the response for ReviewResponseMap, a questionnaire_id is wrapped in the params
    if params[:review][:questionnaire_id]
      @round = params[:review][:round]
    else
      @round=nil
    end

    @response = Response.create(:map_id => @map.id, :additional_comment => params[:review][:comments],:round => @round)#,:version_num=>@version)

    @res = @response.response_id

    #Change the order for displaying questions for editing response views.
    questions = @questionnaire.questions.sort { |a,b| a.seq <=> b.seq }

    if params[:responses]
      params[:responses].each_pair do |k, v|
        Answer.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :answer => v[:score], :comments => v[:comment])
      end
    end

    #@map.save
    msg = "Your response was successfully saved."
    @response.email();
    redirect_to :controller => 'response', :action => 'saving', :id => @map.map_id, :return => params[:return], :msg => msg, :error_msg => error_msg, :save_options => params[:save_options]
  end

  def saving
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @map.save
    redirect_to :action => 'redirection', :id => @map.map_id, :return => params[:return], :msg => params[:msg], :error_msg => params[:error_msg]
  end

  def redirection
    flash[:error] = params[:error_msg] unless params[:error_msg] and params[:error_msg].empty?
    flash[:note] = params[:msg] unless params[:msg] and params[:msg].empty?

    @map = Response.find_by_map_id(params[:id])
    if params[:return] == "feedback"
      redirect_to :controller => 'grades', :action => 'view_my_scores', :id => @map.reviewer.id
    elsif params[:return] == "teammate"
      redirect_to view_student_teams_path student_id: @map.reviewer.id
    elsif params[:return] == "instructor"
      redirect_to :controller => 'grades', :action => 'view', :id => @map.assignment.id
    else
      redirect_to :controller => 'student_review', :action => 'list', :id => @map.reviewer.id

    end
  end

  private
  #new_response if a flag parameter indicating that if user is requesting a new rubric to fill
  #if true: we figure out which questionnaire to use based on current time and records in assignment_questionnaires table
  # e.g. student click "Begin" or "Update" to start filling out a rubric for others' work
  #if false: we figure out which questionnaire to display base on @response object
  # e.g. student click "Edit" or "View"
  def get_content(new_response=false)
    @title = @map.get_title
    @assignment = @map.assignment
    @participant = @map.reviewer
    @contributor = @map.contributor #contributor should always be a Team object

    if @map.type=="ReviewResponseMap" && new_response #determine t
      reviewees_topic=SignedUpTeam.topic_id_by_team_id(@contributor.id)
      @current_round = @assignment.get_current_round(reviewees_topic)
      @questionnaire = @map.questionnaire(@current_round)
    elsif @map.type="MetareviewResponseMap" && new_response
      @questionnaire = @map.questionnaire
    else
      answer = @response.scores.first # if user is not filling a new rubric, the @response object should be available. we can find the questionnaire from the question_id in answers

      @questionnaire =@response.questionnaire_by_answer(answer)
    end

    use_dropdown = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: @questionnaire.id).first.dropdown
    use_dropdown == true ? @dropdown_or_scale = 'dropdown' : @dropdown_or_scale = 'scale'

    @questions = @questionnaire.questions.sort { |a,b| a.seq <=> b.seq }
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
