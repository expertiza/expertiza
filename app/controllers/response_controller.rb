class ResponseController < ApplicationController
  helper :submitted_content
  helper :file

  require 'net/http'

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
      return current_user_id?(user_id)
      # Deny access to anyone except reviewer & author's team
    when 'delete', 'update'
      return current_user_id?(user_id)
    when 'view'
      return edit_allowed?(response.map, user_id)
    else
      current_user
    end
  end

  def edit_allowed?(map, user_id)
    assignment = map.reviewer.assignment
    # if it is a review response map, all the members of reviewee team should be able to view the reponse (can be done from heat map)
    if map.is_a? ReviewResponseMap
      reviewee_team = AssignmentTeam.find(map.reviewee_id)
      return current_user_id?(user_id) || reviewee_team.user?(current_user) || current_user.role.name == 'Administrator' ||
        (current_user.role.name == 'Instructor' and assignment.instructor_id == current_user.id) ||
        (current_user.role.name == 'Teaching Assistant' and TaMapping.exists?(ta_id: current_user.id, course_id: assignment.course.id))
    else
      current_user_id?(user_id)
    end
  end

  # GET /response/json?response_id=xx
  def json
    response_id = params[:response_id] if params.key?(:response_id)
    response = Response.find(response_id)
    render json: response
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
    team = AssignmentTeam.find(@map.reviewee_id)
    @response = Response.where(map_id: @map.id, round: @current_round.to_i).order(updated_at: :desc).first
    if @response.nil? || team.most_recent_submission.updated_at > @response.updated_at
      @response = Response.create(map_id: @map.id, additional_comment: '', round: @current_round, is_submitted: 0)
    end
    questions = sort_questions(@questionnaire.questions)
    init_answers(questions)
    render action: 'response'
  end

  def create
    is_submitted = params[:isSubmit].present?
    was_submitted = false

    print("\r\nIsSubmit #{is_submitted}\r\n")
    
    # New change: When Submit is clicked, instead of immediately redirecting...confirm review first
    print("\r\nThe params in the create method are: \r\n")
    print(params)
    print("\r\n")
    
    save_response('create')
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
    @modified_object = @response.response_id
    # set more handy variables for the view
    set_content
    @review_scores = []
    @questions.each do |question|
      @review_scores << Answer.where(response_id: @response.response_id, question_id: question.id).first
    end
    @questionnaire = set_questionnaire
    render action: 'response'
  end

  # Update the response and answers when student "edit" existing response
  def update
    render nothing: true unless action_allowed?
    is_submitted = params[:isSubmit].present?

    print("\r\nIsSubmit #{is_submitted}\r\n")
    # New change: When Submit is clicked, instead of immediately redirecting...confirm review first
    print("\r\nThe params in the update are: \r\n")
    print(params)
    print("\r\n")

    save_response("update")

    if !is_submitted
       redirect_to controller: 'submitted_content', action: 'edit', id: @map.reviewer.id
    end

  end

  def delete
    @response = Response.find(params[:id])
    # user cannot delete other people's responses. Needs to be authenticated.
    map_id = @response.map.id
    @response.delete
    redirect_to action: 'redirect', id: map_id, return: params[:return], msg: "The response was deleted."
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

  # Adding a function to integrate suggestion detection algorithm (SDA)
  def get_review_response_metrics
    uri = URI.parse('https://peer-review-metrics-nlp.herokuapp.com/metrics/all')
    http = Net::HTTP.new(uri.hostname, uri.port)
    req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' =>'application/json'})
    req.body = {"reviews"=>@all_comments,
                      "metrics"=>["suggestion", "sentiment"]}.to_json
    http.use_ssl = true
    res = http.request(req)

    return JSON.parse(res.body)
  end

  def show_confirmation_page
    print("\r\nInside show_confirmation_page\r\n")

    @response = Response.find(params[:id])

    # a response should already exist when viewing this page
    render nothing:true unless @response

    @all_comments = []

    # NEW change: since response already saved 
    # fetch comments from Answer model in db instead
    answers = Answer.where(response_id: @response.id)
    answers.each do |a|
      comment = a.comments
      comment.slice! "<p>"
      comment.slice! "</p>"
      # print comment
      @all_comments.push(comment)
    end

    ##@the_params[:responses].each_pair do |k, v|
      ##comment = v[:comment]
      ##comment.slice! "<p>"
      ##comment.slice! "</p>"
      # print comment
      ##@all_comments.push(comment)
   ## end

    # send user review to API for analysis
    ##@api_response = get_review_response_metrics
    ##@response = Response.find(_params[:id])

    #compute average for all response fields
    ##suggestion_chance = 0
    #puts @api_response["results"]
    ##puts @api_response["results"].size
    ##0.upto(@api_response["results"].size - 1) do |i|
      ##suggestion_chance += @api_response["results"][i]["metrics"]["suggestion"]["suggestions_chances"]
    ##end
    ##average_suggestion_chance = suggestion_chance/@api_response["results"].size
    ##puts suggestion_chance.to_s    #debug print

    ##@response.update_suggestion_chance(average_suggestion_chance.to_i)
    # compute average

    ##@map = ResponseMap.find(@response.map_id)
    # below is class avg (suggestion score)for this assignment
    ##@response.suggestion_chance_average(@map.reviewed_object_id)

    #display average

    print("\r\nInside show_confirmation_page about to render view\r\n")
    render action: "show_confirmation_page"
  end

  def save_response(http_method)
    print("\r\n Inside the save_response(#{http_method}) method\r\n")
    

    case http_method
    when "create"

      # NEW change: is_submitted is always false for create.
      is_submitted = false

      map_id = params[:id]
      map_id = params[:map_id] unless params[:map_id].nil? # pass map_id as a hidden field in the review form
      @map = ResponseMap.find(map_id)
      if params[:review][:questionnaire_id]
        @questionnaire = Questionnaire.find(params[:review][:questionnaire_id])
        @round = params[:review][:round]
      else
        @round = nil
      end
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

      # ,:version_num=>@version)
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
    when "update"
      # the response to be updated
      @response = Response.find(params[:id])
      @map = @response.map
      msg = ""

      if params[:isSubmit]
         save_confirmed_response
         
	 # log success
         ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "Your response was submitted: #{@response.is_submitted}", request)
         
         # redirect to save method...which then redirects again
         redirect_to controller: 'response', action: 'save', id: @map.map_id,
                  return: params[:return], msg: msg, review: params[:review], save_options: params[:save_options]
      else
         save_unconfirmed_response
      end

    end
  end


  def save_confirmed_response
      @response.update_attribute('is_submitted', true) if params['isSubmit'] && params['isSubmit'] == 'Yes'
      @response.notify_instructor_on_difference if (@map.is_a? ReviewResponseMap) && @response.is_submitted && @response.significant_difference?
  end

  def save_unconfirmed_response
      begin
        #@map = @response.map

        @response.update_attribute('additional_comment', params[:review][:comments])

        @questionnaire = set_questionnaire

        questions = sort_questions(@questionnaire.questions)

        # for some rubrics, there might be no questions but only file submission (Dr. Ayala's rubric)
        create_answers(params, questions) unless params[:responses].nil?

        ##@response.update_attribute('is_submitted', true) if params['isSubmit'] && params['isSubmit'] == 'Yes'
        ##@response.notify_instructor_on_difference if (@map.is_a? ReviewResponseMap) && @response.is_submitted && @response.significant_difference?
      rescue StandardError
        msg = "Your response was not saved. Cause:189 #{$ERROR_INFO}"
      end
  end

  def save
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @map.save
    participant = Participant.find_by(id: @map.reviewee_id)
    # E1822: Added logic to insert a student suggested 'Good Teammate' or 'Good Reviewer' badge in the awarded_badges table.
    if @map.assignment.has_badge?
      if @map.is_a? TeammateReviewResponseMap and params[:review][:good_teammate_checkbox] == 'on'
        badge_id = Badge.get_id_from_name('Good Teammate')
        AwardedBadge.where(participant_id: participant.id, badge_id: badge_id, approval_status: 0).first_or_create
      end
      if @map.is_a? FeedbackResponseMap and params[:review][:good_reviewer_checkbox] == 'on'
        badge_id = Badge.get_id_from_name('Good Reviewer')
        AwardedBadge.where(participant_id: participant.id, badge_id: badge_id, approval_status: 0).first_or_create
      end
    end
    # also save response metric:suggestion_chances
    ##response_metrics = get_review_response_metrics


    # suggestion_chance = response_metrics["results"][0]["metrics"]["suggestion"]["suggestions_chances"]
    # puts suggestion_chance.class
    # puts suggestion_chance.to_s    #debug print
    # @response = Response.where(map_id: @map.id).first
    # @response.update_suggestion_chance(suggestion_chance.round)
    # @response.suggestion_chance_average(@map.reviewed_object_id)


    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "Response was successfully saved")
    redirect_to action: 'redirect', id: @map.map_id, return: params[:return], msg: params[:msg], error_msg: params[:error_msg]
  end

  def redirect
    flash[:error] = params[:error_msg] unless params[:error_msg] and params[:error_msg].empty?
    flash[:note] = params[:msg] unless params[:msg] and params[:msg].empty?
    @map = Response.find_by(map_id: params[:id])
    if params[:return] == "feedback"
      redirect_to controller: 'grades', action: 'view_my_scores', id: @map.reviewer.id
    elsif params[:return] == "teammate"
      redirect_to view_student_teams_path student_id: @map.reviewer.id
    elsif params[:return] == "instructor"
      redirect_to controller: 'grades', action: 'view', id: @map.response_map.assignment.id
    elsif params[:return] == "assignment_edit"
      redirect_to controller: 'assignments', action: 'edit', id: @map.response_map.assignment.id
    elsif params[:return] == "selfreview"
      redirect_to controller: 'submitted_content', action: 'edit', id: @map.response_map.reviewer_id
    elsif params[:return] == "survey"
      redirect_to controller: 'response', action: 'pending_surveys'
    else
      redirect_to controller: 'student_review', action: 'list', id: @map.reviewer.id
    end
  end

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

  # This method should be moved to survey_deployment_contoller.rb
  def pending_surveys
    unless session[:user] # Check for a valid user
      redirect_to '/'
      return
    end

    # Get all the course survey deployments for this user
    @surveys = []
    [CourseParticipant, AssignmentParticipant].each do |participant_type|
      # Get all the participant(course or assignment) entries for this user
      participants = participant_type.where(user_id: session[:user].id)
      next unless participants
      participants.each do |p|
        survey_deployment_type = (participant_type == CourseParticipant ? CourseSurveyDeployment : AssignmentSurveyDeployment)
        survey_deployments = survey_deployment_type.where(parent_id: p.parent_id)
        next unless survey_deployments
        survey_deployments.each do |survey_deployment|
          next unless survey_deployment && Time.now > survey_deployment.start_date && Time.now < survey_deployment.end_date
          @surveys <<
              [
                'survey' => Questionnaire.find(survey_deployment.questionnaire_id),
                'survey_deployment_id' => survey_deployment.id,
                'start_date' => survey_deployment.start_date,
                'end_date' => survey_deployment.end_date,
                'parent_id' => p.parent_id,
                'participant_id' => p.id,
                'global_survey_id' => survey_deployment.global_survey_id
              ]
        end
      end
    end
  end

  private

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

  def set_questionnaire_for_new_response
    case @map.type
    when "ReviewResponseMap", "SelfReviewResponseMap"
      reviewees_topic = SignedUpTeam.topic_id_by_team_id(@contributor.id)
      @current_round = @assignment.number_of_current_round(reviewees_topic)
      @questionnaire = @map.questionnaire(@current_round)
    when
      "MetareviewResponseMap",
      "TeammateReviewResponseMap",
      "FeedbackResponseMap",
      "CourseSurveyResponseMap",
      "AssignmentSurveyResponseMap",
      "GlobalSurveyResponseMap"
      @questionnaire = @map.questionnaire
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

  def set_questionnaire
    # if user is not filling a new rubric, the @response object should be available.
    # we can find the questionnaire from the question_id in answers
    answer = @response.scores.first
    @questionnaire = @response.questionnaire_by_answer(answer)
  end

  def set_dropdown_or_scale
    use_dropdown = AssignmentQuestionnaire.where(assignment_id: @assignment.try(:id),
                                                 questionnaire_id: @questionnaire.try(:id))
                                          .first.try(:dropdown)
    @dropdown_or_scale = (use_dropdown ? 'dropdown' : 'scale')
  end

  def sort_questions(questions)
    questions.sort_by(&:seq)
  end

  def create_answers(params, questions)
    # create score if it is not found. If it is found update it otherwise update it
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
end
