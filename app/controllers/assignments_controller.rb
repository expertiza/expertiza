class AssignmentsController < ApplicationController
  autocomplete :user, :name
  before_filter :authorize

  def action_allowed?
    ['Super-Administrator',
     'Administrator',
     'Instructor',
     'Teaching Assistant'].include? current_role_name
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
    @assignment_form = AssignmentForm.new(params[:assignment_form])
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
    @assignment_form = AssignmentForm.create_form_object(params[:id])
    @user = current_user

    @assignment_questionnaires = AssignmentQuestionnaire::where(assignment_id: params[:id])
    @due_date_all = DueDate::where(assignment_id: params[:id])
    @reviewvarycheck = false
    @due_date_nameurl_notempty = false
    @due_date_nameurl_notempty_checkbox = false

    # Check if name and url in database is empty before webpage displays
    @due_date_all.each do |dd|
      if((!dd.deadline_name.nil?&&!dd.deadline_name.empty?)||(!dd.description_url.nil?&&!dd.description_url.empty?))
        @due_date_nameurl_notempty = true
        @due_date_nameurl_notempty_checkbox = true
        break
      end
      if dd.due_at.present?
          dd.due_at = dd.due_at.to_s.in_time_zone(session[:user].timezonepref)
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
    #TODO: require params[:assignment][:directory_path] to be not null
    #TODO: insert warning if directory_path is duplicated
    if @assignment_form.update_attributes(params[:assignment_form],session[:user])
        flash[:note] = 'Assignment was successfully saved.'
        #TODO: deal with submission path change
        # Need to rename the bottom-level directory and/or move intermediate directories on the path to an
        # appropriate place
        # Probably there are 2 different operations:
        #  - rename an assgt. -- implemented by renaming a directory
        #  - assigning an assignment to a course -- implemented by moving a directory.
      else
        flash[:error] = "Assignment save failed: #{@assignment_form.errors.full_messages.join(' ')}"
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
    new_assign_id=AssignmentForm.copy(params[:id],@user)
    if !new_assign_id.nil?
      flash[:note] = 'Warning: The submission directory for the copy of this assignment will be the same as the submission directory for the existing assignment, which will allow student submissions to one assignment to overwrite submissions to the other assignment.  If you do not want this to happen, change the submission directory in the new copy of the assignment.'
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
         flash[:notice] = "The assignment is deleted"
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


    #--------------------------------------------------------------------------------------------------------------------
    # DEFINE_INSTRUCTOR_NOTIFICATION_LIMIT
    # TODO: NO usages found need verification
    #--------------------------------------------------------------------------------------------------------------------
    def define_instructor_notification_limit(assignment_id, questionnaire_id, limit)
      existing = NotificationLimit.where(['user_id = ? and assignment_id = ? and questionnaire_id = ?', session[:user].id, assignment_id, questionnaire_id])
      if existing.nil?
        NotificationLimit.create(:user_id => session[:user].id,
                                 :assignment_id => assignment_id,
                                 :questionnaire_id => questionnaire_id,
                                 :limit => limit)
      else
        existing.limit = limit
        existing.save
      end
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

end
