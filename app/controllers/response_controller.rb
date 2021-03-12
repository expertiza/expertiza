class ResponseController < ApplicationController
  include AuthorizationHelper

  helper :submitted_content
  helper :file

  def action_allowed?
    response = user_id = nil
    action = params[:action]
    if %w[edit delete update view].include?(action)
      response = Response.find(params[:id])
      user_id = response.map.reviewer.user_id if response.map.reviewer
    end
    case action
    when 'edit' # If response has been submitted, no further editing allowed
      return false if response.is_submitted
      return current_user_is_reviewer?(response.map, user_id)
      # Deny access to anyone except reviewer & author's team
    when 'delete', 'update'
      return current_user_is_reviewer?(response.map, user_id)
    when 'view'
      return response_edit_allowed?(response.map, user_id)
    else
      user_logged_in?
    end
  end

  # E-1973 - helper method to check if the current user is the reviewer
  # if the reviewer is an assignment team, we have to check if the current user is on the team
  def current_user_is_reviewer?(map, reviewer_id)
    map.get_reviewer.current_user_is_reviewer? current_user.try(:id)
  end

  # GET /response/json?response_id=xx
  def json
    response_id = params[:response_id] if params.key?(:response_id)
    response = Response.find(response_id)
    render json: response
  end

  def delete
    #The locking was added for E1973, team-based reviewing. See lock.rb for details
    @response = Response.find(params[:id])
    @map = @response.map
    if @map.reviewer_is_team
      @response = Lock.get_lock(@response, current_user, Lock::DEFAULT_TIMEOUT)
      if @response.nil?
        response_lock_action
        return
      end
    end
    
    # user cannot delete other people's responses. Needs to be authenticated.
    map_id = @response.map.id
    # The lock will be automatically destroyed when the response is destroyed
    @response.delete
    redirect_to action: 'redirect', id: map_id, return: params[:return], msg: "The response was deleted."
  end

  # Determining the current phase and check if a review is already existing for this stage.
  # If so, edit that version otherwise create a new version.

  # Prepare the parameters when student clicks "Edit"
  def edit
    assign_instance_vars
    @prev = Response.where(map_id: @map.id)
    @review_scores = @prev.to_a
    if @prev.present?
      @sorted = @review_scores.sort {|m1, m2| m1.version_num.to_i && m2.version_num.to_i ? m2.version_num.to_i <=> m1.version_num.to_i : (m1.version_num ? -1 : 1) }
      @largest_version_num = @sorted[0]
    end
    #Added for E1973, team-based reviewing
    @map = @response.map
    if @map.reviewer_is_team
      @response = Lock.get_lock(@response, current_user, Lock::DEFAULT_TIMEOUT)
      if @response.nil?
        response_lock_action
        return
      end
    end
    
    @modified_object = @response.response_id
    # set more handy variables for the view
    set_content
    @review_scores = []
    @questions.each do |question|
      @review_scores << Answer.where(response_id: @response.response_id, question_id: question.id).first
    end
    @questionnaire = set_questionnaire
    store_total_cake_score
    render action: 'response'
  end



  # Update the response and answers when student "edit" existing response
  def update
    render nothing: true unless action_allowed?
    
    msg = ""
    begin
      # the response to be updated
      # Locking functionality added for E1973, team-based reviewing
      @response = Response.find(params[:id])
      @current_round = @response.round
      @map = @response.map
      if @map.reviewer_is_team && !Lock.lock_between?(@response, current_user)
        response_lock_action
        return
      end
      @response.update_attribute('additional_comment', params[:review][:comments])
      @questionnaire = set_questionnaire
      questions = sort_questions(@questionnaire.questions)
      create_answers(params, questions) unless params[:responses].nil? # for some rubrics, there might be no questions but only file submission (Dr. Ayala's rubric)
      @response.update_attribute('is_submitted', true) if params['isSubmit'] && params['isSubmit'] == 'Yes'
      @response.notify_instructor_on_difference if (@map.is_a? ReviewResponseMap) && @response.is_submitted && @response.significant_difference?
    rescue StandardError
      msg = "Your response was not saved. Cause:189 #{$ERROR_INFO}"
    end
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "Your response was submitted: #{@response.is_submitted}", request)
    redirect_to controller: 'response', action: 'save', id: @map.map_id,
                return: params[:return], msg: msg, review: params[:review], save_options: params[:save_options]
  end

  def new
    assign_instance_vars
    set_content(true)
    @stage = @assignment.get_current_stage(SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)) if @assignment
    # Because of the autosave feature and the javascript that sync if two reviewing windows are opened
    # The response must be created when the review begin.
    # So do the answers, otherwise the response object can't find the questionnaire when the user hasn't saved his new review and closed the window.
    # A new response has to be created when there hasn't been any reviews done for the current round,
    # or when there has been a submission after the most recent review in this round.
    @response = Response.where(map_id: @map.id, round: @current_round.to_i).order(updated_at: :desc).first
    teams_most_recent_submission = AssignmentTeam.find(@map.reviewee_id).most_recent_submission
    if @response.nil? || (!teams_most_recent_submission.nil? && teams_most_recent_submission.updated_at > @response.updated_at)
      @response = Response.create(map_id: @map.id, additional_comment: '', round: @current_round, is_submitted: 0)
    end
    questions = sort_questions(@questionnaire.questions)
    store_total_cake_score
    init_answers(questions)
    render action: 'response'
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
      redirect_to action: 'new', id: map.id, return: "feedback"
    else
      redirect_to :back
    end
  end

  # view response
  def view
    @response = Response.find(params[:id])
    @map = @response.map
    set_content
  end

  def create
    map_id = params[:id]
    map_id = params[:map_id] unless params[:map_id].nil? # pass map_id as a hidden field in the review form
    @map = ResponseMap.find(map_id)
    if params[:review][:questionnaire_id]
      @questionnaire = Questionnaire.find(params[:review][:questionnaire_id])
      @round = params[:review][:round]
    else
      @round = nil
    end
    is_submitted = (params[:isSubmit] == 'Yes')
    was_submitted = false
    # There could be multiple responses per round, when re-submission is enabled for that round.
    # Hence we need to pick the latest response.
    @response = Response.where(map_id: @map.id, round: @round.to_i).order(created_at: :desc).first
    if @response.nil?
      @response = Response.create(
        map_id: @map.id,
        additional_comment: params[:review][:comments],
        round: @round.to_i,
        is_submitted: is_submitted
      )
    end
    was_submitted = @response.is_submitted
    @response.update(additional_comment: params[:review][:comments], is_submitted: is_submitted) # ignore if autoupdate try to save when the response object is not yet created.

    # :version_num=>@version)
    # Change the order for displaying questions for editing response views.
    questions = sort_questions(@questionnaire.questions)
    create_answers(params, questions) if params[:responses]
    msg = "Your response was successfully saved."
    error_msg = ""
    # only notify if is_submitted changes from false to true
    if (@map.is_a? ReviewResponseMap) && (was_submitted == false && @response.is_submitted) && @response.significant_difference?
      @response.notify_instructor_on_difference
      @response.email
    end
    redirect_to controller: 'response', action: 'save', id: @map.map_id,
                return: params[:return], msg: msg, error_msg: error_msg, review: params[:review], save_options: params[:save_options]
  end

  def save
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @map.save
    participant = Participant.find_by(id: @map.reviewee_id)
    # E1822: Added logic to insert a student suggested 'Good Teammate' or 'Good Reviewer' badge in the awarded_badges table.
    if @map.assignment.badge?
      if @map.is_a? TeammateReviewResponseMap and params[:review][:good_teammate_checkbox] == 'on'
        badge_id = Badge.get_id_from_name('Good Teammate')
        AwardedBadge.where(participant_id: participant.id, badge_id: badge_id, approval_status: 0).first_or_create
      end
      if @map.is_a? FeedbackResponseMap and params[:review][:good_reviewer_checkbox] == 'on'
        badge_id = Badge.get_id_from_name('Good Reviewer')
        AwardedBadge.where(participant_id: participant.id, badge_id: badge_id, approval_status: 0).first_or_create
      end
    end
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "Response was successfully saved")
    redirect_to action: 'redirect', id: @map.map_id, return: params[:return], msg: params[:msg], error_msg: params[:error_msg]
  end

  def pending_surveys
    redirect_to controller: 'survey_deployment', action: 'pending_surveys'
  end

  def redirect
    error_id = params[:error_msg]
    message_id = params[:msg]
    flash[:error] = error_id unless error_id and error_id.empty?
    flash[:note] = message_id unless message_id and message_id.empty?
    @map = Response.find_by(map_id: params[:id])
    case params[:return]
    when "feedback"
      redirect_to controller: 'grades', action: 'view_my_scores', id: @map.reviewer.id
    when "teammate"
      redirect_to view_student_teams_path student_id: @map.reviewer.id
    when "instructor"
      redirect_to controller: 'grades', action: 'view', id: @map.response_map.assignment.id
    when "assignment_edit"
      redirect_to controller: 'assignments', action: 'edit', id: @map.response_map.assignment.id
    when "selfreview"
      redirect_to controller: 'submitted_content', action: 'edit', id: @map.response_map.reviewer_id
    when "survey"
      redirect_to controller: 'survey_deployment', action: 'pending_surveys'
    when "bookmark"
      bookmark = Bookmark.find(@map.response_map.reviewee_id)
      redirect_to controller: 'bookmarks', action: 'list', id: bookmark.topic_id
    when "ta_review"      # Page should be directed to list_submissions if TA/instructor performs the review
      redirect_to controller: 'assignments', action: 'list_submissions', id: @map.response_map.assignment.id
    else
      # if reviewer is team, then we have to get the id of the participant from the team
      # the id in reviewer_id is of an AssignmentTeam
      reviewer_id = @map.response_map.get_reviewer.get_logged_in_reviewer_id(current_user.try(:id))
      redirect_to controller: 'student_review', action: 'list', id: reviewer_id
    end
  end

  # assigning variables for the expert reviews
  def show_calibration_results_for_student
    calibration_response_map = ReviewResponseMap.find(params[:calibration_response_map_id])
    review_response_map = ReviewResponseMap.find(params[:review_response_map_id])
    @calibration_response = calibration_response_map.response[0]
    @review_response = review_response_map.response[0]
    @assignment = Assignment.find(calibration_response_map.reviewed_object_id)
    @review_questionnaire_ids = ReviewQuestionnaire.select("id")
    @assignment_questionnaire = AssignmentQuestionnaire.where(["assignment_id = ? and questionnaire_id IN (?)", @assignment.id, @review_questionnaire_ids]).first
    @questions = @assignment_questionnaire.questionnaire.questions.reject {|q| q.is_a?(QuestionnaireHeader) }
  end

  def toggle_permission
    render nothing: true unless action_allowed?

    # the response to be updated
    @response = Response.find(params[:id])

    # Error message placehoder
    msg = ""

    begin
      @map = @response.map

      # Updating visibility for the response object, by E2022 @SujalAhrodia -->
      visibility = params[:visibility]
      if (!visibility.nil?)
        @response.update_attribute("visibility",visibility)
      end

    rescue StandardError
      msg = "Your response was not saved. Cause:189 #{$ERROR_INFO}"
    end
    redirect_to action: 'redirect', id: @map.map_id, return: params[:return], msg: params[:msg], error_msg: params[:error_msg]
  end

  private
  
  # Added for E1973, team-based reviewing:
  # http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2019_-_Project_E1973._Team_Based_Reviewing
  # This action gets taken if the response is locked and cannot be edit right now
  def response_lock_action
    redirect_to action: 'redirect', id: @map.map_id, return: 'locked', error_msg: 'Another user is modifying this response or has modified this response. Try again later.'
  end

  # new_response if a flag parameter indicating that if user is requesting a new rubric to fill
  # if true: we figure out which questionnaire to use based on current time and records in assignment_questionnaires table
  # e.g. student click "Begin" or "Update" to start filling out a rubric for others' work
  # if false: we figure out which questionnaire to display base on @response object
  # e.g. student click "Edit" or "View"
  def set_content(new_response = false)
    @title = @map.get_title
    if @map.survey?
      @survey_parent = @map.survey_parent
    else
      @assignment = @map.assignment
    end
    @participant = @map.reviewer
    @contributor = @map.contributor
    new_response ? set_questionnaire_for_new_response : set_questionnaire
    set_dropdown_or_scale
    @questions = sort_questions(@questionnaire.questions)
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score
  end
  # assigning the instance variables for Edit and New actions
  def assign_instance_vars
    case params[:action]
    when 'edit'
      @header = 'Edit'
      @next_action = 'update'
      @response = Response.find(params[:id])
      @current_round = @response.round
      @map = @response.map
      @contributor = @map.contributor
    when 'new'
      @header = 'New'
      @next_action = 'create'
      @feedback = params[:feedback]
      @map = ResponseMap.find(params[:id])
      @modified_object = @map.id
    end
    @return = params[:return]
  end
  # identifying the questionnaire type
  # updating the current round for the reviewer's responses
  def set_questionnaire_for_new_response
    case @map.type
    when "ReviewResponseMap", "SelfReviewResponseMap"
      reviewees_topic = SignedUpTeam.topic_id_by_team_id(@contributor.id)
      @current_round = @assignment.number_of_current_round(reviewees_topic)
      @questionnaire = @map.questionnaire(@current_round, reviewees_topic)
    when
      "MetareviewResponseMap",
      "TeammateReviewResponseMap",
      "FeedbackResponseMap",
      "CourseSurveyResponseMap",
      "AssignmentSurveyResponseMap",
      "GlobalSurveyResponseMap",
      "BookmarkRatingResponseMap"
      @questionnaire = @map.questionnaire
    end
  end
  # stores the first instance of the score for each question
  def scores
    @review_scores = []
    @questions.each do |question|
      @review_scores << Answer.where(
        response_id: @response.id,
        question_id:  question.id
      ).first
    end
  end

  def set_questionnaire
    # if user is not filling a new rubric, the @response object should be available.
    # we can find the questionnaire from the question_id in answers
    answer = @response.scores.first
    @questionnaire = @response.questionnaire_by_answer(answer)
  end

  # checks if the questionnaire is nil and opens drop down or rating accordingly
  def set_dropdown_or_scale
    use_dropdown = AssignmentQuestionnaire.where(assignment_id: @assignment.try(:id),
                                                 questionnaire_id: @questionnaire.try(:id))
                                          .first.try(:dropdown)
    @dropdown_or_scale = (use_dropdown ? 'dropdown' : 'scale')
  end

  # sorts by sequence number
  def sort_questions(questions)
    questions.sort_by(&:seq)
  end
  # For each question in the list, starting with the first one, you update the comment and score
  def create_answers(params, questions)
    params[:responses].each_pair do |k, v|
      score = Answer.where(response_id: @response.id, question_id: questions[k.to_i].id).first
      score ||= Answer.create(response_id: @response.id, question_id: questions[k.to_i].id, answer: v[:score], comments: v[:comment])
      score.update_attribute('answer', v[:score])
      score.update_attribute('comments', v[:comment])
    end
  end

  def init_answers(questions)
    questions.each do |q|
      # it's unlikely that these answers exist, but in case the user refresh the browser some might have been inserted.
      a = Answer.where(response_id: @response.id, question_id: q.id).first
      Answer.create(response_id: @response.id, question_id: q.id, answer: nil, comments: '') if a.nil?
    end
  end

  # Creates a table to store total contribution for Cake question across all reviewers
  def store_total_cake_score
    @total_score = Hash.new
    @questions.each do |question|
      if question.instance_of? Cake
        reviewee_id = ResponseMap.select(:reviewee_id, :type).where(id: @response.map_id.to_s).first
        total_score = question.get_total_score_for_question(reviewee_id.type, question.id, @participant.id, @assignment.id, reviewee_id.reviewee_id).to_s
        if total_score.nil?
          total_score = 0
        end
        @total_score[question.id] = total_score
      end
    end
  end
end

