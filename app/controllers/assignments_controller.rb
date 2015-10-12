class AssignmentsController < ApplicationController
  autocomplete :user, :name
  before_filter :authorize

  def action_allowed?
    if params[:action] == 'edit' or params[:action] == 'update'
      assignment = Assignment.find(params[:id])
      return true if ['Super-Administrator', 'Administrator'].include? current_role_name
      return true if assignment.instructor_id == session[:user].id
      return true if TaMapping.exists?(ta_id: session[:user].id, course_id: assignment.course_id) and TaMapping.where(course_id: assignment.course_id).include?TaMapping.where(ta_id: session[:user].id, course_id: assignment.course_id).first
      return false
    else
      ['Super-Administrator',
       'Administrator',
       'Instructor',
       'Teaching Assistant'].include? current_role_name
    end
  end

  # change access permission from public to private or vice versa
  def toggle_access
    assignment = Assignment.find(params[:id])
    assignment.private = !assignment.private
    assignment.save
    redirect_to :controller => 'tree_display', :action => 'list'
  end

  def new
    @assignment_form = AssignmentForm.new
    @assignment_form.assignment.instructor ||= current_user
  end

  def create
    @assignment_form = AssignmentForm.new(assignment_form_params)
    #This one is working
    #       emails = Array.new
    #      #emails<<"vikas.023@gmail.com"
    #Mailer.generic_message(
    #    {:bcc => emails,
    #     :subject => "one",
    #     #:body => "two",
    #    :partial_name => 'update'
    #    }).deliver

    if @assignment_form.save
      @assignment_form.create_assignment_node
      # flash[:success] = 'Assignment was successfully created.'
      # redirect_to controller: :assignments, action: :edit, id: @assignment.id
      #AAD#
      redirect_to :action => 'edit', :id => @assignment_form.assignment.id
      undo_link("Assignment \"#{@assignment_form.assignment.name}\" has been created successfully. ")
      #AAD#
    else
      render 'new'
    end
  end

  def edit
    # give an error message is instructor have not set the time zone.
    if session[:user].timezonepref.nil?
      flash.now[:error] = "You have not specified you preferred timezone yet. Please do this first before you set up the deadlines."
    end
    @topics = SignUpTopic.find_by_sql("select * from sign_up_topics where assignment_id="+params[:id])
    @assignment_form = AssignmentForm.create_form_object(params[:id])
    @user = current_user

    @assignment_questionnaires = AssignmentQuestionnaire::where(assignment_id: params[:id])
    @due_date_all = DueDate::where(assignment_id: params[:id])
    @reviewvarycheck = false
    @due_date_nameurl_notempty = false
    @due_date_nameurl_notempty_checkbox = false
    @metareview_allowed=false
    @metareview_allowed_checkbox=false
    @signup_allowed=false
    @signup_allowed_checkbox=false
    @drop_topic_allowed=false
    @drop_topic_allowed_checkbox=false
    @team_formation_allowed=false
    @team_formation_allowed_checkbox=false
    @participants_count = @assignment_form.assignment.participants.size
    @teams_count = @assignment_form.assignment.teams.size

    # Check if name and url in database is empty before webpage displays
    @due_date_all.each do |dd|
      if((!dd.deadline_name.nil?&&!dd.deadline_name.empty?)||(!dd.description_url.nil?&&!dd.description_url.empty?))
        @due_date_nameurl_notempty = true
        @due_date_nameurl_notempty_checkbox = true
      end
      if dd.due_at.present?
          dd.due_at = dd.due_at.to_s.in_time_zone(session[:user].timezonepref)
      end
      if dd.deadline_type_id==5
        @metareview_allowed = true
      end
      if @due_date_nameurl_notempty && @due_date_nameurl_notempty_checkbox && @metareview_allowed
        break
      end
      if dd.deadline_type_id==6
        @drop_topic_allowed = true
      end
      if @due_date_nameurl_notempty && @due_date_nameurl_notempty_checkbox && @drop_topic_allowed
        break
      end
      if dd.deadline_type_id==7
        @signup_allowed = true
      end
      if @due_date_nameurl_notempty && @due_date_nameurl_notempty_checkbox && @signup_allowed
        break
      end
      if dd.deadline_type_id==8
        @team_formation_allowed = true
      end
      if @due_date_nameurl_notempty && @due_date_nameurl_notempty_checkbox && @team_formation_allowed
        break
      end
    end
    @assignment_questionnaires.each do  |aq|
      if(!(aq.used_in_round.nil?))
        @reviewvarycheck = 1
        break
      end
    end
    @due_date_all.each do |dd|
      if dd.deadline_name.nil?
        dd.deadline_name=""
      end
      if dd.description_url.nil?
        dd.description_url=""
      end
    end
    #only when instructor does not assign rubrics and in assignment edit page will show this error message.
    if !empty_rubrics_list.empty? and request.original_fullpath == "/assignments/#{@assignment_form.assignment.id}/edit"
      empty_rubrics = "<b>["
      empty_rubrics_list.each do |item|
        empty_rubrics += item[0...-13] + ", "
      end
      empty_rubrics = empty_rubrics[0...-2]
      empty_rubrics += "] </b>"
      flash.now[:error] = "You did not specify all necessary rubrics: " +empty_rubrics+" of assignment <b>#{@assignment_form.assignment.name}</b> before saving the assignment. You can assign rubrics <a id='go_to_tabs2' style='color: blue;'>here</a>."
    end
  end

  def update
    ##if params doesn't have assignment_form, it means the assignment is assigned to a course using the icon on the popup menu
    unless(params.has_key?(:assignment_form))
      @assignment=Assignment.find(params[:id])
      @assignment.course_id=params[:course_id];
      if @assignment.save
        flash[:note] = 'Assignment was successfully saved.'
        redirect_to :controller => 'tree_display',:action => 'list'
      else
        flash[:error] = "Assignment save failed: #{@assignment.errors.full_messages.join(' ')}"
        redirect_to :action => 'edit', :id => @assignment.id
      end
      return
    end

    @assignment_form= AssignmentForm.create_form_object(params[:id])
    @assignment_form.assignment.instructor ||= current_user
    params[:assignment_form][:assignment][:wiki_type_id] = 1 unless params[:assignment_wiki_assignment]
    params[:assignment_form][:assignment_questionnaire].reject! do |q|
      q[:questionnaire_id].empty?
    end

    if (session[:user].timezonepref).nil?
      parent_id=session[:user].parent_id
      parent_timezone = User.find(parent_id).timezonepref
      flash[:error] = "We strongly suggest instructors specify the preferred timezone to guarantee the correct time display. For now we assume you are in " +parent_timezone
      session[:user].timezonepref=parent_timezone
    end
    if @assignment_form.update_attributes(assignment_form_params,session[:user])
        flash[:note] = 'Assignment was successfully saved.'
        #TODO: deal with submission path change
        # Need to rename the bottom-level directory and/or move intermediate directories on the path to an
        # appropriate place
        # Probably there are 2 different operations:
        #  - rename an assgt. -- implemented by renaming a directory
        #  - assigning an assignment to a course -- implemented by moving a directory.
      else
        flash[:error] = "Assignment save failed: #{@assignment_form.errors}"
    end
    redirect_to :action => 'edit', :id => @assignment_form.assignment.id
  end

  def show
    @assignment = Assignment.find(params[:id])
  end

  #--------------------------------------------------------------------------------------------------------------------
  # GET_PATH (Helper function for CREATE and UPDATE)
  #  return the file location if there is any for the assignment
  # TODO: to be depreicated
  #--------------------------------------------------------------------------------------------------------------------
  def path
    begin
      file_path = @assignment.path
    rescue
      file_path = nil
    end
    return file_path
  end

  #--------------------------------------------------------------------------------------------------------------------
  # COPY_PARTICIPANTS_FROM_COURSE
  #  if assignment and course are given copy the course participants to assignment
  # TODO: to be tested
  #--------------------------------------------------------------------------------------------------------------------
  def copy_participants_from_course
    if params[:assignment][:course_id]
      begin
        Course.find(params[:assignment][:course_id]).copy_participants(params[:id])
      rescue
        flash[:error] = $!
      end
    end
  end

  #-------------------------------------------------------------------------------------------------------------------
  # COPY
  # Creates a copy of an assignment along with dates and submission directory
  # TODO: need to be tested
  #-------------------------------------------------------------------------------------------------------------------
  def copy
    @user = ApplicationHelper::get_user_role(session[:user])
    @user = session[:user]
    session[:copy_flag] = true
    #check new assignment submission directory and old assignment submission directory
    old_assign = Assignment.find(params[:id])
    new_assign_id=AssignmentForm.copy(params[:id],@user)
    if new_assign_id
      new_assign = Assignment.find(new_assign_id)
      flash[:note] = 'Warning: The submission directory for the copy of this assignment will be the same as the submission directory for the existing assignment, which will allow student submissions to one assignment to overwrite submissions to the other assignment.  If you do not want this to happen, change the submission directory in the new copy of the assignment.' if old_assign.directory_path == new_assign.directory_path
      redirect_to :action => 'edit', :id => new_assign_id
    else
      flash[:error] = 'The assignment was not able to be copied. Please check the original assignment for missing information.'
      redirect_to :action => 'list', :controller => 'tree_display'
    end
  end

    #--------------------------------------------------------------------------------------------------------------------
    # DELETE
    # TODO: not been cleanup yep
    #--------------------------------------------------------------------------------------------------------------------
    def delete
      begin
        @assignment_form = AssignmentForm.create_form_object(params[:id])
        @user = session[:user]
        id = @user.get_instructor
        if (id != @assignment_form.assignment.instructor_id)
         raise "Not authorised to delete this assignment"
        else
         @assignment_form.delete(params[:force])
         flash[:success] = "The assignment is deleted"
      end
      rescue
          url_yes = url_for :action => 'delete', :id => params[:id], :force => 1
          url_no = url_for :action => 'delete', :id => params[:id]
          error = $!
          flash[:error] = error.to_s + " Delete this assignment anyway?&nbsp;<a href='#{url_yes}'>Yes</a>&nbsp;|&nbsp;<a href='#{url_no}'>No</a><BR/>"
      end
      redirect_to :controller => 'tree_display', :action => 'list'
    end

    def list
      set_up_display_options("ASSIGNMENT")
      @assignments=super(Assignment)
      #    @assignment_pages, @assignments = paginate :assignments, :per_page => 10
    end
    alias_method :index, :list

    def scheduled_tasks
      @suggestions = Suggestion.where(assignment_id: params[:id])
      @assignment = Assignment.find(params[:id])
    end

    def list_submissions
      @assignment = Assignment.find(params[:id])
      @teams = Team.where(parent_id: params[:id])
    end

    def associate_assignment_with_course
      @assignment = Assignment.find(params[:id])
      @assignment.inspect
      @user = ApplicationHelper::get_user_role(session[:user])
      @user = session[:user]
      @courses = @user.set_courses_to_assignment
    end

    def remove_assignment_from_course
      assignment = Assignment.find(params[:id])
      oldpath = assignment.path rescue nil
      assignment.course_id = nil
      assignment.save
      newpath = assignment.path rescue nil
      FileHelper.update_file_location(oldpath, newpath)
      redirect_to :controller => 'tree_display', :action => 'list'
    end

    def delete_scheduled_task
      @delayed_job = DelayedJob.find(params[:delayed_job_id])
      @delayed_job.delete
      redirect_to :controller => 'assignments', :action => 'scheduled_tasks', :id => params[:id]
    end

    #check whether rubrics are set before save assignment
    def empty_rubrics_list
      rubrics_list = ["ReviewQuestionnaire",
                      "MetareviewQuestionnaire","AuthorFeedbackQuestionnaire",
                      "TeammateReviewQuestionnaire","BookmarkRatingQuestionnaire"]
      @assignment_questionnaires.each do |aq|
        unless aq.questionnaire_id.nil?
          rubrics_list.reject! do |rubric| 
            rubric == Questionnaire.where(id: aq.questionnaire_id).first.type.to_s
          end
        end
      end
      if @assignment_form.assignment.max_team_size == 1
        rubrics_list.delete("TeammateReviewQuestionnaire")
      end
      unless @metareview_allowed
        rubrics_list.delete("MetareviewQuestionnaire")
      end
      unless @assignment_form.assignment.use_bookmark
        rubrics_list.delete("BookmarkRatingQuestionnaire")
      end
      return rubrics_list
    end

    private

    def assignment_form_params
      params.require(:assignment_form).permit!
    end
end
