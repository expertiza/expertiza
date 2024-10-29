class ResponsesController < ApplicationController
  include AuthorizationHelper
  include ResponseHelper

  helper :submitted_content
  helper :file

  before_action :authorize_show_calibration_results, only: %i[show_calibration_results_for_student]
  before_action :set_response, only: %i[update delete view]

  # E2218: Method to delete a response.
  def delete
    # The locking was added for E1973, team-based reviewing. See lock.rb for details
    # user cannot delete other people's responses. Needs to be authenticated.
    @response = lock_response(@map, @response)
    if @response.nil?
      return
    end

    # The lock will be automatically destroyed when the response is destroyed
    @response.delete
    redirect_to action: 'redirect', id: @response.map.id, return: params[:return], msg: 'The response was deleted.'
  end

  # Determining the current phase and check if a review is already existing for this stage.
  # If so, edit that version otherwise create a new version.

  # Prepare the parameters when student clicks "Edit"
  # response questions with answers and scores are rendered in the edit page based on the version number
  def edit
    #Added for E1973, team-based reviewing
    #Lock a response if the user is authorized to edit the current response
    current_response = Response.find(params[:id])
    current_map = current_response.map
    current_response = lock_response(current_map, current_response)
    if current_response.nil?
      return
    end
 
    #setting variables for rendering view
    @header = 'Edit'
    @next_action = 'update'
    @return = params[:return]
    @map = current_response.map
    @modified_object = current_response.response_id
    @title = current_map.get_title
    if current_map.survey?
      @survey_parent = current_map.survey_parent
    else
      @assignment = current_map.assignment
    end
    @participant = current_map.reviewer
    @contributor = current_map.contributor
    
    # if user is not filling a new rubric, the @response object should be available.
    # we can find the questionnaire from the question_id in answers
    current_questionnaire = questionnaire_from_response(current_response)
    @dropdown_or_scale = get_dropdown_or_scale(@assignment,current_questionnaire)
    @min = current_questionnaire.min_question_score
    @max = current_questionnaire.max_question_score
    
    # The new response is created here so that the controller has access to it in the new method
    # This response object is populated later in the new method 
    if current_questionnaire
      #Sometimes the response is already created and the new controller is called again (page refresh)
      @response = Response.where(map_id: current_map.id, round: @current_round.to_i).order(updated_at: :desc).first
      if @response.nil?
        @response = Response.create(map_id: current_map.id, additional_comment: '', round: @current_round.to_i, is_submitted: 0)
      end
    end
    
    questions = current_questionnaire.questions
    @review_scores = []
    questions.each do |question|
      @review_scores << Answer.where(response_id: @response.response_id, question_id: question.id).first
    end
    
    @questionnaire = questionnaire_from_response(@response)
    
    render action: 'response'
  end

  # Update the response and answers when student "edit" existing response
  def update
    render nothing: true unless action_allowed?
    msg = ''
    begin
      # the response to be updated
      # Locking functionality added for E1973, team-based reviewing
      if map_team_reviewing_enabled?(@map.team_reviewing_enabled) && !Lock.lock_between?(@response, current_user)
        response_lock_action
        return
      end

      @response.update_attribute('additional_comment', params[:review][:comments])
      @questionnaire = questionnaire_from_response(@response)
      questions = sort_questions(@questionnaire.questions)

      # for some rubrics, there might be no questions but only file submission (Dr. Ayala's rubric)
      create_answers(params, questions) unless params[:responses].nil?
      if params['isSubmit'] && params['isSubmit'] == 'Yes'
        @response.update_attribute('is_submitted', true)
      end

      if (@map.is_a? ReviewResponseMap) && @response.is_submitted && @response.significant_difference?
        @response.notify_instructor_on_difference
      end
    rescue StandardError
      msg = "Your response was not saved. Cause:189 #{$ERROR_INFO}"
    end
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "Your response was submitted: #{@response.is_submitted}", request)
    redirect_to controller: 'response', action: 'save', id: @map.map_id,
                return: params.permit(:return)[:return], msg: msg, review: params.permit(:review)[:review],
                save_options: params.permit(:save_options)[:save_options]
  end

  def new
    @header = 'New'
    @next_action = 'create'
    @return = params[:return]
    @map = ResponseMap.find(params[:id])
    @modified_object = @map.id
    @title = @map.get_title
    if @map.survey?
      @survey_parent = @map.survey_parent
    else
      @assignment = @map.assignment
    end
    @participant = @map.reviewer
    @contributor = @map.contributor
    
    #get the questionnaire from the response map -> new_response=questionnaire_from_response_map
    current_questionnaire=questionnaire_from_response_map(@map,@contributor,@assignment)
    @dropdown_or_scale = get_dropdown_or_scale(@assignment,current_questionnaire)
    @min = current_questionnaire.min_question_score
    @max = current_questionnaire.max_question_score
    
    # The new response is created here so that the controller has access to it in the new method
    # This response object is populated later in the new method
    if current_questionnaire
      #Sometimes the response is already created and the new controller is called again (page refresh)
      @response = Response.where(map_id: @map.id, round: @current_round.to_i).order(updated_at: :desc).first
      if @response.nil?
        @response = Response.create(map_id: @map.id, additional_comment: '', round: @current_round.to_i, is_submitted: 0)
      end
    end
    
    @feedback = params[:feedback]
    if @assignment
      @stage = @assignment.current_stage(SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id))
    end
    
    # Because of the autosave feature and the javascript that sync if two reviewing windows are opened
    # The response must be created when the review begin.
    # So do the answers, otherwise the response object can't find the questionnaire when the user hasn't saved his new review and closed the window.
    # A new response has to be created when there hasn't been any reviews done for the current round,
    # or when there has been a submission after the most recent review in this round.
    @current_round=get_current_round(@assignment)
    @response = @response.create_or_get_response(@map, @current_round.to_i)
    @review_questions = @questionnaire.questions
    @total_score=get_total_cake_score(@response,@participant,@assignment)
    init_answers(@review_questions)
    
    render action: 'response'
  end

  def create
    map_id = params[:id]
    unless params[:map_id].nil?
      map_id = params[:map_id]
    end # pass map_id as a hidden field in the review form
    @map = ResponseMap.find(map_id)
    if params[:review][:questionnaire_id]
      @questionnaire = Questionnaire.find(params[:review][:questionnaire_id])
      @round = params[:review][:round]
    else
      @round = nil
    end
    is_submitted = (params[:isSubmit] == 'Yes')
    # There could be multiple responses per round, when re-submission is enabled for that round.
    # Hence we need to pick the latest response.
    @response = Response.where(map_id: @map.id, round: @round.to_i).order(created_at: :desc).first
    if @response.nil?
      @response = Response.create(map_id: @map.id, additional_comment: params[:review][:comments],
                                  round: @round.to_i, is_submitted: is_submitted)
    end
    was_submitted = @response.is_submitted

    # ignore if autoupdate try to save when the response object is not yet created.s
    @response.update(additional_comment: params[:review][:comments], is_submitted: is_submitted)

    # :version_num=>@version)
    # Change the order for displaying questions for editing response views.
    questions = sort_questions(@questionnaire.questions)
    create_answers(params, questions) if params[:responses]
    msg = 'Your response was successfully saved.'
    error_msg = ''

    # only notify if is_submitted changes from false to true
    if (@map.is_a? ReviewResponseMap) && (!was_submitted && @response.is_submitted) && @response.significant_difference?
      @response.notify_instructor_on_difference
      @response.email
    end
    redirect_to controller: 'response', action: 'save', id: @map.map_id,
                return: params.permit(:return)[:return], msg: msg, error_msg: error_msg, review: params.permit(:review)[:review], save_options: params.permit(:save_options)[:save_options]
  end

  def save
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @map.save
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, 'Response was successfully saved')
    redirect_to action: 'redirect', id: @map.map_id, return: params.permit(:return)[:return], msg: params.permit(:msg)[:msg], error_msg: params.permit(:error_msg)[:error_msg]
  end

  def author; end

  # view response
  def view
    @title = @map.get_title
    if @map.survey?
      @survey_parent = @map.survey_parent
    else
      @assignment = @map.assignment
    end
    @participant = @map.reviewer
    @contributor = @map.contributor
    current_questionnaire = questionnaire_from_response(current_response)
    @dropdown_or_scale = get_dropdown_or_scale(@assignment,current_questionnaire)
    @min = current_questionnaire.min_question_score
    @max = current_questionnaire.max_question_score
    # The new response is created here so that the controller has access to it in the new method
    # This response object is populated later in the new method
    if current_questionnaire
      #Sometimes the response is already created and the new controller is called again (page refresh)
      @response = Response.where(map_id: @map.id, round: @current_round.to_i).order(updated_at: :desc).first
      if @response.nil?
        @response = Response.create(map_id: @map.id, additional_comment: '', round: @current_round.to_i, is_submitted: 0)
      end
    end
  end

  # E2218: Method to check if that action is allowed for the user.
  def action_allowed?
    response = user_id = nil
    action = params[:action]
    # Initialize response and user id if action is edit or delete or update or view.
    if %w[edit delete update view].include?(action)
      response = Response.find(params[:id])
      user_id = response.map.reviewer.user_id if response.map.reviewer
    end
    case action
    when 'edit'
      # If response has been submitted, no further editing allowed.
      return false if response.is_submitted

      # Else, return true if the user is a reviewer for that response.
      current_user_is_reviewer?(response.map, user_id)

    # Deny access to anyone except reviewer & author's team
    when 'delete', 'update'
      current_user_is_reviewer?(response.map, user_id)
    when 'view'
      response_edit_allowed?(response.map, user_id)
    else
      user_logged_in?
    end
  end

  # E2218: Method to authorize if the reviewer can view the calibration results
  # When user manipulates the URL, the user should be authorized
  def authorize_show_calibration_results
    response_map = ResponseMap.find(params[:review_response_map_id])
    user_id = response_map.reviewer.user_id if response_map.reviewer
    # Deny access to the calibration result page if the current user is not a reviewer.
    unless current_user_is_reviewer?(response_map, user_id)
      flash[:error] = 'You are not allowed to view this calibration result'
      redirect_to controller: 'student_review', action: 'list', id: user_id
    end
  end

  # GET /response/json?response_id=xx
  def json
    response_id = params[:response_id] if params.key?(:response_id)
    response = Response.find(response_id)
    render json: response
  end

  # This method is used to send email from a Reviewer to an Author.
  # Email body and subject are inputted from Reviewer and passed to send_mail_to_author_reviewers method in MailerHelper.
  def send_email
    subject = params['send_email']['subject']
    body = params['send_email']['email_body']
    response = params['response']
    email = params['email']

    respond_to do |format|
      if subject.blank? || body.blank?
        flash[:error] = 'Please fill in the subject and the email content.'
        format.html { redirect_to controller: 'response', action: 'author', response: response, email: email }
        format.json { head :no_content }
      else
        # make a call to method invoking the email process
        MailerHelper.send_mail_to_author_reviewers(subject, body, email)
        flash[:success] = 'Email sent to the author.'
        format.html { redirect_to controller: 'student_task', action: 'list' }
        format.json { head :no_content }
      end
    end
  end

  def new_feedback
    review = Response.find(params[:id]) unless params[:id].nil?
    if review
      reviewer = AssignmentParticipant.where(user_id: session[:user].id, parent_id: review.map.assignment.id).first
      map = FeedbackResponseMap.where(reviewed_object_id: review.id, reviewer_id: reviewer.id).first
      if map.nil?
        # if no feedback exists by dat user den only create for dat particular response/review
        map = FeedbackResponseMap.create(reviewed_object_id: review.id, reviewer_id: reviewer.id, reviewee_id: review.map.reviewer.id)
      end
      redirect_to action: 'new', id: map.id, return: 'feedback'
    else
      redirect_back fallback_location: root_path
    end
  end

  def redirect
    error_id = params[:error_msg]
    message_id = params[:msg]
    flash[:error] = error_id unless error_id&.empty?
    flash[:note] = message_id unless message_id&.empty?
    @map = Response.find_by(map_id: params[:id])
    case params[:return]
    when 'feedback'
      redirect_to controller: 'grades', action: 'view_my_scores', id: @map.reviewer.id
    when 'teammate'
      redirect_to view_student_teams_path student_id: @map.reviewer.id
    when 'instructor'
      redirect_to controller: 'grades', action: 'view', id: @map.response_map.assignment.id
    when 'assignment_edit'
      redirect_to controller: 'assignments', action: 'edit', id: @map.response_map.assignment.id
    when 'selfreview'
      redirect_to controller: 'submitted_content', action: 'edit', id: @map.response_map.reviewer_id
    when 'survey'
      redirect_to controller: 'survey_deployment', action: 'pending_surveys'
    when 'bookmark'
      bookmark = Bookmark.find(@map.response_map.reviewee_id)
      redirect_to controller: 'bookmarks', action: 'list', id: bookmark.topic_id
    when 'ta_review' # Page should be directed to list_submissions if TA/instructor performs the review
      redirect_to controller: 'assignments', action: 'list_submissions', id: @map.response_map.assignment.id
    else
      # if reviewer is team, then we have to get the id of the participant from the team
      # the id in reviewer_id is of an AssignmentTeam
      reviewer_id = @map.response_map.reviewer.get_logged_in_reviewer_id(current_user.try(:id))
      redirect_to controller: 'student_review', action: 'list', id: reviewer_id
    end
  end

  # This method set the appropriate values to the instance variables used in the 'show_calibration_results_for_student' page
  # Responses are fetched using calibration_response_map_id and review_response_map_id params passed in the URL
  # Questions are fetched by querying AssignmentQuestionnaire table to get the valid questions
  def show_calibration_results_for_student
    @assignment = Assignment.find(params[:assignment_id])
    @calibration_response = ReviewResponseMap.find(params[:calibration_response_map_id]).response[0]
    @review_response = ReviewResponseMap.find(params[:review_response_map_id]).response[0]
    @review_questions = AssignmentQuestionnaire.get_questions_by_assignment_id(params[:assignment_id])
  end

  def toggle_permission
    render nothing: true unless action_allowed?

    # the response to be updated
    @response = Response.find(params[:id])

    # Error message placeholder
    error_msg = ''

    begin
      @map = @response.map

      # Updating visibility for the response object, by E2022 @SujalAhrodia -->
      visibility = params[:visibility]
      unless visibility.nil?
        @response.update_attribute('visibility', visibility)
      end
    rescue StandardError
      error_msg = "Your response was not saved. Cause:189 #{$ERROR_INFO}"
    end
    redirect_to action: 'redirect', id: @map.map_id, return: params[:return], msg: params[:msg], error_msg: error_msg
  end

  private

  # E2218: Method to initialize response and response map for update, delete and view methods
  def set_response
    @response = Response.find(params[:id])
    @map = @response.map
  end

  # Added for E1973, team-based reviewing:
  # http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2019_-_Project_E1973._Team_Based_Reviewing
  # Taken if the response is locked and cannot be edited right now
  def response_lock_action
    redirect_to action: 'redirect', id: @map.map_id, return: 'locked', error_msg: 'Another user is modifying this response or has modified this response. Try again later.'
  end

  # This method initialize answers for the questions in the response
  # Iterates over each questions and create corresponding answer for that
  def init_answers(questions)
    questions.each do |q|
      # it's unlikely that these answers exist, but in case the user refresh the browser some might have been inserted.
      answer = Answer.where(response_id: @response.id, question_id: q.id).first
      if answer.nil?
        Answer.create(response_id: @response.id, question_id: q.id, answer: nil, comments: '')
      end
    end
  end

  #this method is called within the view,new,edit actions to set vaariables for the view
  def set_action_parameters(header,next_action,params_return,current_response,current_map,modified_object)
    #setting variables for the view
    @header = header
    @next_action = next_action
    @return = params_return
    @map = current_map
    @modified_object = modified_object
    @title = current_map.get_title
    if current_map.survey?
      @survey_parent = current_map.survey_parent
    else
      @assignment = current_map.assignment
    end
    @participant = current_map.reviewer
    @contributor = current_map.contributor
    
    # if user is not filling a new rubric, the @response object should be available.
    # we can find the questionnaire from the question_id in answers
    current_questionnaire = questionnaire_from_response(current_response)
    @dropdown_or_scale = get_dropdown_or_scale(@assignment,current_questionnaire)
    @min = current_questionnaire.min_question_score
    @max = current_questionnaire.max_question_score
    
    # The new response is created here so that the controller has access to it in the new method
    # This response object is populated later in the new method 
    if current_questionnaire
      #Sometimes the response is already created and the new controller is called again (page refresh)
      @response = Response.where(map_id: current_map.id, round: @current_round.to_i).order(updated_at: :desc).first
      if @response.nil?
        @response = Response.create(map_id: current_map.id, additional_comment: '', round: @current_round.to_i, is_submitted: 0)
      end
    end
    
    @review_questions = sort_questions(current_questionnaire.questions)
end
end
