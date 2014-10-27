class AssignmentController < ApplicationController
  autocomplete :user, :name
  before_filter :authorize
  #-------------------------------------------------------------------------------------------------------------------
  # COPY
  # Creates a copy of an assignment along with dates and submission directory
  #-------------------------------------------------------------------------------------------------------------------
  def copy
    Assignment.record_timestamps = false
    old_assign = Assignment.find(params[:id])
    @assignment = old_assign.clone
    @user =  ApplicationHelper::get_user_role(session[:user])
    @user = session[:user]
    @user.set_instructor(@assignment)
    @assignment.name = 'Copy of ' + @assignment.name
    @assignment.created_at = Time.now
    @assignment.updated_at = Time.now
    if @assignment.directory_path.present?
      @assignment.directory_path = @assignment.directory_path + '_copy'
    end
    session[:copy_flag] = true
    @assignment.copy_flag = true

    if @assignment.save
      Assignment.record_timestamps = true

      old_assign.assignment_questionnaires.each do |aq|
        AssignmentQuestionnaire.create(
          :assignment_id => @assignment.id,
          :questionnaire_id => aq.questionnaire_id,
          :user_id => session[:user].id,
          :notification_limit => aq.notification_limit,
          :questionnaire_weight => aq.questionnaire_weight
        )
      end

      DueDate.copy(old_assign.id, @assignment.id)
      @assignment.create_node()

      undo_link("Copy of \"#{old_assign.name}\" has been created successfully and named\"#{@assignment.name}\". Warning: The submission directory for the copy of this assignment will be the same as the submission directory for the existing assignment, which will allow student submissions to one assignment to overwrite submissions to the other assignment.  If you do not want this to happen, change the submission directory in the new copy of the assignment. ")
      redirect_to :action => 'edit', :id => @assignment.id
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

      @wiki_types = WikiType.all
      @private = params[:private] == true
      #calling the defalut values mathods
      get_limits_and_weights
      if (session[:user].role.name == "Administrator") or (session[:user].role.name == "Super-Administrator")
        flash[:note] = "Note: The Submission Directory field to be filled in is the path relative to the instructor\'s
        home directory (named after his user.name). However, when an administrator creates an assignment,
          (s)he needs to preface the path with the user.name of the instructor whose assignment it is."
        end
    end


    # Toggle the access permission for this assignment from public to private, or vice versa
    def toggle_access
      assignment = Assignment.find(params[:id])
      assignment.private = !assignment.private
      assignment.save

      redirect_to :controller => 'tree_display', :action => 'list'
    end

    # This functions finds the epoch time in seconds of the due_at parameter and finds the difference of it
    # from the current time and returns this difference in minutes
    def find_min_from_now(due_at)

      curr_time=DateTime.now.to_s(:db)
      curr_time=Time.parse(curr_time)
      time_in_min=((due_at - curr_time).to_i/60)
      return time_in_min
    end
    # Deletes the job with id equal to "delayed_job_id" from the delayed_jobs queue
    def delete_from_delayed_queue (delayed_job_id)
      dj=Delayed::Job.find(delayed_job_id)
      if (dj != nil && dj.id != nil)
        dj.delete
      end
    end

    # this function finds all the due_dates for a given assignment and calculates the time when the reminder for these deadlines needs to be sent. Enqueues them in the delayed_jobs table
    def add_to_delayed_queue
      duedates = DueDate::where(assignment_id: @assignment.id)
      for i in (0 .. duedates.length-1)
        deadline_type = DeadlineType.find(duedates[i].deadline_type_id).name
        due_at = duedates[i].due_at.to_datetime.to_s(:db)
        Time.parse(due_at)
        due_at= Time.parse(due_at)
        mi=find_min_from_now(due_at)
        diff = mi-(duedates[i].threshold)*60
        dj=Delayed::Job.enqueue(DelayedMailer.new(@assignment.id, deadline_type, duedates[i].due_at.to_s(:db)) , 1, diff.minutes.from_now)
        #duedates[i].update_attribute(:delayed_job_id, dj.id)
      end
    end

    def create
      # The Assignment Directory field to be filled in is the path relative to the instructor's home directory (named after his user.name)
      # However, when an administrator creates an assignment, (s)he needs to preface the path with the user.name of the instructor whose assignment it is.
      @assignment = Assignment.new(params[:assignment])
      @user =  ApplicationHelper::get_user_role(session[:user])
      @user = session[:user]
      @user.set_instructor(@assignment)
      @assignment.submitter_count = 0
      @assignment.bookmarkrating_questionnaire_id=1
      ## feedback added
      ##

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

      # Deadline types used in the deadline_types DB table
      deadline = DeadlineType.find_by_name("submission")
      @Submission_deadline = deadline.id
      deadline = DeadlineType.find_by_name("review")
      @Review_deadline = deadline.id
      deadline = DeadlineType.find_by_name("resubmission")
      @Resubmission_deadline = deadline.id
      deadline = DeadlineType.find_by_name("rereview")
      @Rereview_deadline = deadline.id
      deadline = DeadlineType.find_by_name("metareview")
      @Review_of_review_deadline = deadline.id
      deadline = DeadlineType.find_by_name("drop_topic")
      @drop_topic_deadline = deadline.id

      set_requirement

      deadline = DeadlineType.find_by_name("signup")
      @signup_deadline = deadline.id
      deadline = DeadlineType.find_by_name("team_formation")
      @team_formation_deadline = deadline.id
      check_flag = @assignment.availability_flag

      late_policy_set=set_late_policy(params)


      if(check_flag == true && params[:submit_deadline].nil? || !late_policy_set)
        if(check_flag == true && params[:submit_deadline].nil?)
          raise "Please enter a valid Submission deadline!!"
          render :action => 'create'
        elsif(!late_policy_set)
          flash[:error] = "Please select a valid late policy!!"
          @wiki_types = WikiType.all
          get_limits_and_weights
          @private = params[:private] == true
          render :action => 'new'
        end
      elsif (@assignment.save)
        # increment times_used for setting default policy while display. (in late_policies table)
        @late_policy = LatePolicy.find(@assignment.late_policy_id)
        @late_policy.update_attribute(:times_used, @late_policy.times_used + 1)
        #set_questionnaires
        #set_limits_and_weights
        set_assignment_questionnaires
        max_round = 1
        begin
          #setting the Due Dates with a helper function written in DueDate.rb
          if check_flag == true
            due_date = DueDate::set_duedate(params[:submit_deadline],@Submission_deadline, @assignment.id, max_round )
            raise "Please enter a valid Submission deadline" if !due_date
          else
            due_date = DueDate::set_duedate(params[:submit_deadline],@Submission_deadline, @assignment.id, max_round )
          end
          due_date = DueDate::set_duedate(params[:review_deadline],@Review_deadline, @assignment.id, max_round )
          #        raise "Please enter a valid Review deadline" if !due_date
          max_round = 2;

          due_date = DueDate::set_duedate(params[:drop_topic_deadline],@drop_topic_deadline, @assignment.id, 0)
          due_date = DueDate::set_duedate(params[:signup_deadline],@signup_deadline, @assignment.id, 0)
          due_date = DueDate::set_duedate(params[:team_formation_deadline],@team_formation_deadline, @assignment.id, 0)

          #       raise "Please enter a valid Drop-Topic deadline" if !due_date

          if params[:assignment_helper][:no_of_reviews].to_i >= 2
            for resubmit_duedate_key in params[:additional_submit_deadline].keys
              #setting the Due Dates with a helper function written in DueDate.rb
              due_date = DueDate::set_duedate(params[:additional_submit_deadline][resubmit_duedate_key],@Resubmission_deadline, @assignment.id, max_round )
              raise "Please enter a valid Resubmission deadline" if !due_date
              max_round = max_round + 1
            end
            max_round = 2
            for rereview_duedate_key in params[:additional_review_deadline].keys
              #setting the Due Dates with a helper function written in DueDate.rb
              due_date = DueDate::set_duedate(params[:additional_review_deadline][rereview_duedate_key],@Rereview_deadline, @assignment.id, max_round )
              raise "Please enter a valid Rereview deadline" if !due_date
              max_round = max_round + 1
            end
          end
          #setting the Due Dates with a helper function written in DueDate.rb
          @assignment.questionnaires.each{
            |questionnaire|
            if questionnaire.instance_of? MetareviewQuestionnaire
              due_date = DueDate::set_duedate(params[:reviewofreview_deadline],@Review_of_review_deadline, @assignment.id, max_round )
              raise "Please enter a valid Metareview deadline" if !due_date
            end
          }

          # Create submission directory for this assignment
          # If assignment is a Wiki Assignment (or has no directory)
          # the helper will not create a path
          FileHelper.create_directory(@assignment)

          # Creating node information for assignment display
          @assignment.create_node()

          flash[:alert] = "There is already an assignment named \"#{@assignment.name}\". &nbsp;<a style='color: blue;' href='../../assignment/edit/#{@assignment.id}'>Edit assignment</a>" if @assignment.duplicate_name?
            undo_link("Assignment \"#{@assignment.name}\" has been created successfully. ")
          redirect_to controller: :assignments, action: :edit, id: @assignment.id
        rescue
          flash[:error] = $!
          prepare_to_edit
          @wiki_types = WikiType.all
          render :action => 'new'
        end
      else
        @wiki_types = WikiType.all
        render :action => 'new'
      end


      # function that facilitates sending of email reminders
      add_to_delayed_queue
      end

    #---------------------------------------------------------------------------------------------------------------------
    #  SET_DUE_DATES  (Helper function for CREATE and UPDATE)
    #   Creates and sets review deadlines using a helper function written in DueDate.rb
    #   If :id is not blank - update due date in database, else if :due_at is not blank - create due date in database
    #---------------------------------------------------------------------------------------------------------------------

    def set_due_dates

      return_string = ""

      max_round = 2

      if params[:assignment][:rounds_of_reviews].to_i >= 2

        #Resubmission Deadlines
        @Resubmission_deadline = DeadlineType.find_by_name("resubmission").id
        for resubmit_duedate_key in params[:additional_submit_deadline].keys
          if (!params[:additional_submit_deadline][resubmit_duedate_key][:id].blank?)
            due_date_temp = DueDate.find(params[:additional_submit_deadline][resubmit_duedate_key][:id])
            due_date_temp.update_attributes(params[:additional_submit_deadline][resubmit_duedate_key])
            return_string += "Please enter a valid Resubmission deadline </br>" if due_date_temp.errors.length > 0
          elsif (!params[:additional_submit_deadline][resubmit_duedate_key][:due_at].blank?)
            due_date = DueDate::set_duedate(params[:additional_submit_deadline][resubmit_duedate_key],@Resubmission_deadline, @assignment.id, max_round )
            return_string += "Please enter a valid Resubmission deadline</br>" if !due_date
          end
          max_round = max_round + 1
        end
        max_round = 2

        #ReReview Deadlines
        @Rereview_deadline = DeadlineType.find_by_name("rereview").id
        for rereview_duedate_key in params[:additional_review_deadline].keys
          if (!params[:additional_review_deadline][rereview_duedate_key][:id].blank?)
            due_date_temp = DueDate.find(params[:additional_review_deadline][rereview_duedate_key][:id])
            due_date_temp.update_attributes(params[:additional_review_deadline][rereview_duedate_key])
            return_string += "Please enter a valid Rereview deadline </br>" if due_date_temp.errors.length > 0
          elsif (!params[:additional_review_deadline][rereview_duedate_key][:due_at].blank?)
            due_date = DueDate::set_duedate(params[:additional_review_deadline][rereview_duedate_key],@Rereview_deadline, @assignment.id, max_round )
            return_string += "Please enter a valid Rereview deadline</br>" if !due_date
          end
          max_round = max_round + 1
        end
      end

      #Build array for other deadlines
      rows, cols = 5,2
      param_deadline = Hash.new

      param_deadline[DeadlineType.find_by_name("submission").id] = [:submit_deadline, 1]
      param_deadline[DeadlineType.find_by_name("review").id] = [:review_deadline,1]
      param_deadline[DeadlineType.find_by_name("drop_topic").id] = [:drop_topic_deadline,0]
      param_deadline[DeadlineType.find_by_name("metareview").id] = [:reviewofreview_deadline, max_round]



      #Update/Create all deadlines
      param_deadline.each_with_index do |type, index|
        if (!index[0].nil?)
          type_name = DeadlineType.find(type).name.capitalize
          if ( params["#{index[0]}"] && !params["#{index[0]}"][:id].blank?)
            due_date_temp = DueDate.find(params["#{index[0]}"][:id])
            due_date_temp.update_attributes(params["#{index[0]}"])
            (return_string += "Please enter a valid #{type_name} deadline </br>") if due_date_temp.errors.length > 0
          elsif (params["#{index[0]}"] && !params["#{index[0]}"][:due_at].blank?)
            due_date = DueDate::set_duedate(params["#{index[0]}"],type, @assignment.id, index[1] )
            return_string += "Please enter a valid #{type_name} deadline </br>" if !due_date
          end
        end
      end


      return_string

    end

    #---------------------------------------------------------------------------------------------------------------------
    #  SET_DAYS_BETWEEN_SUBMISSIONS  (Helper function for CREATE and UPDATE)
    #   Sets days between submissions for staggered assignments
    #---------------------------------------------------------------------------------------------------------------------

    def set_days_between_submissions

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

    # this function finds all the due_dates for a given assignment and calculates the time when the reminder for these deadlines needs to be sent. Enqueues them in the delayed_jobs table
    def add_to_delayed_queue
      duedates = DueDate::where(assignment_id: @assignment.id)
      for i in (0 .. duedates.length-1)
        deadline_type = DeadlineType.find(duedates[i].deadline_type_id).name
        due_at = duedates[i].due_at.to_s(:db)
        Time.parse(due_at)
        due_at= Time.parse(due_at)
        mi=find_min_from_now(due_at)
        diff = mi-(duedates[i].threshold)*60
        dj=Delayed::Job.enqueue(DelayedMailer.new(@assignment.id, deadline_type, duedates[i].due_at.to_s(:db)) , 1, diff.minutes.from_now)
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

    # This functions finds the epoch time in seconds of the due_at parameter and finds the difference of it
    # from the current time and returns this difference in minutes
    def find_min_from_now(due_at)
      curr_time=DateTime.now.to_s(:db)
      curr_time=Time.parse(curr_time)
      time_in_min=((due_at - curr_time).to_i/60)

      return time_in_min
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
      @wiki_types = WikiType.all
    end

    def define_instructor_notification_limit(assignment_id, questionnaire_id, limit)
      existing = NotificationLimit
        .where(['user_id = ? and assignment_id = ? and questionnaire_id = ?', session[:user].id, assignment_id,questionnaire_id ]).first
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

    def set_questionnaires
      @assignment.questionnaires = Array.new
      params[:questionnaires].each{
        | key, value |
        if value.to_i > 0 and (q = Questionnaire.find(value))
          @assignment.questionnaires << q
      end
      }
    end

    def get_limits_and_weights
      @limits = Hash.new
      @weights = Hash.new

      if session[:user].role.name == "Teaching Assistant"
        user_id = Ta.get_my_instructor(session[:user]).id
      else
        user_id = session[:user].id
      end

      default = AssignmentQuestionnaire.where(
        user_id: user_id,
        assignment_id: nil,
        questionnaire_id: nil,
      ).first

      if default.nil?
        default_limit_value = 15
      else
        default_limit_value = default.notification_limit
      end

      @limits[:review]     = default_limit_value
      @limits[:metareview] = default_limit_value
      @limits[:feedback]   = default_limit_value
      @limits[:teammate]   = default_limit_value
      @limits[:bookmarkrating]= default_limit_value

      @weights[:review] = 100
      @weights[:metareview] = 0
      @weights[:feedback] = 0
      @weights[:teammate] = 0
      @weights[:bookmarkrating] = 0

      @assignment.questionnaires.each{
        | questionnaire |
        aq = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: questionnaire.id).first
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

      default = AssignmentQuestionnaire.where(user_id: user_id, assignment_id: nil, questionnaire_id: nil).first

      @assignment.questionnaires.each{
        | questionnaire |

        aq = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: questionnaire.id).first
        if params[:limits][questionnaire.symbol].length > 0
          aq.update_attribute('notification_limit',params[:limits][questionnaire.symbol])
        else
          aq.update_attribute('notification_limit',default.notification_limit)
        end
        aq.update_attribute('questionnaire_weight',params[:weights][questionnaire.symbol])
        aq.update_attribute('user_id',user_id)
        aq.save
      }
    end
    # a method combines functionality of set_questionnaire and set_limits_and_weights, and it works better with paper_trail versioning
    def set_assignment_questionnaires
      if session[:user].role.name == "Teaching Assistant"
        user_id = TA.get_my_instructor(session[:user]).id
      else
        user_id = session[:user].id
      end

      # update assignment questionnaires, if assignment questionnaire doesn't exist, create one
      default = AssignmentQuestionnaire.where(user_id: user_id, assignment_id: nil, questionnaire_id: nil).first
      params[:questionnaires].each do |key,value|
        if value.to_i > 0 and (@q = Questionnaire.find(value))
          if AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: @q.id).first
            @aq = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: @q.id).first
          else
            @aq = AssignmentQuestionnaire.new(:assignment_id => @assignment.id,:questionnaire_id=> @q.id)
          end
          if params[:limits][@q.symbol].length > 0
            @aq.notification_limit = params[:limits][@q.symbol]
          else
            @aq.notification_limit= default.notification_limit
          end
          @aq.questionnaire_weight= params[:weights][@q.symbol]
          @aq.user_id=user_id
          @aq.save!
        end
      end

      @aqs = AssignmentQuestionnaire.where(assignment_id: @assignment.id)
      for aq in @aqs
        should_delete = true
        params[:questionnaires].each do |key,value|
          if aq.questionnaire_id.to_s == value.to_s
            should_delete = false
          end
        end
        if should_delete == true
          aq.destroy
        end
      end
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


      def set_requirement
        #@required = Hash.new
        if params[:required][:review]
          @assignment.num_reviews = params[:required][:review]
        end

        if params[:required][:metareview]
          @assignment.num_review_of_reviews = params[:required][:metareview]
        end

      end

      #--------------------------------------------------------------------------------------------------------------------
      # UPDATE
      #  make updates to assignment
      #--------------------------------------------------------------------------------------------------------------------
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

        # The update call below updates only the assignment table. The due dates must be updated separately.
        set_requirement

        late_policy_set = set_late_policy(params)

        if @assignment.calculate_penalty == true && params[:assignment][:calculate_penalty] == "false"
          @late_policy = LatePolicy.find(params[:assignment][:late_policy_id])
          @late_policy.update_attribute(:times_used, @late_policy.times_used - 1)

          # delete corresponding rows from Calculated_penalties
          @penaltyObjs = CalculatedPenalty.all

          @penaltyObjs.each do |pen|
            @participant = Participant.find(pen.participant_id)
            if @participant.parent_id == @assignment.id
              #@penalties = calculate_penalty(pen.participant_id)
              #@total_penalty = (@penalties[:submission] + @penalties[:review] + @penalties[:meta_review])
              pen.delete
            end

          end
          @assignment.update_attribute(:is_penalty_calculated, false)
          @assignment.update_attribute(:late_policy_id, nil)
        elsif @assignment.calculate_penalty == false && params[:assignment][:calculate_penalty] == "true"
          # add rows in calculated_penalties

          @late_policy = LatePolicy.find(params[:assignment][:late_policy_id])

          @late_policy.update_attribute(:times_used, @late_policy.times_used + 1)

          participants = AssignmentParticipant.where(parent_id: @assignment.id)
          participants.each do |p|
            @penalties = calculate_penalty(p.id)
            if(@penalties[:submission] != 0 || @penalties[:review] != 0 || @penalties[:meta_review] != 0)
              @total_penalty = (@penalties[:submission] + @penalties[:review] + @penalties[:meta_review])
              penalty_attr1 = {:deadline_type_id => 1,:participant_id => @participant.id, :penalty_points => @penalties[:submission]}
              CalculatedPenalty.create(penalty_attr1)

              penalty_attr2 = {:deadline_type_id => 2,:participant_id => @participant.id, :penalty_points => @penalties[:review]}
              CalculatedPenalty.create(penalty_attr2)

              penalty_attr3 = {:deadline_type_id => 5,:participant_id => @participant.id, :penalty_points => @penalties[:meta_review]}
              CalculatedPenalty.create(penalty_attr3)
            end

          end
          @assignment.update_attribute(:is_penalty_calculated, true)
        end
        # Update the penalties in calculated_penalties table.
        if @assignment.late_policy_id != params[:assignment][:late_policy_id]
          #policy changed so we change the times used field for proper ordering of policies in the dropdown
          @late_policy = LatePolicy.find(@assignment.late_policy_id)
          if (@late_policy.times_used.to_i > 0)
            @late_policy.update_attribute(:times_used, @late_policy.times_used - 1)
          end

          @late_policy = LatePolicy.find(params[:assignment][:late_policy_id])
          @late_policy.update_attribute(:times_used, @late_policy.times_used + 1)

          @penaltyObjs = CalculatedPenalty.all

          @penaltyObjs.each do |pen|
            @participant = Participant.find(pen.participant_id)
            if @participant.parent_id == @assignment.id
              @penalties = calculate_penalty(pen.participant_id)
              @total_penalty = (@penalties[:submission] + @penalties[:review] + @penalties[:meta_review])
              if pen.deadline_type_id.to_i == 1
                pen.update_attribute(:penalty_points, @penalties[:submission])
              elsif pen.deadline_type_id.to_i == 2
                pen.update_attribute(:penalty_points, @penalties[:review])
              elsif pen.deadline_type_id.to_i == 5
                pen.update_attribute(:penalty_points, @penalties[:meta_review])
              end
            end
          end
        end

        if @assignment.calculate_penalty == true && params[:assignment][:calculate_penalty] == "false"
          params[:assignment][:late_policy_id] = nil
        end
        if(!late_policy_set)
          flash[:error] = "Please select a valid late policy!!"
          prepare_to_edit
          @assignment.calculate_penalty = true
          render :action => 'edit'
        elsif @assignment.update_attributes(params[:assignment])
          if params[:questionnaires] and params[:limits] and params[:weights]
            #set_questionnaires
            #set_limits_and_weights
            set_assignment_questionnaires
          end

          begin
            newpath = @assignment.get_path
          rescue
            newpath = nil
          end
          if oldpath != nil and newpath != nil
            FileHelper.update_file_location(oldpath,newpath)
          end

          begin
            # Iterate over due_dates, from due_date[0] to the maximum due_date

            if params[:due_date]
              for due_date_key in params[:due_date].keys
                due_date_temp = DueDate.find(due_date_key)
                # delete the previous jobs from the delayed_jobs table
                djobs = Delayed::Job.where(['handler LIKE "%assignment_id: ?%"', @assignment.id])
                for dj in djobs
                  delete_from_delayed_queue(dj.id)
                end
                due_date_temp.update_attributes(params[:due_date][due_date_key])
                raise "Please enter a valid date & time" if due_date_temp.errors.length > 0
              end
              # add to the delayed_jobs queue according to the updated due_dates
              add_to_delayed_queue
            end

            undo_link("Assignment \"#{@assignment.name}\" was successfully updated. ")
            redirect_to :action => 'show', :id => @assignment

          rescue
            flash[:error] = $!
            prepare_to_edit
            render :action => 'edit', :id => @assignment
          end
        else # Simply refresh the page
          @wiki_types = WikiType.all
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
        @assignment = Assignment.find(params[:id])

        # If the assignment is already deleted, go back to the list of assignments
        if @assignment
          begin
            #delete from delayed_jobs queue
            djobs = Delayed::Job.where(['handler LIKE "%assignment_id: ?%"', @assignment.id])
            for dj in djobs
              delete_from_delayed_queue(dj.id)
            end

            @user = session[:user]
            id = @user.get_instructor
            if(id != @assignment.instructor_id)
              raise "Not authorised to delete this assignment"
            end
            @assignment.delete(params[:force])
            flash[:notice] = "The assignment is deleted"
          rescue
            url_yes = url_for :action => 'delete', :id => params[:id], :force => 1
            url_no  = url_for :action => 'delete', :id => params[:id]
            error = $!
            flash[:error] = error.to_s + " Delete this assignment anyway?&nbsp;<a href='#{url_yes}'>Yes</a>&nbsp;|&nbsp;<a href='#{url_no}'>No</a><BR/>"
          end
        end
        undo_link("Assignment: \"#{@assignment.name}\" has deleted successfully. ")
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
        @assignment = Assignment.find(params[:id])
        @assignment.private = !@assignment.private
        @assignment.save
        undo_link("Assignment \"#{@assignment.name}\" has been made private successfully. ")
        redirect_to :controller => 'tree_display', :action => 'list'
      end

      #--------------------------------------------------------------------------------------------------------------------
      # DEFINE_INSTRUCTOR_NOTIFICATION_LIMIT
      #  !!!NO usages found
      #--------------------------------------------------------------------------------------------------------------------
      def define_instructor_notification_limit(assignment_id, questionnaire_id, limit)
        existing = NotificationLimit.where(['user_id = ? and assignment_id = ? and questionnaire_id = ?',session[:user].id,assignment_id,questionnaire_id]).first
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
        @assignment = Assignment.find(params[:id])
        oldpath = assignment.get_path rescue nil
        @assignment.course_id = nil
        @assignment.save
        newpath = assignment.get_path rescue nil
        FileHelper.update_file_location(oldpath,newpath)
        undo_link("Assignment \"#{@assignment.name}\" has been removed from course successfully. ")
        redirect_to :controller => 'tree_display', :action => 'list'
      end

      :private
      def set_late_policy(params)
        late_policy_set=true
        if(params[:assignment][:calculate_penalty]=="true")
          if(params[:assignment][:late_policy_id].to_i==0)
            late_policy_set=false
          end
        end

        if(params[:assignment][:late_policy_id].to_i==0)
          @assignment.late_policy_id=nil
          params[:assignment][:late_policy_id]=nil
        end
        return late_policy_set
      end


      # generate the undo link
      #def undo_link
      #  "<a href = #{url_for(:controller => :versions,:action => :revert,:id => @assignment.versions.last.id)}>undo</a>"
      #end
    end
