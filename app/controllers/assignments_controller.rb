class AssignmentsController < ApplicationController
  include AssignmentHelper
  include AuthorizationHelper
  autocomplete :user, :name
  before_action :authorize

  # determines if an action is allowed for a user
  def action_allowed?
    if %w[edit update list_submissions].include? params[:action]
      current_user_has_admin_privileges? || current_user_teaching_staff_of_assignment?(params[:id])
    else
      current_user_has_ta_privileges?
    end
  end

  # creates and renders a new assignment form
  def new
    @assignment_form = AssignmentForm.new
    @assignment_form.assignment.instructor ||= current_user
    @num_submissions_round = 0
    @num_reviews_round = 0
    @default_num_metareviews_required = 3
  end

  # creates a new assignment via the assignment form
  def create
    @assignment_form = AssignmentForm.new(assignment_form_params)
    if params[:button]
      # E2138 issue #3
      find_existing_assignment = Assignment.find_by(name: @assignment_form.assignment.name, course_id: @assignment_form.assignment.course_id)
      dir_path = assignment_form_params[:assignment][:directory_path]
      find_existing_directory = Assignment.find_by(directory_path: dir_path, course_id: @assignment_form.assignment.course_id)
      if !find_existing_assignment && !find_existing_directory && @assignment_form.save # No existing names/directories
        @assignment_form.create_assignment_node
        exist_assignment = Assignment.find(@assignment_form.assignment.id)
        assignment_form_params[:assignment][:id] = exist_assignment.id.to_s
        if assignment_form_params[:assignment][:directory_path].blank?
          assignment_form_params[:assignment][:directory_path] = "assignment_#{assignment_form_params[:assignment][:id]}"
        end
        ques_array = assignment_form_params[:assignment_questionnaire]
        due_array = assignment_form_params[:due_date]
        ques_array.each do |cur_questionnaire|
          cur_questionnaire[:assignment_id] = exist_assignment.id.to_s
        end
        due_array.each do |cur_due|
          cur_due[:parent_id] = exist_assignment.id.to_s
        end
        assignment_form_params[:assignment_questionnaire] = ques_array
        assignment_form_params[:due_date] = due_array
        @assignment_form.update(assignment_form_params, current_user)
        aid = Assignment.find(@assignment_form.assignment.id).id
        ExpertizaLogger.info "Assignment created: #{@assignment_form.as_json}"
        redirect_to edit_assignment_path aid
        undo_link("Assignment \"#{@assignment_form.assignment.name}\" has been created successfully. ")
        return
      else
        flash[:error] = 'Failed to create assignment.'
        if find_existing_assignment
          flash[:error] << '<br>  ' + @assignment_form.assignment.name + ' already exists as an assignment name'
        end
        if find_existing_directory
          flash[:error] << '<br>  ' + dir_path + ' already exists as a submission directory name'
        end
        redirect_to '/assignments/new?private=1'
      end
    else
      render 'new'
      undo_link("Assignment \"#{@assignment_form.assignment.name}\" has been created successfully. ")
    end
  end

  # edits an assignment's deadlines and assigned rubrics
  def edit
    user_timezone_specified
    edit_params_setting
    assignment_staggered_deadline?
    update_due_date
    check_questionnaires_usage
    @due_date_all = update_nil_dd_deadline_name(@due_date_all)
    @due_date_all = update_nil_dd_description_url(@due_date_all)
    unassigned_rubrics_warning
    path_warning_and_answer_tag
    update_assignment_badges
    @assigned_badges = @assignment_form.assignment.badges
    @badges = Badge.all
    @use_bookmark = @assignment.use_bookmark
    @duties = Duty.where(assignment_id: @assignment_form.assignment.id)
  end

  # updates an assignment via an assignment form
  def update
    unless params.key?(:assignment_form)
      key_nonexistent_handler
      return
    end
    retrieve_assignment_form
    assignment_staggered_deadline?
    nil_timezone_update
    update_feedback_attributes
    query_participants_and_alert

    if params['button'].nil?
      render partial: 'assignments/edit/topics'
    else
      # SAVE button was used (do a redirect)
      redirect_to edit_assignment_path @assignment_form.assignment.id
    end
  end

  # displays an assignment via ID
  def show
    @assignment = Assignment.find(params[:id])
  end

  # gets an assignment's path/url
  def path
    begin
      file_path = @assignment.path
    rescue StandardError
      file_path = nil
    end
    file_path
  end

  # makes a copy of an assignment
  def copy
    update_copy_session
    # check new assignment submission directory and old assignment submission directory
    new_assign_id = AssignmentForm.copy(params[:id], @user)
    if new_assign_id
      if check_same_directory?(params[:id], new_assign_id)
        flash[:note] = 'Warning: The submission directory for the copy of this assignment will be the same as the submission directory '\
          'for the existing assignment. This will allow student submissions to one assignment to overwrite submissions to the other assignment. '\
          'If you do not want this to happen, change the submission directory in the new copy of the assignment.'
      end
      redirect_to edit_assignment_path new_assign_id
    else
      flash[:error] = 'The assignment was not able to be copied. Please check the original assignment for missing information.'
      redirect_to list_tree_display_index_path
    end
  end

  # deletes an assignment
  def delete
    begin
      assignment_form = AssignmentForm.create_form_object(params[:id])
      user = session[:user]
      # Issue 1017 - allow instructor to delete assignment created by TA.
      # FixA : TA can only delete assignment created by itself.
      # FixB : Instrucor will be able to delete any assignment belonging to his/her courses.
      if (user.role.name == 'Instructor') || ((user.role.name == 'Teaching Assistant') && (user.id == assignment_form.assignment.instructor_id))
        assignment_form.delete(params[:force])
        ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "Assignment #{assignment_form.assignment.id} was deleted.", request)
        flash[:success] = 'The assignment was successfully deleted.'
      else
        ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, 'You are not authorized to delete this assignment.', request)
        flash[:error] = 'You are not authorized to delete this assignment.'
      end
    rescue StandardError => e
      flash[:error] = e.message
    end

    redirect_to list_tree_display_index_path
  end

  # sets the current assignment and suggestions for the assignment
  def delayed_mailer
    @suggestions = Suggestion.where(assignment_id: params[:id])
    @assignment = Assignment.find(params[:id])
  end

  # place an assignment in a course
  def place_assignment_in_course
    @assignment = Assignment.find(params[:id])
    @courses = Assignment.assign_courses_to_assignment(current_user)
  end

  # list team assignment submissions
  def list_submissions
    @assignment = Assignment.find(params[:id])
    @teams = Team.where(parent_id: params[:id])
  end

  # remove an assignment from a course. Doesn't delete assignment
  def remove_assignment_from_course
    assignment = Assignment.find(params[:id])
    assignment.remove_assignment_from_course
    redirect_to list_tree_display_index_path
  end

  def delete_delayed_mailer
    queue = Sidekiq::Queue.new('mailers')
    queue.each do |job|
      job.delete if job.jid == params[:delayed_job_id]
    end
    redirect_to delayed_mailer_assignments_index_path params[:id]
  end

  # Provide a means for a rendering of all flash messages to be requested
  # This is useful because the assignments page has tabs
  #   and switching tabs acts like a "save" but does NOT cause a new page load
  #   so if we want to see via flash messages when something goes wrong,
  #   we need to ask about it
  # Doing it this way has a few advantages
  #   doesn't matter what kind of flash item is set (error, note, notice, etc.)
  #   doesn't matter what tab we are on (anybody can request this render)
  #   doesn't matter where the flash item originated, anything can get seen this way
  def instant_flash
    render partial: 'shared/flash_messages'
  end

  private

  # check whether rubrics are set before save assignment
  def list_unassigned_rubrics
    rubrics_list = %w[ReviewQuestionnaire
                      MetareviewQuestionnaire AuthorFeedbackQuestionnaire
                      TeammateReviewQuestionnaire BookmarkRatingQuestionnaire]
    @assignment_questionnaires.each do |aq|
      remove_existing_questionnaire(rubrics_list, aq)
    end

    remove_invalid_questionnaires(rubrics_list)
    rubrics_list
  end

  # Removes questionnaire types from the rubric list that are already on the assignment
  def remove_existing_questionnaire(rubrics_list, aq)
    return if aq.questionnaire_id.nil?

    rubrics_list.reject! do |rubric|
      rubric == Questionnaire.where(id: aq.questionnaire_id).first.type.to_s
    end
  end

  # Removes questionnaire types from the rubric list that shouldn't be there
  # e.g. remove teammate review questionnaire if the maximum team size is one person (there are no teammates)
  def remove_invalid_questionnaires(rubrics_list)
    rubrics_list.delete('TeammateReviewQuestionnaire') if @assignment_form.assignment.max_team_size == 1
    rubrics_list.delete('MetareviewQuestionnaire') unless @metareview_allowed
    rubrics_list.delete('BookmarkRatingQuestionnaire') unless @assignment_form.assignment.use_bookmark
  end

  # lists parts of the assignment that need a rubric assigned
  def needed_rubrics(empty_rubrics_list)
    needed_rub = '<b>['
    empty_rubrics_list.each do |item|
      needed_rub += item[0...-13] + ', '
    end
    needed_rub = needed_rub[0...-2]
    needed_rub += '] </b>'
  end

  # checks an assignment's due date has a name or description
  def due_date_nameurl_not_empty?(dd)
    dd.deadline_name.present? || dd.description_url.present?
  end

  # checks if an assignment allows meta reviews
  def meta_review_allowed?(dd)
    dd.deadline_type_id == DeadlineHelper::DEADLINE_TYPE_METAREVIEW
  end

  # checks if an assignment allows topic drops
  def drop_topic_allowed?(dd)
    dd.deadline_type_id == DeadlineHelper::DEADLINE_TYPE_DROP_TOPIC
  end

  # checks if an assignment allows for topic sign ups
  def signup_allowed?(dd)
    dd.deadline_type_id == DeadlineHelper::DEADLINE_TYPE_SIGN_UP
  end

  # checks if an assignment allows teams to be formed
  def team_formation_allowed?(dd)
    dd.deadline_type_id == DeadlineHelper::DEADLINE_TYPE_TEAM_FORMATION
  end

  # sets an assignment's deadline name
  def update_nil_dd_deadline_name(due_date_all)
    due_date_all.each do |dd|
      dd.deadline_name ||= ''
    end
    due_date_all
  end

  # sets an assignment's due date description
  def update_nil_dd_description_url(due_date_all)
    due_date_all.each do |dd|
      dd.description_url ||= ''
    end

    due_date_all
  end

  # helper methods for create

  # handle assignment form saved condition
  def assignment_form_save_handler
    exist_assignment = Assignment.find_by(name: @assignment_form.assignment.name)
    assignment_form_params[:assignment][:id] = exist_assignment.id.to_s
    fix_assignment_missing_path
    update_assignment_form(exist_assignment)
    aid = Assignment.find_by(name: @assignment_form.assignment.name).id
    ExpertizaLogger.info "Assignment created: #{@assignment_form.as_json}"
    redirect_to edit_assignment_path aid
    undo_link("Assignment \"#{@assignment_form.assignment.name}\" has been created successfully. ")
  end

  # update_assignment_form_params to handle non existent directory path
  def fix_assignment_missing_path
    assignment_form_params[:assignment][:directory_path] = "assignment_#{assignment_form_params[:assignment][:id]}" \
    if assignment_form_params[:assignment][:directory_path].blank?
  end

  # update assignment_form with assignment_questionnaire and due_date
  def update_assignment_form(exist_assignment)
    questionnaire_array = assignment_form_params[:assignment_questionnaire]
    questionnaire_array.each { |cur_questionnaire| cur_questionnaire[:assignment_id] = exist_assignment.id.to_s }
    assignment_form_params[:assignment_questionnaire]
    due_array = assignment_form_params[:due_date]
    due_array.each { |cur_due| cur_due[:parent_id] = exist_assignment.id.to_s }
    assignment_form_params[:due_date]
    @assignment_form.update(assignment_form_params, current_user)
  end

  # helper methods for copy
  # checks if two assignments are in the same directory
  def check_same_directory?(old_id, new_id)
    Assignment.find(old_id).directory_path == Assignment.find(new_id).directory_path
  end

  # sets the user for the copy method to the current user and indicates the session is for copying
  def update_copy_session
    @user = current_user
    session[:copy_flag] = true
  end

  # helper methods for edit

  # populates values and settings of the assignment for editing
  def edit_params_setting
    @assignment = Assignment.find(params[:id])
    @num_submissions_round = @assignment.find_due_dates('submission').nil? ? 0 : @assignment.find_due_dates('submission').count
    @num_reviews_round = @assignment.find_due_dates('review').nil? ? 0 : @assignment.find_due_dates('review').count

    @topics = SignUpTopic.where(assignment_id: params[:id])
    @assignment_form = AssignmentForm.create_form_object(params[:id])
    @user = current_user

    @assignment_questionnaires = AssignmentQuestionnaire.where(assignment_id: params[:id])
    @due_date_all = AssignmentDueDate.where(parent_id: params[:id])
    @due_date_nameurl_not_empty = false
    @due_date_nameurl_not_empty_checkbox = false
    @metareview_allowed = false
    @metareview_allowed_checkbox = false
    @signup_allowed = false
    @signup_allowed_checkbox = false
    @drop_topic_allowed = false
    @drop_topic_allowed_checkbox = false
    @team_formation_allowed = false
    @team_formation_allowed_checkbox = false
    @participants_count = @assignment_form.assignment.participants.size
    @teams_count = @assignment_form.assignment.teams.size
  end

  # populates assignment deadlines in the form if they are staggered
  def assignment_staggered_deadline?
    if @assignment_form.assignment.staggered_deadline == true
      @review_rounds = @assignment_form.assignment.num_review_rounds
      @due_date_all ||= AssignmentDueDate.where(parent_id: @assignment_form.assignment.id)
      @assignment_submission_due_dates = @due_date_all.select { |due_date| due_date.deadline_type_id == DeadlineHelper::DEADLINE_TYPE_SUBMISSION }
      @assignment_review_due_dates = @due_date_all.select { |due_date| due_date.deadline_type_id == DeadlineHelper::DEADLINE_TYPE_REVIEW }
    end
    @assignment_form.assignment.staggered_deadline == true
  end

  # gets the current settings of the current assignment
  def update_due_date_nameurl(dd)
    @due_date_nameurl_not_empty = due_date_nameurl_not_empty?(dd)
    @due_date_nameurl_not_empty_checkbox = @due_date_nameurl_not_empty
    @metareview_allowed = meta_review_allowed?(dd)
    @drop_topic_allowed = drop_topic_allowed?(dd)
    @signup_allowed = signup_allowed?(dd)
    @team_formation_allowed = team_formation_allowed?(dd)
  end

  # adjusts the time zone for a due date
  def adjust_due_date_for_timezone(dd)
    dd.due_at = dd.due_at.to_s.in_time_zone(current_user.timezonepref) if dd.due_at.present?
  end

  # ensures due dates ahave a name, description and at least either meta reviews, topic drops, signups, or team formations
  def validate_due_date
    @due_date_nameurl_not_empty && @due_date_nameurl_not_empty_checkbox &&
      (@metareview_allowed || @drop_topic_allowed || @signup_allowed || @team_formation_allowed)
  end

  # checks if each questionnaire in an assignment is used
  def check_questionnaires_usage
    @assignment_questionnaires.each do |aq|
      unless aq.used_in_round.nil?
        @reviewvarycheck = 1
        break
      end
    end
  end

  # determines what aspecs of an assignment need a rubric and provides a notice
  def unassigned_rubrics_warning
    if !list_unassigned_rubrics.empty? && request.original_fullpath == "/assignments/#{@assignment_form.assignment.id}/edit"
      rubrics_needed = needed_rubrics(list_unassigned_rubrics)
      ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].name, "Rubrics missing for #{@assignment_form.assignment.name}.", request)
      if flash.now[:error] != 'Failed to save the assignment: ["Total weight of rubrics should add up to either 0 or 100%"]'
        flash.now[:error] = 'You did not specify all the necessary rubrics. You need ' + rubrics_needed +
                            " of assignment <b>#{@assignment_form.assignment.name}</b> before saving the assignment. You can assign rubrics" \
                            " <a id='go_to_tabs2' style='color: blue;'>here</a>."
      end
    end
  end

  # flashes an error if an assignment has no directory and sets tag prompting
  def path_warning_and_answer_tag
    if @assignment_form.assignment.directory_path.blank?
      flash.now[:error] = 'You did not specify your submission directory.'
      ExpertizaLogger.error LoggerMessage.new(controller_name, '', 'Submission directory not specified', request)
    end
    @assignment_form.tag_prompt_deployments = TagPromptDeployment.where(assignment_id: params[:id]) if @assignment_form.assignment.is_answer_tagging_allowed
  end

  # update values for an assignment's due date when editing
  def update_due_date
    @due_date_all.each do |dd|
      update_due_date_nameurl(dd)
      adjust_due_date_for_timezone(dd)
      break if validate_due_date
    end
  end

  # update the current assignment's badges when editing
  def update_assignment_badges
    @assigned_badges = @assignment_form.assignment.badges
    @badges = Badge.all
  end

  # flash notice if the time zone is not specified for an assignment's due date
  def user_timezone_specified
    ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].name, 'Timezone not specified', request) if current_user.timezonepref.nil?
    flash.now[:error] = 'You have not specified your preferred timezone yet. Please do this before you set up the deadlines.' if current_user.timezonepref.nil?
  end

  # helper methods for update

  # flashes notice if corresponding to an assignment's save status
  def key_nonexistent_handler
    @assignment = Assignment.find(params[:id])
    @assignment.course_id = params[:course_id]

    if @assignment.save
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "The assignment was successfully saved: #{@assignment.as_json}", request)
      flash[:note] = 'The assignment was successfully saved.'
      redirect_to list_tree_display_index_path
    else
      ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].name, "Failed assignment: #{@assignment.errors.full_messages.join(' ')}", request)
      flash[:error] = "Failed to save the assignment: #{@assignment.errors.full_messages.join(' ')}"
      redirect_to edit_assignment_path @assignment.id
    end
  end

  def retrieve_assignment_form
    @assignment_form = AssignmentForm.create_form_object(params[:id])
    @assignment_form.assignment.instructor ||= current_user
    params[:assignment_form][:assignment_questionnaire].reject! do |q|
      q[:questionnaire_id].empty?
    end
    # Deleting Due date info from table if meta-review is unchecked. - UNITY ID: ralwan and vsreeni
    @due_date_info = DueDate.where(parent_id: params[:id])
    DueDate.where(parent_id: params[:id], deadline_type_id: 5).destroy_all if params[:metareview_allowed] == 'false'
  end

  # sets assignment time zone if not specified and flashes a warning
  def nil_timezone_update
    if current_user.timezonepref.nil?
      parent_id = current_user.parent_id
      parent_timezone = User.find(parent_id).timezonepref
      flash[:error] = 'We strongly suggest that instructors specify their preferred timezone to'\
          ' guarantee the correct display time. For now we assume you are in ' + parent_timezone
      current_user.timezonepref = parent_timezone
    end
  end

  # updates an assignment's attributes and flashes a notice on the status of the save
  def update_feedback_attributes
    if params[:set_pressed][:bool] == 'false'
      flash[:error] = "There has been some submissions for the rounds of reviews that you're trying to reduce. You can only increase the round of review."
    elsif @assignment_form.update_attributes(assignment_form_params, current_user)
      flash[:note] = 'The assignment was successfully saved....'
      if @assignment_form.rubric_weight_error(assignment_form_params)
        flash[:error] = 'A rubric has no ScoredQuestions, but still has a weight. Please change the weight to 0.'
      end
    else
      flash[:error] = "Failed to save the assignment: #{@assignment_form.errors}"
    end
    ExpertizaLogger.info LoggerMessage.new('', session[:user].name, "The assignment was saved: #{@assignment_form.as_json}", request)
  end

  def query_participants_and_alert
    assignment = Assignment.find(params[:id])
    if assignment.participants.empty?
      flash[:error] = %(Saved assignment is missing participants. Add them <a href="/participants/list?id=#{assignment.id}&model=Assignment">here</a>)
    end
  end

  # sets values allowed for the assignment form
  def assignment_form_params
    params.require(:assignment_form).permit!
  end
end
