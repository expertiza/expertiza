class AssignmentController < ApplicationController
  auto_complete_for :user, :name
  before_filter :authorize

  #-------------------------------------------------------------------------------------------------------------------
  # COPY
  # Creates a copy of an assignment along with dates and submission directory
  #-------------------------------------------------------------------------------------------------------------------
  def copy
    Assignment.record_timestamps = false

    old_assign = Assignment.find(params[:id])
    new_assign = old_assign.clone
    @user =  ApplicationHelper::get_user_role(session[:user])
    @user = session[:user]
    @user.set_instructor(new_assign)
    new_assign.update_attribute('name','Copy of '+ new_assign.name)
    new_assign.update_attribute('created_at',Time.now)
    new_assign.update_attribute('updated_at',Time.now)
    if new_assign.directory_path != nil
        new_assign.update_attribute('directory_path',new_assign.directory_path+'_copy')
    end
    session[:copy_flag] = true
    new_assign.copy_flag = true

    if new_assign.save
      Assignment.record_timestamps = true

      old_assign.assignment_questionnaires.each{
        | aq |
        AssignmentQuestionnaires.create(
          :assignment_id => new_assign.id,
          :questionnaire_id => aq.questionnaire_id,
          :user_id => session[:user].id,
          :notification_limit => aq.notification_limit,
          :questionnaire_weight => aq.questionnaire_weight
        )
      }      
      
      DueDate.copy(old_assign.id, new_assign.id)           
      new_assign.create_node()
      
      flash[:note] = 'A PATCH HAS BEEN APPLIED FOR THE FOLLOWING WARNING, PLEASE REPORT ANY ISSUES --> Warning: The submission directory for the copy of this assignment will be the same as the submission directory for the existing assignment, which will allow student submissions to one assignment to overwrite submissions to the other assignment.  If you do not want this to happen, change the submission directory in the new copy of the assignment.'
      redirect_to :action => 'edit', :id => new_assign.id
    else
      flash[:error] = 'The assignment was not able to be copied. Please check the original assignment for missing information.'
      redirect_to :action => 'list', :controller => 'tree_display'
    end    
  end

  #--------------------------------------------------------------------------------------------------------------------
  # NEW
  # Creates new assignment and sets default values using helper functions
  #--------------------------------------------------------------------------------------------------------------------
  def new
    #creating
    if params[:parent_id]
      @course = Course.find(params[:parent_id])           
    end    
    
    @assignment = Assignment.new
    
    @wiki_types = WikiType.find(:all)
    @private = params[:private] == true        
    #calling the defalut values mathods
    get_limits_and_weights 
  end

  #--------------------------------------------------------------------------------------------------------------------
  #  CREATE
  #  Populates new assignment
  #
  #  Note:
  #  The Assignment Directory field to be filled in is the path relative to the instructor's
  #  home directory (named after his user.name). However, when an administrator creates an assignment,
  # (s)he needs to preface the path with the user.name of the instructor whose assignment it is.
  #--------------------------------------------------------------------------------------------------------------------
  
  def create
    @assignment = Assignment.new(params[:assignment])    
    @user =  ApplicationHelper::get_user_role(session[:user])
    @user = session[:user]
    @user.set_instructor(@assignment) 
    @assignment.submitter_count = 0

    #Calculate days between submissions
    set_days_btw_sub

    if @assignment.save
      set_questionnaires
      set_limits_and_weights

      begin

        #Create and set due dates (Raise error if problem)
        ddset = set_due_dates
        raise ddset if (ddset != "")
               
        # Create submission directory for this assignment
        # If assignment is a Wiki Assignment (or has no directory) the helper will not create a path
        FileHelper.create_directory(@assignment)      
        
        # Creating node information for assignment display
        @assignment.create_node()
        
        #Alert that there is an assignment with same name (Assignment is still created - this is just a nicety)
        flash[:alert] = "There is already an assignment named \"#{@assignment.name}\". &nbsp;<a style='color: blue;' href='../../assignment/edit/#{@assignment.id}'>Edit assignment</a>" if @assignment.duplicate_name?

        #Notify Assignment created
        flash[:note] = 'Assignment was successfully created.'
        redirect_to :action => 'list', :controller => 'tree_display'

      rescue
        flash[:error] = $!
        prepare_to_edit
        @wiki_types = WikiType.find(:all)
        @private = params[:private] == true
        render :action => 'new'
      end
      
    else
      get_limits_and_weights
      @wiki_types = WikiType.find(:all)
      @private = params[:private] == true
      render :action => 'new'
    end
    
  end

  #---------------------------------------------------------------------------------------------------------------------
  #  SET_DUE_DATES  (Helper function for CREATE)
  #   Creates and sets review deadlines using a helper function written in DueDate.rb
  #---------------------------------------------------------------------------------------------------------------------

  def set_due_dates
    # Deadline types used in the deadline_types DB table
    @Submission_deadline = DeadlineType.find_by_name("submission").id
    @Review_deadline = DeadlineType.find_by_name("review").id
    @Resubmission_deadline = DeadlineType.find_by_name("resubmission").id
    @Rereview_deadline = DeadlineType.find_by_name("rereview").id
    @Review_of_review_deadline = DeadlineType.find_by_name("metareview").id
    @drop_topic_deadline = DeadlineType.find_by_name("drop_topic").id

    max_round = 1

    #Submission Deadline
    due_date = DueDate::set_duedate(params[:submit_deadline],@Submission_deadline, @assignment.id, max_round )
    return "Please enter a valid Submission deadline" if !due_date

    #Review Deadline
    due_date = DueDate::set_duedate(params[:review_deadline],@Review_deadline, @assignment.id, max_round )
    return "Please enter a valid Review deadline" if !due_date
    max_round = 2

    #Drop Topic Deadline
    due_date = DueDate::set_duedate(params[:drop_topic_deadline],@drop_topic_deadline, @assignment.id, 0)
    return "Please enter a valid drop topic deadline" if !due_date

    if params[:assignment_helper][:no_of_reviews].to_i >= 2

      #Resubmission Deadlines
      for resubmit_duedate_key in params[:additional_submit_deadline].keys
        due_date = DueDate::set_duedate(params[:additional_submit_deadline][resubmit_duedate_key],@Resubmission_deadline, @assignment.id, max_round )
        return "Please enter a valid Resubmission deadline" if !due_date
        max_round = max_round + 1
      end
      max_round = 2

      #ReReview Deadlines
      for rereview_duedate_key in params[:additional_review_deadline].keys
        due_date = DueDate::set_duedate(params[:additional_review_deadline][rereview_duedate_key],@Rereview_deadline, @assignment.id, max_round )
        return "Please enter a valid Rereview deadline" if !due_date
        max_round = max_round + 1
      end
    end

    #Metareview Deadlines
    @assignment.questionnaires.each{
        |questionnaire|
      if questionnaire.instance_of? MetareviewQuestionnaire
        due_date = DueDate::set_duedate(params[:reviewofreview_deadline],@Review_of_review_deadline, @assignment.id, max_round )
        return "Please enter a valid Metareview deadline" if !due_date
      end
    }

    return ""

  end

  #---------------------------------------------------------------------------------------------------------------------
  #  SET_DAYS_BTW_SUB  (Helper function for CREATE and UPDATE)
  #   Sets days between submissions for staggered assignments
  #---------------------------------------------------------------------------------------------------------------------
  def set_days_btw_sub

    if params[:days].nil? && params[:weeks].nil?
      @days = 0
      @weeks = 0
    elsif params[:days].nil?
      @days = 0
    elsif params[:weeks].nil?
      @weeks = 0
    else
      @days = params[:days].to_i
      @weeks = params[:weeks].to_i
    end


    @assignment.days_between_submissions = @days + (@weeks*7)
  end

  #--------------------------------------------------------------------------------------------------------------------
  # EDIT
  # Edit existing assignment
  #--------------------------------------------------------------------------------------------------------------------
  def edit
    @assignment = Assignment.find(params[:id])
    prepare_to_edit
  end
  
  #--------------------------------------------------------------------------------------------------------------------
  # PREPARE_TO_EDIT  (Helper function for CREATE, EDIT and UPDATE)
  # Prepare to edit existing assignment
  #--------------------------------------------------------------------------------------------------------------------
  def prepare_to_edit
    if !@assignment.days_between_submissions.nil?
      @weeks = @assignment.days_between_submissions/7
      @days = @assignment.days_between_submissions - @weeks*7
    else
      @weeks = 0
      @days = 0
    end

    get_limits_and_weights    
    @wiki_types = WikiType.find(:all)
  end

  #--------------------------------------------------------------------------------------------------------------------
  # SET_QUESTIONNAIRES  (Helper function for CREATE and UPDATE)
  #  Create array of questionnaires for assignment
  #--------------------------------------------------------------------------------------------------------------------
  def set_questionnaires
    @assignment.questionnaires = Array.new
    params[:questionnaires].each{
      | key, value |       
      if value.to_i > 0 and (q = Questionnaire.find(value))
        @assignment.questionnaires << q
     end
    }     
  end

  #--------------------------------------------------------------------------------------------------------------------
  # GET_LIMITS_AND_WEIGHTS  (Helper function for CREATE, NEW, and PREPARE_TO_EDIT)
  #  Set default limits and weights
  #--------------------------------------------------------------------------------------------------------------------
  def get_limits_and_weights 
    @limits = Hash.new   
    @weights = Hash.new

    user_id = (session[:user].role.name == "Teaching Assistant") ? TA.get_my_instructor(session[:user]).id : session[:user].id

    default = AssignmentQuestionnaires.find_by_user_id_and_assignment_id_and_questionnaire_id(user_id,nil,nil)

    default_limit_value = default.nil? ? 15 : default.notification_limit

    @limits[:review]     = default_limit_value
    @limits[:metareview] = default_limit_value
    @limits[:feedback]   = default_limit_value
    @limits[:teammate]   = default_limit_value
   
    @weights[:review] = 100
    @weights[:metareview] = 0
    @weights[:feedback] = 0
    @weights[:teammate] = 0    
    
    @assignment.questionnaires.each{
      | questionnaire |
      aq = AssignmentQuestionnaires.find_by_assignment_id_and_questionnaire_id(@assignment.id, questionnaire.id)
      @limits[questionnaire.symbol] = aq.notification_limit   
      @weights[questionnaire.symbol] = aq.questionnaire_weight
    }             
  end


  #--------------------------------------------------------------------------------------------------------------------
  # SET_LIMITS_AND_WEIGHTS  (Helper function for CREATE and UPDATE)
  #  Get default limits and weights
  #--------------------------------------------------------------------------------------------------------------------
  def set_limits_and_weights

    user_id = (session[:user].role.name == "Teaching Assistant") ? TA.get_my_instructor(session[:user]).id : session[:user].id
    
    default = AssignmentQuestionnaires.find_by_user_id_and_assignment_id_and_questionnaire_id(user_id,nil,nil) 
    
    @assignment.questionnaires.each{
      | questionnaire |
      aq = AssignmentQuestionnaires.find_by_assignment_id_and_questionnaire_id(@assignment.id, questionnaire.id)
      if params[:limits][questionnaire.symbol].length > 0
        aq.update_attribute('notification_limit',params[:limits][questionnaire.symbol])
      else
        aq.update_attribute('notification_limit',default.notification_limit)
      end
      aq.update_attribute('questionnaire_weight',params[:weights][questionnaire.symbol])
      aq.update_attribute('user_id',user_id)
    }
  end

  #--------------------------------------------------------------------------------------------------------------------
  # GET_PATH (Helper function for CREATE and UPDATE)
  #  return the file location if there is any for the assignment
  #--------------------------------------------------------------------------------------------------------------------
  def get_path
    begin
      file_path = @assignment.get_path
    rescue
      file_path = nil
    end
    return file_path
  end

  #--------------------------------------------------------------------------------------------------------------------
  # COPY_PARTICIPANTS_FROM_COURSE
  #  if assignment and course are given copy the course participants to assignment
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

  #--------------------------------------------------------------------------------------------------------------------
  # UPDATE
  #  make updates to assignment
  #--------------------------------------------------------------------------------------------------------------------
  def update
    #if course is given, find course participants
    copy_participants_from_course
    #find the assignment by id
    @assignment = Assignment.find(params[:id])
    #get file old location
    oldpath = get_path

    #Calculate days between submissions
    set_days_btw_sub

    # The update call below updates only the assignment table. The due dates must be updated separately.
    if @assignment.update_attributes(params[:assignment])
      if params[:questionnaires] and params[:limits] and params[:weights]
        set_questionnaires
        set_limits_and_weights
      end

      # Following modified by Sterling Alexander
      #
      # Added flag to each assignment.  When an assignment is copied, the flag will be "true",
      #   a new directory will be created and the old directory will be conserved with it's files intact.

      # puts session[:copy_flag].to_s + " <--- Value of session_flag as a string"
      newpath = get_path
      if session[:copy_flag] == false
        if oldpath != nil and newpath != nil
          FileHelper.update_file_location(oldpath,newpath)
        end
      else
        FileHelper.create_directory_from_path(newpath)
        session[:copy_flag] = false
      end
      #update due dates
      begin
        # Iterate over due_dates, from due_date[0] to the maximum due_date
        if params[:due_date]
          for due_date_key in params[:due_date].keys
            due_date_temp = DueDate.find(due_date_key)
            due_date_temp.update_attributes(params[:due_date][due_date_key])
            type = DeadlineType.find_by_id(due_date_temp.deadline_type_id).name.capitalize
            raise "Please enter a valid #{type} deadline" if due_date_temp.errors.length > 0
          end
        end

        flash[:notice] = 'Assignment was successfully updated.'
        redirect_to :action => 'show', :id => @assignment

      rescue
        flash[:error] = $!
        prepare_to_edit
        render :action => 'edit', :id => @assignment
      end
    else # Simply refresh the page
      @wiki_types = WikiType.find(:all)
      render :action => 'edit'
    end
  end

  #--------------------------------------------------------------------------------------------------------------------
  # SHOW
  #
  #--------------------------------------------------------------------------------------------------------------------
  def show
    @assignment = Assignment.find(params[:id])
  end
  
  #--------------------------------------------------------------------------------------------------------------------
  # DELETE
  #  delete assignment
  #--------------------------------------------------------------------------------------------------------------------
  def delete
    assignment = Assignment.find(params[:id])
    
    # If the assignment is already deleted, go back to the list of assignments
    if assignment 
      begin
        @user = session[:user]
        id = @user.get_instructor
        if(id != assignment.instructor_id)
          raise "Not authorised to delete this assignment"
        end
        assignment.delete(params[:force])
        @a = Node.find(:first, :conditions => ['node_object_id = ? and type = ?',params[:id],'AssignmentNode'])
     
        @a.destroy
        flash[:notice] = "The assignment is deleted"
      rescue
        url_yes = url_for :action => 'delete', :id => params[:id], :force => 1
        url_no  = url_for :action => 'delete', :id => params[:id]
        error = $!
        flash[:error] = error.to_s + " Delete this assignment anyway?&nbsp;<a href='#{url_yes}'>Yes</a>&nbsp;|&nbsp;<a href='#{url_no}'>No</a><BR/>"
      end
    end
    
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  #--------------------------------------------------------------------------------------------------------------------
  # LIST
  #
  #--------------------------------------------------------------------------------------------------------------------
  def list
    set_up_display_options("ASSIGNMENT")
    @assignments=super(Assignment)
    #    @assignment_pages, @assignments = paginate :assignments, :per_page => 10
  end

  #--------------------------------------------------------------------------------------------------------------------
  # TOGGLE_ACCESS
  #  Toggle the access permission for this assignment from public to private, or vice versa
  #--------------------------------------------------------------------------------------------------------------------
  def toggle_access
    assignment = Assignment.find(params[:id])
    assignment.private = !assignment.private
    assignment.save

    redirect_to :controller => 'tree_display', :action => 'list'
  end

  #--------------------------------------------------------------------------------------------------------------------
  # DEFINE_INSTRUCTOR_NOTIFICATION_LIMIT
  #  !!!NO usages found
  #--------------------------------------------------------------------------------------------------------------------
  def define_instructor_notification_limit(assignment_id, questionnaire_id, limit)
    existing = NotificationLimit.find(:first, :conditions => ['user_id = ? and assignment_id = ? and questionnaire_id = ?',session[:user].id,assignment_id,questionnaire_id])
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

  #--------------------------------------------------------------------------------------------------------------------
  # ASSOCIATE_ASSIGNMENT_TO_COURSE
  #  !!!NO usages found
  #--------------------------------------------------------------------------------------------------------------------
  def associate_assignment_to_course
    @assignment = Assignment.find(params[:id])
    @user =  ApplicationHelper::get_user_role(session[:user])
    @user = session[:user]
    @courses = @user.set_courses_to_assignment
  end

  #--------------------------------------------------------------------------------------------------------------------
  # REMOVE_ASSIGNMENT_FROM_COURSE
  #  !!!NO usages found
  #--------------------------------------------------------------------------------------------------------------------
  def remove_assignment_from_course
    assignment = Assignment.find(params[:id])
    oldpath = assignment.get_path rescue nil
    assignment.course_id = nil
    assignment.save
    newpath = assignment.get_path rescue nil
    FileHelper.update_file_location(oldpath,newpath)
    redirect_to :controller => 'tree_display', :action => 'list'
  end

end