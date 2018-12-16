class AssignmentsController < ApplicationController
  include AssignmentHelper
  autocomplete :user, :name
  before_action :authorize

  def action_allowed?
    if %w[edit update list_submissions].include? params[:action]
      assignment = Assignment.find(params[:id])
      (%w[Super-Administrator Administrator].include? current_role_name) ||
      (assignment.instructor_id == current_user.try(:id)) ||
      TaMapping.exists?(ta_id: current_user.try(:id), course_id: assignment.course_id) ||
      (assignment.course_id && Course.find(assignment.course_id).instructor_id == current_user.try(:id))
    else
      ['Super-Administrator',
       'Administrator',
       'Instructor',
       'Teaching Assistant'].include? current_role_name
    end
  end

  def new
    @assignment_form = AssignmentForm.new
    @assignment_form.assignment.instructor ||= current_user
    @num_submissions_round = 0
    @num_reviews_round = 0
  end

  def create
    @assignment_form = AssignmentForm.new(assignment_form_params)
    if params[:button]
      if @assignment_form.save
        @assignment_form.create_assignment_node
        exist_assignment = Assignment.find_by_name(@assignment_form.assignment.name)
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
        @assignment_form.update(assignment_form_params,current_user)
        aid = Assignment.find_by_name(@assignment_form.assignment.name).id
        ExpertizaLogger.info "Assignment created: #{@assignment_form.as_json}"
        redirect_to edit_assignment_path aid
        undo_link("Assignment \"#{@assignment_form.assignment.name}\" has been created successfully. ")
        return
      else
        flash.now[:error] = "Failed to create assignment"
        render 'new'
      end
    else
      render 'new'
      undo_link("Assignment \"#{@assignment_form.assignment.name}\" has been created successfully. ")
    end
  end

  def edit
    ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].name, "Timezone not specified", request) if current_user.timezonepref.nil?
    flash.now[:error] = "You have not specified your preferred timezone yet. Please do this before you set up the deadlines." if current_user.timezonepref.nil?
    edit_params_setting
    assignment_form_assignment_staggered_deadline?
    @due_date_all.each do |dd|
      check_due_date_nameurl_not_empty(dd)
      adjust_timezone_when_due_date_present(dd)
      break if validate_due_date
    end
    check_assignment_questionnaires_usage
    @due_date_all = update_nil_dd_deadline_name(@due_date_all)
    @due_date_all = update_nil_dd_description_url(@due_date_all)
    # only when instructor does not assign rubrics and in assignment edit page will show this error message.
    handle_rubrics_not_assigned_case
    handle_assignment_directory_path_nonexist_case_and_answer_tagging
    # assigned badges will hold all the badges that have been assigned to an assignment
    # added it to display the assigned badges while creating a badge in the assignments page
    @assigned_badges = @assignment_form.assignment.badges
    @badges = Badge.all
  end

  def update
    unless params.key?(:assignment_form)
      assignment_form_key_nonexist_case_handler
      return
    end
    retrieve_assignment_form
    handle_current_user_timezonepref_nil
    update_feedback_assignment_form_attributes
    redirect_to edit_assignment_path @assignment_form.assignment.id
  end

  def show
    @assignment = Assignment.find(params[:id])
  end

  def path
    begin
      file_path = @assignment.path
    rescue StandardError
      file_path = nil
    end
    file_path
  end

  def copy
    @user = current_user
    session[:copy_flag] = true
    # check new assignment submission directory and old assignment submission directory
    old_assign = Assignment.find(params[:id])
    new_assign_id = AssignmentForm.copy(params[:id], @user)
    if new_assign_id
      new_assign = Assignment.find(new_assign_id)
      if old_assign.directory_path == new_assign.directory_path
        flash[:note] = "Warning: The submission directory for the copy of this assignment will be the same as the submission directory "\
          "for the existing assignment. This will allow student submissions to one assignment to overwrite submissions to the other assignment. "\
          "If you do not want this to happen, change the submission directory in the new copy of the assignment."
      end
      redirect_to edit_assignment_path new_assign_id
    else
      flash[:error] = 'The assignment was not able to be copied. Please check the original assignment for missing information.'
      redirect_to list_tree_display_index_path
    end
  end

  def delete
    begin
      @assignment_form = AssignmentForm.create_form_object(params[:id])
      @user = session[:user]
      id = @user.get_instructor
      if id != @assignment_form.assignment.instructor_id
        ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "You are not authorized to delete this assignment.", request)
        raise "You are not authorized to delete this assignment."
      else
        @assignment_form.delete(params[:force])
        ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "Assignment #{@assignment_form.assignment.id} was deleted.", request)
        flash[:success] = "The assignment was successfully deleted."
      end
    rescue StandardError => e
      flash[:error] = e.message
    end

    redirect_to list_tree_display_index_path
  end

  def delayed_mailer
    @suggestions = Suggestion.where(assignment_id: params[:id])
    @assignment = Assignment.find(params[:id])
  end

  def associate_assignment_with_course
    @assignment = Assignment.find(params[:id])
    @courses = Assignment.set_courses_to_assignment(current_user)
  end

  def list_submissions
    @assignment = Assignment.find(params[:id])
    @teams = Team.where(parent_id: params[:id])
  end

  def remove_assignment_from_course
    assignment = Assignment.find(params[:id])
    Assignment.remove_assignment_from_course(assignment)
    redirect_to list_tree_display_index_path
  end

  def delete_delayed_mailer
    @delayed_job = DelayedJob.find(params[:delayed_job_id])
    @delayed_job.delete
    redirect_to delayed_mailer_assignments_index_path params[:id]
  end

  private

  # check whether rubrics are set before save assignment
  def empty_rubrics_list
    rubrics_list = %w[ReviewQuestionnaire
                      MetareviewQuestionnaire AuthorFeedbackQuestionnaire
                      TeammateReviewQuestionnaire BookmarkRatingQuestionnaire]
    @assignment_questionnaires.each do |aq|
      next if aq.questionnaire_id.nil?

      rubrics_list.reject! do |rubric|
        rubric == Questionnaire.where(id: aq.questionnaire_id).first.type.to_s
      end
    end
    rubrics_list.delete('TeammateReviewQuestionnaire') if @assignment_form.assignment.max_team_size == 1
    rubrics_list.delete('MetareviewQuestionnaire') unless @metareview_allowed
    rubrics_list.delete('BookmarkRatingQuestionnaire') unless @assignment_form.assignment.use_bookmark
    rubrics_list
  end

  def needed_rubrics(empty_rubrics_list)
    needed_rub = '<b>['
    empty_rubrics_list.each do |item|
      needed_rub += item[0...-13] + ', '
    end
    needed_rub = needed_rub[0...-2]
    needed_rub += '] </b>'
  end

  def due_date_nameurl_not_empty?(dd)
    dd.deadline_name.present? || dd.description_url.present?
  end

  def meta_review_allowed?(dd)
    dd.deadline_type_id == DeadlineHelper::DEADLINE_TYPE_METAREVIEW
  end

  def drop_topic_allowed?(dd)
    dd.deadline_type_id == DeadlineHelper::DEADLINE_TYPE_DROP_TOPIC
  end

  def signup_allowed?(dd)
    dd.deadline_type_id == DeadlineHelper::DEADLINE_TYPE_SIGN_UP
  end

  def team_formation_allowed?(dd)
    dd.deadline_type_id == DeadlineHelper::DEADLINE_TYPE_TEAM_FORMATION
  end

  def update_nil_dd_deadline_name(due_date_all)
    due_date_all.each do |dd|
      dd.deadline_name ||= ''
    end
    due_date_all
  end

  def update_nil_dd_description_url(due_date_all)
    due_date_all.each do |dd|
      dd.description_url ||= ''
    end

    due_date_all
  end

  # helper methods for edit
  def edit_params_setting

    @assignment = Assignment.find(params[:id])
    @num_submissions_round = @assignment.find_due_dates('submission') == nil ? 0 : @assignment.find_due_dates('submission').count
    @num_reviews_round = @assignment.find_due_dates('review') == nil ? 0 : @assignment.find_due_dates('review').count

    @topics = SignUpTopic.where(assignment_id: params[:id])
    @assignment_form = AssignmentForm.create_form_object(params[:id])
    @user = current_user

    @assignment_questionnaires = AssignmentQuestionnaire.where(assignment_id: params[:id])
    @due_date_all = AssignmentDueDate.where(parent_id: params[:id])
    @reviewvarycheck = false
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

  def assignment_form_assignment_staggered_deadline?
    if @assignment_form.assignment.staggered_deadline == true
      @review_rounds = @assignment_form.assignment.num_review_rounds
      @assignment_submission_due_dates = @due_date_all.select {|due_date| due_date.deadline_type_id == DeadlineHelper::DEADLINE_TYPE_SUBMISSION }
      @assignment_review_due_dates = @due_date_all.select {|due_date| due_date.deadline_type_id == DeadlineHelper::DEADLINE_TYPE_REVIEW }
    end
    @assignment_form.assignment.staggered_deadline == true
  end

  def check_due_date_nameurl_not_empty(dd)
    @due_date_nameurl_not_empty = due_date_nameurl_not_empty?(dd)
    @due_date_nameurl_not_empty_checkbox = @due_date_nameurl_not_empty
    @metareview_allowed = meta_review_allowed?(dd)
    @drop_topic_allowed = drop_topic_allowed?(dd)
    @signup_allowed = signup_allowed?(dd)
    @team_formation_allowed = team_formation_allowed?(dd)
  end

  def adjust_timezone_when_due_date_present(dd)
    dd.due_at = dd.due_at.to_s.in_time_zone(current_user.timezonepref) if dd.due_at.present?
  end

  def validate_due_date
    @due_date_nameurl_not_empty && @due_date_nameurl_not_empty_checkbox &&
      (@metareview_allowed || @drop_topic_allowed || @signup_allowed || @team_formation_allowed)
  end

  def check_assignment_questionnaires_usage
    @assignment_questionnaires.each do |aq|
      unless aq.used_in_round.nil?
        @reviewvarycheck = 1
        break
      end
    end
  end

  def handle_rubrics_not_assigned_case
    if !empty_rubrics_list.empty? && request.original_fullpath == "/assignments/#{@assignment_form.assignment.id}/edit"
      rubrics_needed = needed_rubrics(empty_rubrics_list)
      ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].name, "Rubrics missing for #{@assignment_form.assignment.name}.", request)
      flash.now[:error] = "You did not specify all the necessary rubrics. You need " + rubrics_needed +
          " of assignment <b>#{@assignment_form.assignment.name}</b> before saving the assignment. You can assign rubrics <a id='go_to_tabs2' style='color: blue;'>here</a>."
    end
  end

  def handle_assignment_directory_path_nonexist_case_and_answer_tagging
    if @assignment_form.assignment.directory_path.blank?
      flash.now[:error] = "You did not specify your submission directory."
      ExpertizaLogger.error LoggerMessage.new(controller_name, "", "Submission directory not specified", request)
    end
    @assignment_form.tag_prompt_deployments = TagPromptDeployment.where(assignment_id: params[:id]) if @assignment_form.assignment.is_answer_tagging_allowed
  end

  # helper methods for update
  def assignment_form_key_nonexist_case_handler
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

    @due_date_info = DueDate.find_each(parent_id: params[:id])

    if params[:metareviewAllowed] == "false"
      DueDate.where(parent_id: params[:id], deadline_type_id: 5).destroy_all
    end
  end

  def handle_current_user_timezonepref_nil
    if current_user.timezonepref.nil?
      parent_id = current_user.parent_id
      parent_timezone = User.find(parent_id).timezonepref
      flash[:error] = "We strongly suggest that instructors specify their preferred timezone to guarantee the correct display time. For now we assume you are in " + parent_timezone
      current_user.timezonepref = parent_timezone
    end
  end

  def update_feedback_assignment_form_attributes
    if params[:set_pressed][:bool] == 'false'
      flash[:error] = "There has been some submissions for the rounds of reviews that you're trying to reduce. You can only increase the round of review."
    else
      if @assignment_form.update_attributes(assignment_form_params, current_user)
        flash[:note] = 'The assignment was successfully saved....'
      else
        flash[:error] = "Failed to save the assignment: #{@assignment_form.errors.get(:message)}"
      end
    end
    ExpertizaLogger.info LoggerMessage.new("", session[:user].name, "The assignment was saved: #{@assignment_form.as_json}", request)
  end

  def assignment_form_params
    params.require(:assignment_form).permit!
  end
end