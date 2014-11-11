class AssignmentController < ApplicationController
  auto_complete_for :user, :name
  before_filter :authorize

  # change access permission from public to private or vice versa
  def toggle_access
    assignment = Assignment.find(params[:id])
    assignment.private = !assignment.private
    assignment.save
    redirect_to :controller => 'tree_display', :action => 'list'
  end

  def new
    @assignment = Assignment.new
    @assignment.course = Course.find(params[:parent_id]) unless params[:parent_id].nil?

    if @assignment.course.nil?
      @assignment.instructor = session[:user]
    else
      @assignment.instructor = @assignment.course.instructor
    end

    @assignment.wiki_type_id = 1 #default no wiki type
  end

  def load_redis
    rf1 = ScoreCache.find(:first, :conditions => ["reviewee_id = ? and object_type = ?", params[:id], "Threshold"])
    if rf1 == nil
      rf1 = ScoreCache.new
    end
    rf1.reviewee_id = params[:id]
    rf1.range = "nothing"
    if params[:assigned][:thresh]
      rf1.score = params[:assigned][:thresh]
    else
      rf1.score = 20
    end
    rf1.object_type="Threshold"
    rf1.save

    rf2 = ScoreCache.find(:first, :conditions => ["reviewee_id = ? and object_type = ?", params[:id], "RedisFactor"])
    if rf2 == nil
      rf2 = ScoreCache.new
    end
    rf2.reviewee_id = params[:id]
    rf2.range= "nothing"

    if params[:assigned][:rfactor]
      rf2.score = params[:assigned][:rfactor]
    else
      rf2.score = 1
    end

    rf2.object_type="RedisFactor"
    rf2.save

    rf3 = ScoreCache.find(:first, :conditions => ["reviewee_id = ? and object_type = ?", params[:id], "MaxDeduct"])
    if rf3 == nil
      rf3 = ScoreCache.new
    end
    rf3.reviewee_id = params[:id]
    rf3.range= "nothing"
    if params[:assigned][:mdp]
      rf3.score = params[:assigned][:mdp]
    else
      rf3.score = 20
    end
    rf3.object_type="MaxDeduct"
    rf3.save

    rf4 = ScoreCache.find(:first, :conditions => ["reviewee_id = ? and object_type = ?", params[:id], "IfClass"])
    if rf4 == nil
      rf4 = ScoreCache.new
    end
    rf4.reviewee_id = params[:id]
    rf4.range= "nothing"
    if params[:assigned][:ifclass] == true
      rf4.score = 1
    elsif params[:assigned][:ifclass] == false
      rf4.score = 0
    else
      rf4.score = 0
    end
    rf4.object_type="IfClass"
    rf4.save

    rf5 = ScoreCache.find(:first, :conditions => ["reviewee_id = ? and object_type = ?", params[:id], "HardLine"])
    if rf5 == nil
      rf5 = ScoreCache.new
    end
    rf5.reviewee_id = params[:id]
    rf5.range= "nothing"
    if params[:assigned][:hardline]
      rf5.score = params[:assigned][:hardline]
    else
      rf5.score = 85
    end
    rf5.object_type="HardLine"
    rf5.save

  end



  def create
    params[:assignment][:max_team_size] ||= 1
    # E726 Fall2012 Changes Begin
        # Code for adding rubrics if option selected in the form was "Same as Review Rubric"
        if(params[:selfreview_checkbox] == "selfreview_checkbox")
                 params[:questionnaires][:selfreview] = params[:questionnaires][:review]
                 params[:weights][:selfreview] = params[:weights][:review]
                 params[:limits][:selfreview] = params[:limits][:review]
               end
       if(params[:managerreview_checkbox] == "managerreview_checkbox")
                 params[:questionnaires][:managerreview] = params[:questionnaires][:review]
                 params[:weights][:managerreview] = params[:weights][:review]
                 params[:limits][:managerreview] = params[:limits][:review]
               end
       if(params[:readerreview_checkbox] == "readerreview_checkbox")
                 params[:questionnaires][:readerreview] = params[:questionnaires][:review]
                 params[:weights][:readerreview] = params[:weights][:review]
                 params[:limits][:readerreview] = params[:limits][:review]
               end
        # E726 Fall2012 Changes End
    @assignment = Assignment.new(params[:assignment])

    if @assignment.save
      @assignment.create_node
      flash[:note] = 'Assignment was successfully created.'
      flash[:alert] = "There is already an assignment named #{@assignment.name}" if @assignment.duplicate_name?
      redirect_to :action => 'edit', :id => @assignment.id
    else
      render :action => 'new'
    end
  end

  def edit
    @assignment = Assignment.find(params[:id])
    @assignment_questionnaires = AssignmentQuestionnaire.find_all_by_assignment_id(params[:id])
    @due_date_all = DueDate.find_all_by_assignment_id(params[:id])
    @reviewvarycheck = nil
    @newsetroundnum = 2
    @due_date_nameurl_notempty = "null"
    @due_date_nameurl_notempty_checkbox = false
    @review_check = nil
    @metareview_check= nil
    @author_check = nil
    @teammate_check = nil

    # Add by Xiaoqiang Shao, check if name and url in database is empty before webpage displays
    @due_date_all.each do |dd|
      if(!(dd.deadline_name.nil?))
      if(dd.deadline_name.length>=1)
        @due_date_nameurl_notempty = 1
        @due_date_nameurl_notempty_checkbox = true
      end
      end
      if(!(dd.description_url.nil?))
      if(dd.description_url.length>=1)
        @due_date_nameurl_notempty = 1
        @due_date_nameurl_notempty_checkbox = true
      end
      end
    end
    @assignment_questionnaires.each do  |aq|
      if(!(aq.used_in_round.nil?))
        @reviewvarycheck = 1
        @q_id = aq.questionnaire_id
        @qn = Questionnaire.find(@q_id)

        if(@qn.display_type.eql?"Review")
          @review_check = 1
        elsif(@qn.display_type.eql?"Metareview")
          @metareview_check=1
        elsif(@qn.display_type.eql?"Author Feedback")
          @author_check = 1
        elsif(@qn.display_type.eql?"Teammate Review")
          @teammate_check = 1
        end
      end
    end
    set_up
  end

  def delete_all_due_dates
    if params[:assignment_id].nil?
      return 
    end

    assignment = Assignment.find(params[:assignment_id])
    if assignment.nil?
      return 
    end

    @due_dates = DueDate.find_all_by_assignment_id(params[:assignment_id])
    @due_dates.each do |due_date|
      due_date.delete
    end

    respond_to do |format|
      format.json { render :json => @due_dates }
    end
  end



  def set_due_date
    if params[:due_date][:assignment_id].nil?
      return 
    end

    assignment = Assignment.find(params[:due_date][:assignment_id])
    if assignment.nil?
      return 
    end

    due_at = DateTime.parse(params[:due_date][:due_at])
    if due_at.nil?
      return 
    end

    @due_date = DueDate.new(params[:due_date])
    @due_date.save

    # 2014.10.28 Not successful
    @assignment_questionnaire=AssignmentQuestionnaire.new({"assignment_id"=>params[:due_date][:assignment_id],"questionnaire_id"=>params[:due_date][:questionnaire_id]})
    @assignment_questionnaire.save
    respond_to do |format|
      format.json { render :json => @due_date }
      format.json { render :json => @assignment_questionnaire }
    end
  end



  def delete_all_questionnaires
    assignment = Assignment.find(params[:assignment_id])
    if assignment.nil?
      return
    end

    @assignment_questionnaires = AssignmentQuestionnaire.find_all_by_assignment_id(params[:assignment_id])
    @assignment_questionnaires.each do |assignment_questionnaire|
      assignment_questionnaire.delete
    end

    respond_to do |format|
      format.json { render :json => @assignment_questionnaires }
    end
  end

  def set_questionnaire
    if params[:assignment_questionnaire][:assignment_id].nil? or params[:assignment_questionnaire][:questionnaire_id].nil?
      return
    end

    assignment = Assignment.find(params[:assignment_questionnaire][:assignment_id])
    if assignment.nil?
      return
    end

    questionnaire = Questionnaire.find(params[:assignment_questionnaire][:questionnaire_id])
    if questionnaire.nil?
      return 
    end

    @assignment_questionnaire = AssignmentQuestionnaire.new(params[:assignment_questionnaire])
    @assignment_questionnaire.save

    respond_to do |format|
      format.json { render :json => @assignment_questionnaire }
    end
  end


  def update
    @assignment = Assignment.find(params[:id])
    params[:assignment][:wiki_type_id] = 1 unless params[:assignment_wiki_assignment]
    @assignment_questionnaires = AssignmentQuestionnaire.find_all_by_assignment_id(params[:id])

    #TODO: require params[:assignment][:directory_path] to be not null
    #TODO: insert warning if directory_path is duplicated
    load_redis
    if @assignment.update_attributes(params[:assignment])
      flash[:note] = 'Assignment was successfully saved.'
      #TODO: deal with submission path change
      # Need to rename the bottom-level directory and/or move intermediate directories on the path to an
      # appropriate place
      # Probably there are 2 different operations:
      #  - rename an assgt. -- implemented by renaming a directory
      #  - assigning an assignment to a course -- implemented by moving a directory.

      redirect_to :action => 'edit', :id => @assignment.id
    else
      flash[:note] = 'Assignment save failed.'
      redirect_to :action => 'edit', :id => @assignment.id
    end


    #respond_to do |format|
    #  format.json { render :json => params }
    #end
  end

  def show
    @assignment = Assignment.find(params[:id])
  end


#NOTE: many of these functions actually belongs to other models
#====setup methods for new and edit method=====#
  def set_up
    set_up_defaults

  #  submissions = @assignment.find_due_dates('submission') + @assignment.find_due_dates('resubmission')
  #  reviews = @assignment.find_due_dates('review') + @assignment.find_due_dates('rereview')
  #  @assignment.rounds_of_reviews = [@assignment.rounds_of_reviews, submissions.count, reviews.count].max

    if @assignment.directory_path.try :empty?
      @assignment.directory_path = nil
    end

    #drop_topic_deadine = @assignment.find_due_dates('drop_topic')
    #signup_deadline = @assignment.find_due_dates('signup')
    #sign_ups = SignUpTopic.find_all_by_assignment_id(@assignment.id)
    #@assignment.require_signup = !(drop_topic_deadine + signup_deadline + sign_ups).empty?
  end

  #NOTE: unfortunately this method is needed due to bad data in db @_@
  def set_up_defaults
    if @assignment.require_signup.nil?
      @assignment.require_signup = false
    end
    if @assignment.wiki_type.nil?
      @assignment.wiki_type = WikiType.find_by_name('No')
    end
    if @assignment.staggered_deadline.nil?
      @assignment.staggered_deadline = false
      @assignment.days_between_submissions = 0
    end
    if @assignment.availability_flag.nil?
      @assignment.availability_flag = false
    end
    if @assignment.microtask.nil?
      @assignment.microtask = false
    end
    if @assignment.reviews_visible_to_all.nil?
      @assignment.reviews_visible_to_all = false
    end
    if @assignment.review_assignment_strategy.nil?
      @assignment.review_assignment_strategy = ''
    end
  end


  #====== old stuff =====#
  # this function finds all the due_dates for a given assignment and calculates the time when the reminder for these deadlines needs to be sent. Enqueues them in the delayed_jobs table
  def add_to_delayed_queue
    duedates = DueDate::find_all_by_assignment_id(@assignment.id)
    for i in (0 .. duedates.length-1)
      deadline_type = DeadlineType.find(duedates[i].deadline_type_id).name
      due_at = duedates[i].due_at(:db).to_s
      Time.parse(due_at)
      due_at= Time.parse(due_at)
      mi=find_min_from_now(due_at)
      diff = mi-(duedates[i].threshold)*60
      dj=Delayed::Job.enqueue(DelayedMailer.new(@assignment.id, deadline_type, duedates[i].due_at(:db).to_s), 1, diff.minutes.from_now)
      duedates[i].update_attribute(:delayed_job_id, dj.id)
    end
  end

  # Deletes the job with id equal to "delayed_job_id" from the delayed_jobs queue
  def delete_from_delayed_queue(delayed_job_id)
    dj=Delayed::Job.find(delayed_job_id)
    if (dj != nil && dj.id != nil)
      dj.delete
    end
  end

  #--------------------------------------------------------------------------------------------------------------------
  # GET_PATH (Helper function for CREATE and UPDATE)
  #  return the file location if there is any for the assignment
  # TODO: to be depreicated
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
    Assignment.record_timestamps = false
    old_assign = Assignment.find(params[:id])
    new_assign = old_assign.clone
    @user = ApplicationHelper::get_user_role(session[:user])
    @user = session[:user]
    @user.set_instructor(new_assign)
    new_assign.update_attribute('name', 'Copy of ' + new_assign.name)
    new_assign.update_attribute('created_at', Time.now)
    new_assign.update_attribute('updated_at', Time.now)

    if new_assign.directory_path.present?
      new_assign.update_attribute('directory_path', new_assign.directory_path + '_copy')
    end

    session[:copy_flag] = true
    new_assign.copy_flag = true

    if new_assign.save
      Assignment.record_timestamps = true

      old_assign.assignment_questionnaires.each do |aq|
        AssignmentQuestionnaire.create(
            :assignment_id => new_assign.id,
            :questionnaire_id => aq.questionnaire_id,
            :user_id => session[:user].id,
            :notification_limit => aq.notification_limit,
            :questionnaire_weight => aq.questionnaire_weight
        )
      end

      DueDate.copy(old_assign.id, new_assign.id)
      new_assign.create_node()

      flash[:note] = 'Warning: The submission directory for the copy of this assignment will be the same as the submission directory for the existing assignment, which will allow student submissions to one assignment to overwrite submissions to the other assignment.  If you do not want this to happen, change the submission directory in the new copy of the assignment.'

      redirect_to :action => 'edit', :id => new_assign.id
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
    assignment = Assignment.find(params[:id])

    # If the assignment is already deleted, go back to the list of assignments
    if assignment
      begin
        #delete from delayed_jobs queue
        djobs = Delayed::Job.find(:all, :conditions => ['handler LIKE "%assignment_id: ?%"', assignment.id])
        for dj in djobs
          delete_from_delayed_queue(dj.id)
        end

        @user = session[:user]
        id = @user.get_instructor
        if (id != assignment.instructor_id)
          raise "Not authorised to delete this assignment"
        end
        assignment.delete(params[:force])
        @a = Node.find(:first, :conditions => ['node_object_id = ? and type = ?', params[:id], 'AssignmentNode'])

        @a.destroy
        flash[:notice] = "The assignment is deleted"
      rescue
        url_yes = url_for :action => 'delete', :id => params[:id], :force => 1
        url_no = url_for :action => 'delete', :id => params[:id]
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


  #--------------------------------------------------------------------------------------------------------------------
  # DEFINE_INSTRUCTOR_NOTIFICATION_LIMIT
  # TODO: NO usages found need verification
  #--------------------------------------------------------------------------------------------------------------------
  def define_instructor_notification_limit(assignment_id, questionnaire_id, limit)
    existing = NotificationLimit.find(:first, :conditions => ['user_id = ? and assignment_id = ? and questionnaire_id = ?', session[:user].id, assignment_id, questionnaire_id])
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

  def associate_assignment_to_course
    puts '>>>>' + params[:id].to_s
    @assignment = Assignment.find(params[:id])
    @assignment.inspect
    @user = ApplicationHelper::get_user_role(session[:user])
    @user = session[:user]
    @courses = @user.set_courses_to_assignment
  end

  def remove_assignment_from_course
    assignment = Assignment.find(params[:id])
    oldpath = assignment.get_path rescue nil
    assignment.course_id = nil
    assignment.save
    newpath = assignment.get_path rescue nil
    FileHelper.update_file_location(oldpath, newpath)
    redirect_to :controller => 'tree_display', :action => 'list'
  end

end
