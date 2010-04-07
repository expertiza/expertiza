class AssignmentController < ApplicationController
  require 'ftools'
  auto_complete_for :user, :name
  before_filter :authorize
  
  def copy
    Assignment.record_timestamps = false
    #creating a copy of an assignment; along with the dates and submission directory too
    old_assign = Assignment.find(params[:id])
    new_assign = old_assign.clone
    @user =  ApplicationHelper::get_user_role(session[:user])
    @user = session[:user]
    @user.set_instructor(new_assign)
    new_assign.update_attribute('name','Copy of '+new_assign.name)     
    new_assign.update_attribute('created_at',Time.now)
    new_assign.update_attribute('updated_at',Time.now)
    

    
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
      
      flash[:note] = 'Warning: The submission directory for the copy of this assignment will be the same as the submission directory for the existing assignment, which will allow student submissions to one assignment to overwrite submissions to the other assignment.  If you do not want this to happen, change the submission directory in the new copy of the assignment.'
      redirect_to :action => 'edit', :id => new_assign.id
    else
      flash[:error] = 'The assignment was not able to be copied. Please check the original assignment for missing information.'
      redirect_to :action => 'list', :controller => 'tree_display'
    end    
  end  
  
  def new
    #creating new assignment and setting default values using helper functions
    if params[:parent_id]
      @course = Course.find(params[:parent_id])           
    end    
    
    @assignment = Assignment.new
    
    @wiki_types = WikiType.find_all
    @private = params[:private] == true        
    #calling the defalut values mathods
    get_limits_and_weights 
  end
  
  
  # Toggle the access permission for this assignment from public to private, or vice versa
  def toggle_access
    assignment = Assignment.find(params[:id])
    assignment.private = !assignment.private
    assignment.save
    
    redirect_to :controller => 'tree_display', :action => 'list'
  end
  
  def create
    # The Assignment Directory field to be filled in is the path relative to the instructor's home directory (named after his user.name)
    # However, when an administrator creates an assignment, (s)he needs to preface the path with the user.name of the instructor whose assignment it is.    
    @assignment = Assignment.new(params[:assignment])    
    @user =  ApplicationHelper::get_user_role(session[:user])
    @user = session[:user]
    @user.set_instructor(@assignment) 
    @assignment.submitter_count = 0    
    ## feedback added
    ##
    
    # Deadline types used in the deadline_types DB table
    deadline = DeadlineType.find_by_name("submission")
    @Submission_deadline= deadline.id
    deadline = DeadlineType.find_by_name("review")
    @Review_deadline = deadline.id
    deadline = DeadlineType.find_by_name("resubmission")
    @Resubmission_deadline= deadline.id
    deadline = DeadlineType.find_by_name("rereview")
    @Rereview_deadline = deadline.id
    deadline = DeadlineType.find_by_name("metareview")
    @Review_of_review_deadline = deadline.id
    
    if @assignment.save 
      set_questionnaires   
      set_limits_and_weights
      
      max_round = 1
      #setting the Due Dates with a helper function written in DueDate.rb
      DueDate::set_duedate(params[:submit_deadline],@Submission_deadline, @assignment.id, max_round )
      DueDate::set_duedate(params[:review_deadline],@Review_deadline, @assignment.id, max_round )
      max_round = 2;
      
     
      if params[:assignment_helper][:no_of_reviews].to_i >= 2
        for resubmit_duedate_key in params[:additional_submit_deadline].keys
          #setting the Due Dates with a helper function written in DueDate.rb
          DueDate::set_duedate(params[:additional_submit_deadline][resubmit_duedate_key],@Resubmission_deadline, @assignment.id, max_round )
          max_round = max_round + 1
        end
        max_round = 2
        for rereview_duedate_key in params[:additional_review_deadline].keys
          #setting the Due Dates with a helper function written in DueDate.rb
          DueDate::set_duedate(params[:additional_review_deadline][rereview_duedate_key],@Rereview_deadline, @assignment.id, max_round )
          max_round = max_round + 1
        end
      end
      #setting the Due Dates with a helper function written in DueDate.rb
      @assignment.questionnaires.each{
         |questionnaire|
         if questionnaire.instance_of? MetareviewQuestionnaire
           DueDate::set_duedate(params[:reviewofreview_deadline],@Review_of_review_deadline, @assignment.id, max_round )
         end
      }
      
      
      # Create submission directory for this assignment
      # If assignment is a Wiki Assignment (or has no directory)
      # the helper will not create a path
      FileHelper.create_directory(@assignment)      
      
      # Creating node information for assignment display
      @assignment.create_node()
      
      flash[:notice] = 'Assignment was successfully created.'
      redirect_to :action => 'list', :controller => 'tree_display'
      
    else
      @wiki_types = WikiType.find_all
      render :action => 'new'
    end
    
  end
  
  def edit
    @assignment = Assignment.find(params[:id])
    get_limits_and_weights    
    @wiki_types = WikiType.find_all
  end
  
  def set_questionnaires
    @assignment.assignment_questionnaires.clear
    params[:questionnaires].each{
      | key, value |       
      if value.to_i > 0 and Questionnaire.find(value)
        @assignment.questionnaires << Questionnaire.find(value)
      end
    }     
  end   
  
  def get_limits_and_weights 
    @limits = Hash.new   
    @weights = Hash.new
    
    if session[:user].role.name == "Teaching Assistant"
      user_id = TA.get_my_instructor(session[:user]).id
    else
      user_id = session[:user].id
    end
    
    default = AssignmentQuestionnaires.find_by_user_id_and_assignment_id_and_questionnaire_id(user_id,nil,nil)   
    
    @limits[:review] = default.notification_limit
    @limits[:metareview] = default.notification_limit
    @limits[:feedback] = default.notification_limit
    @limits[:teammate] = default.notification_limit
   
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
  
  def set_limits_and_weights
    if session[:user].role.name == "Teaching Assistant"
      user_id = TA.get_my_instructor(session[:user]).id
    else
      user_id = session[:user].id
    end
    
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
  
  def update      
    if params[:assignment][:course_id]
      begin
        Course.find(params[:assignment][:course_id]).copy_participants(params[:id])
      rescue
        flash[:error] = $!
      end
    end
    @assignment = Assignment.find(params[:id])
    begin 
      oldpath = @assignment.get_path
    rescue
      oldpath = nil
    end
    # The update call below updates only the assignment table. The due dates must be updated separately.
    if @assignment.update_attributes(params[:assignment])     
      set_questionnaires
      set_limits_and_weights
      begin
        newpath = @assignment.get_path        
      rescue
        newpath = nil
      end
      if oldpath != nil and newpath != nil
        FileHelper.update_file_location(oldpath,newpath)
      end
      # Iterate over due_dates, from due_date[0] to the maximum due_date
      if params[:due_date]
        for due_date_key in params[:due_date].keys
          due_date_temp = DueDate.find(due_date_key)
          due_date_temp.update_attributes(params[:due_date][due_date_key])
        end
      end
      flash[:notice] = 'Assignment was successfully updated.'
      redirect_to :action => 'show', :id => @assignment                  
    else # Simply refresh the page
      @wiki_types = WikiType.find_all
      render :action => 'edit'
    end    
  end
  
  def show
    @assignment = Assignment.find(params[:id])
  end
  
  def delete
    assignment = Assignment.find(params[:id])
    
    # If the assignment is already deleted, go back to the list of assignments
    if assignment 
      begin
        @user =  ApplicationHelper::get_user_role(session[:user])
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
  
  def list
    set_up_display_options("ASSIGNMENT")
    @assignments=super(Assignment)
    #    @assignment_pages, @assignments = paginate :assignments, :per_page => 10
  end
  
  def associate_assignment_to_course
    @assignment = Assignment.find(params[:id])
    @user =  ApplicationHelper::get_user_role(session[:user])
    @user = session[:user]
    @courses = @user.set_courses_to_assignment
#    if session[:user].role_id != 6 # for other that TA
#      @courses = Course.find_all_by_instructor_id(session[:user].id, :order => 'name')
#    else
#      @courses = TaMapping.get_courses(session[:user].id)
#    end   
  end
  
  def remove_assignment_from_course    
    assignment = Assignment.find(params[:id])
    oldpath = assignment.get_path
    assignment.course_id = nil    
    assignment.save
    newpath = assignment.get_path
    FileHelper.update_file_location(oldpath,newpath)
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
end