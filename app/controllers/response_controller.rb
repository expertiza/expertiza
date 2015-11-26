class ResponseController < ApplicationController
  helper :wiki
  helper :submitted_content
  helper :file

  def action_allowed?
    case params[:action]
      when 'edit'  # If response has been submitted, no further editing allowed
        response = Response.find(params[:id])
        if (response.isSubmitted.eql?('Yes'))
           return false
        end
      # Deny access to anyone except reviewer & author's team
      when 'view','edit','delete','update'
        response = Response.find(params[:id])
         if response.map.read_attribute(:type) == 'FeedbackResponseMap' && response.map.assignment.team_assignment?
          team = response.map.reviewer.team
          unless team.has_user session[:user]
            redirect_to '/denied?reason=You are not on the team that wrote this feedback'
          else
            return false
          end
          response.map.read_attribute(:type)
        end
        current_user_id?(response.map.reviewer.user_id)
        else
      current_user
    end
  end

  def scores
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
    #user cannot delete other people's responses. Needs to be authenticated.
    map_id = @response.map.id
    @response.delete
    redirect_to :action => 'redirection', :id => map_id, :return => params[:return], :msg => "The response was deleted."
  end

  #Determining the current phase and check if a review is already existing for this stage.
  #If so, edit that version otherwise create a new version.


  #Prepare the parameters when student clicks "Edit"
  def edit
    @header = "Edit"
    @next_action = "update"
    @return = params[:return]
    @response = Response.find(params[:id])


    @map = @response.map
    @contributor = @map.contributor
    array_not_empty=0
    set_all_responses
    if @prev.present?
      @sorted=@review_scores.sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }
      @largest_version_num=@sorted[0]
    end

    @modified_object = @response.response_id

    # set more handy variables for the view
    set_content

    @review_scores = Array.new

    @questions.each do |question|
      @review_scores << Answer.where(response_id: @response.response_id, question_id:  question.id).first
    end
    render :action => 'response'
  end

  #Update the response and answers when student "edit" existing response
  def update
    return unless action_allowed?

    # the response to be updated
    @response = Response.find(params[:id])

    msg = ""
    begin
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
       questions=sort_questions(@questionnaire.questions)
       create_answers(params,questions)
      questions = @questionnaire.questions.sort { |a,b| a.seq <=> b.seq }

      if !params[:responses].nil? # for some rubrics, there might be no questions but only file submission (Dr. Ayala's rubric)
        params[:responses].each_pair do |k, v|
          score = Answer.where(response_id: @response.id, question_id:  questions[k.to_i].id).first
          unless score
            score = Answer.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :answer => v[:score], :comments => v[:comment])
          end
          score.update_attribute('answer', v[:score])
          score.update_attribute('comments', v[:comment])
        end
      end
      if (params['isSubmit'] && (params['isSubmit'].eql?'Yes'))
        # Update the submission flag.
        @response.update_attribute('isSubmitted','Yes')
      else
        @response.update_attribute('isSubmitted','No')
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

    # set more handy variables for the view
    set_content(true)

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
    @map = @response.map
    set_content

  end

  def create
    @map = ResponseMap.find(params[:id]) #assignment/review/metareview id is in params id

    msg = ""
    error_msg = ""

    set_all_responses

    #to save the response for ReviewResponseMap, a questionnaire_id is wrapped in the params
    if params[:review][:questionnaire_id]
      @questionnaire = Questionnaire.find(params[:review][:questionnaire_id])
      @round = params[:review][:round]
    else
      @round=nil
    end

    @response = Response.create(:map_id => @map.id, :additional_comment => params[:review][:comments],:round => @round)#,:version_num=>@version)
    # create the response
    @response = Response.create(:map_id => @map.id, :additional_comment => params[:review][:comments],:round => @round)#,:version_num=>@version)
    if params[:isSubmit].eql?('Yes')
      isSubmitted = 'Yes'
    else
      isSubmitted = 'No'
    end
    @response = Response.create(:map_id => @map.id, :additional_comment => params[:review][:comments],:round => @round, :isSubmitted => isSubmitted)#,:version_num=>@version)

    #Change the order for displaying questions for editing response views.
    questions=sort_questions(@questionnaire.questions)

    if params[:responses]
       create_answers(params, questions)
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
      redirect_to :controller => 'grades', :action => 'view_my_score', :id => @map.reviewer.id
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
  def set_content(new_response=false)

    # handy reference to response title for view
    @title = @map.get_title

    # handy reference to response assignment for ???
    @assignment = @map.assignment

    # handy reference to the reviewer for ???
    @participant = @map.reviewer

    # handy reference to the contributor (should always be a Team)
    @contributor = @map.contributor

    # set a handy reference to the response questionnaire for the view
    if new_response then set_questionnaire_for_new_response else set_questionnaire end

    # set a handy reference to the dropdown_or_scale property to be used in the view
    set_dropdown_or_scale

    # set a handy reference to the response questionnaire's questions
    # sorted in a special way for the view
    @questions = sort_questions(@questionnaire.questions)

    # set a handy refence to the min/max question  for the view
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score

  end

  def set_questionnaire_for_new_response
    case @map.type
    when "ReviewResponseMap"
      reviewees_topic=SignedUpTeam.topic_id_by_team_id(@contributor.id)
      @current_round = @assignment.get_current_round(reviewees_topic)
      @questionnaire = @map.questionnaire(@current_round)
    when "MetareviewResponseMap"
      @questionnaire = @map.questionnaire
    else
      # This is most likely an error, but I'm keeping it here in case
      # someone was relying on this side effect
      set_questionnaire
    end
  end

  def set_questionnaire
    # if user is not filling a new rubric, the @response object should be available.
    # we can find the questionnaire from the question_id in answers
    answer = @response.scores.first
    @questionnaire =@response.questionnaire_by_answer(answer)
  end

  def set_dropdown_or_scale
    use_dropdown = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: @questionnaire.id).first.dropdown
    use_dropdown == true ? @dropdown_or_scale = 'dropdown' : @dropdown_or_scale = 'scale'
  end

  def sort_questions(questions)
      questions.sort { |a,b| a.seq <=> b.seq }
  end

  def create_answers(params, questions)
     #create score if it is not found. If it is found update it otherwise update it
    params[:responses].each_pair do |k, v|
        score = Answer.where(response_id: @response.id, question_id:  questions[k.to_i].id).first
        unless score
          score = Answer.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :answer => v[:score], :comments => v[:comment])
        end
        score.update_attribute('answer', v[:score])
        score.update_attribute('comments', v[:comment])
      end
  end

  def set_all_responses
    # get all previous versions of responses for the response map.
    # I guess if we're in the middle of creating a new response, this would be
    # all 'previous' responses to this new one (which is not yet saved)?
    @prev=Response.where(map_id: @map.id)
    # not sure what this is about
    @review_scores=@prev.to_a
  end


end
