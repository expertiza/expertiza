class ResponseController < ApplicationController
  helper :submitted_content
  helper :file

  def action_allowed?
    case params[:action]
    when 'edit' # If response has been submitted, no further editing allowed
      response = Response.find(params[:id])
      return false if response.is_submitted
      return current_user_id?(response.map.reviewer.user_id)
      # Deny access to anyone except reviewer & author's team
    when 'delete', 'update'
      response = Response.find(params[:id])
      return current_user_id?(response.map.reviewer.user_id)
    when 'view'
      response = Response.find(params[:id])
      map = response.map
      assignment = response.map.reviewer.assignment
      # if it is a review response map, all the members of reviewee team should be able to view the reponse (can be done from heat map)
      if map.is_a? ReviewResponseMap
        reviewee_team = AssignmentTeam.find(map.reviewee_id)
        return current_user_id?(response.map.reviewer.user_id) || reviewee_team.has_user(current_user) || current_user.role.name == 'Administrator' || (current_user.role.name == 'Instructor' and assignment.instructor_id == current_user.id) || (current_user.role.name == 'Teaching Assistant' and TaMapping.exists?(ta_id: current_user.id, course_id: assignment.course.id))
      else
        return current_user_id?(response.map.reviewer.user_id)
      end
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
    # user cannot delete other people's responses. Needs to be authenticated.
    map_id = @response.map.id
    @response.delete
    redirect_to action: 'redirection', id: map_id, return: params[:return], msg: "The response was deleted."
  end

  # Determining the current phase and check if a review is already existing for this stage.
  # If so, edit that version otherwise create a new version.

  # Prepare the parameters when student clicks "Edit"
  def edit
    @header = "Edit"
    @next_action = "update"
    @return = params[:return]
    @response = Response.find(params[:id])

    @map = @response.map
    @contributor = @map.contributor
    set_all_responses
    if @prev.present?
      @sorted = @review_scores.sort {|m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }
      @largest_version_num = @sorted[0]
    end

    @modified_object = @response.response_id

    # set more handy variables for the view
    set_content

    @review_scores = []

    @questions.each do |question|
      @review_scores << Answer.where(response_id: @response.response_id, question_id:  question.id).first
    end
    render action: 'response'
  end

  # Update the response and answers when student "edit" existing response
  # E1600
  # Added if - else condition for 'SelfReviewResponseMap'
  def update
    return unless action_allowed?

    # the response to be updated
    @response = Response.find(params[:id])

    msg = ""
    begin
      @map = @response.map
      @response.update_attribute('additional_comment', params[:review][:comments])
      @questionnaire = if @map.type == "ReviewResponseMap" && @response.round
                         @map.questionnaire(@response.round)
                       elsif @map.type == "ReviewResponseMap"
                         @map.questionnaire(nil)
                       elsif @map.type == "SelfReviewResponseMap" && @response.round
                         @map.questionnaire(@response.round)
                       elsif @map.type == "SelfReviewResponseMap"
                         @map.questionnaire(nil)
                       else
                         @map.questionnaire
                       end
      questions = @questionnaire.questions.sort {|a, b| a.seq <=> b.seq }

      questions = sort_questions(@questionnaire.questions)
      create_answers(params, questions)
      questions = @questionnaire.questions.sort {|a, b| a.seq <=> b.seq }

      unless params[:responses].nil? # for some rubrics, there might be no questions but only file submission (Dr. Ayala's rubric)
        params[:responses].each_pair do |k, v|
          score = Answer.where(response_id: @response.id, question_id:  questions[k.to_i].id).first
          unless score
            score = Answer.create(response_id: @response.id, question_id: questions[k.to_i].id, answer: v[:score], comments: v[:comment])
          end
          score.update_attribute('answer', v[:score])
          score.update_attribute('comments', v[:comment])
        end
      end

      if (params['isSubmit'] && (params['isSubmit'].eql?'Yes'))

        # Update the submission flag.
        @response.update_attribute('is_submitted', true)
      else
        @response.update_attribute('is_submitted', false)
      end
    rescue
      msg = "Your response was not saved. Cause:189 #{$ERROR_INFO}"
    end
    redirect_to controller: 'response', action: 'saving', id: @map.map_id, return: params[:return], msg: msg, save_options: params[:save_options]
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
    render action: 'response'
  end

  def new_feedback
    review = Response.find(params[:id])
    if review
      reviewer = AssignmentParticipant.where(user_id: session[:user].id, parent_id:  review.map.assignment.id).first
      map = FeedbackResponseMap.where(reviewed_object_id: review.id, reviewer_id:  reviewer.id).first
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
    @map = ResponseMap.find(params[:id]) # assignment/review/metareview id is in params id

    set_all_responses

    # to save the response for ReviewResponseMap, a questionnaire_id is wrapped in the params
    if params[:review][:questionnaire_id]
      @questionnaire = Questionnaire.find(params[:review][:questionnaire_id])
      @round = params[:review][:round]
    else
      @round = nil
    end

    # create the response
    if params[:isSubmit].eql?('Yes')
      is_submitted = true
    else
      is_submitted = false
    end
    @response = Response.create(:map_id => @map.id, :additional_comment => params[:review][:comments],:round => @round, :is_submitted => is_submitted)#,:version_num=>@version)

    #Change the order for displaying questions for editing response views.
    questions=sort_questions(@questionnaire.questions)

    if params[:responses]
       create_answers(params, questions)
    end

    #@map.save

    msg = "Your response was successfully saved."
    error_msg = ""
    @response.email
    redirect_to controller: 'response', action: 'saving', id: @map.map_id, return: params[:return], msg: msg, error_msg: error_msg, save_options: params[:save_options]
  end

  # E1600
  # Added paramps[:return] value for 'SelfReviewResponseMap' to ensure that this method is invoked from self-review operation
  # this looks dirty to me. If other map type do not do this, there is no reason that we handle SelfReviewResponseMap here. There should be a elegant way.. --Yang
  def saving
    @map = ResponseMap.find(params[:id])
    params[:return] = "selfreview" if @map.type == "SelfReviewResponseMap"

    @return = params[:return]
    @map.save
    redirect_to action: 'redirection', id: @map.map_id, return: params[:return], msg: params[:msg], error_msg: params[:error_msg]
  end

  # E1600
  # Added if - else for 'SelfReviewResponseMap' for proper redirection
  def redirection
    flash[:error] = params[:error_msg] unless params[:error_msg] and params[:error_msg].empty?
    flash[:note] = params[:msg] unless params[:msg] and params[:msg].empty?
    @map = Response.find_by_map_id(params[:id])

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

  private

  # new_response if a flag parameter indicating that if user is requesting a new rubric to fill
  # if true: we figure out which questionnaire to use based on current time and records in assignment_questionnaires table
  # e.g. student click "Begin" or "Update" to start filling out a rubric for others' work
  # if false: we figure out which questionnaire to display base on @response object
  # e.g. student click "Edit" or "View"
  def set_content(new_response = false)
    # handy reference to response title for view
    @title = @map.get_title

    # handy reference to response assignment for ???
    @assignment = @map.assignment

    # handy reference to the reviewer for ???
    @participant = @map.reviewer

    # handy reference to the contributor (should always be a Team)
    @contributor = @map.contributor

    # set a handy reference to the response questionnaire for the view
    new_response ? set_questionnaire_for_new_response : set_questionnaire

    # set a handy reference to the dropdown_or_scale property to be used in the view
    set_dropdown_or_scale

    # set a handy reference to the response questionnaire's questions
    # sorted in a special way for the view
    @questions = sort_questions(@questionnaire.questions)

    # set a handy refence to the min/max question  for the view
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score
  end

  # E1600
  # Added 'SelfReviewResponseMap' to when condition
  def set_questionnaire_for_new_response
    case @map.type
    when "ReviewResponseMap", "SelfReviewResponseMap"
      reviewees_topic = SignedUpTeam.topic_id_by_team_id(@contributor.id)
      @current_round = @assignment.number_of_current_round(reviewees_topic)
      @questionnaire = @map.questionnaire(@current_round)
    when "MetareviewResponseMap", "TeammateReviewResponseMap", "FeedbackResponseMap"
      @questionnaire = @map.questionnaire
    end
  end

  def set_questionnaire
    # if user is not filling a new rubric, the @response object should be available.
    # we can find the questionnaire from the question_id in answers
    answer = @response.scores.first
    @questionnaire = @response.questionnaire_by_answer(answer)
  end

  def set_dropdown_or_scale
    use_dropdown = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: @questionnaire.id).first.dropdown
    @dropdown_or_scale = use_dropdown == true ? 'dropdown' : 'scale'
  end

  def sort_questions(questions)
    questions.sort {|a, b| a.seq <=> b.seq }
  end

  def create_answers(params, questions)
    # create score if it is not found. If it is found update it otherwise update it
    params[:responses].each_pair do |k, v|
      score = Answer.where(response_id: @response.id, question_id:  questions[k.to_i].id).first
      unless score
        score = Answer.create(response_id: @response.id, question_id: questions[k.to_i].id, answer: v[:score], comments: v[:comment])
      end
      score.update_attribute('answer', v[:score])
      score.update_attribute('comments', v[:comment])
    end
  end

  def set_all_responses
    # get all previous versions of responses for the response map.
    # I guess if we're in the middle of creating a new response, this would be
    # all 'previous' responses to this new one (which is not yet saved)?
    @prev = Response.where(map_id: @map.id)
    # not sure what this is about
    @review_scores = @prev.to_a
  end
end
