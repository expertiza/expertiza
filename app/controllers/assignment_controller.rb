class AssignmentController < ApplicationController
  require 'ftools'
  auto_complete_for :user, :name
  before_filter :authorize
  
  @no_dl="1" # a value of "no" for whether an action is permitted prior to a deadline
  @late_dl="2" # a value of "late" for whether an action is permitted prior to a deadline (it is permitted, but marked late)
  @ok_dl="3" # a value of "OK" for whether an action is permitted prior to a deadline
  def new
    @assignment = Assignment.new
    @questionnaire = Questionnaire.find_all
    @wiki_types = WikiType.find_all
  end
  def add_team_member
    @count=4#params[:newitem]
  end
  def create
    # The Assignment Directory field to be filled in is the path relative to the instructor's home directory (named after his user.name)
    # However, when an administrator creates an assignment, (s)he needs to preface the path with the user.name of the instructor whose assignment it is.
    @assignment = Assignment.new(params[:assignment])
    @assignment.instructor_id = (session[:user]).id
    @assignment.submitter_count = 0
    ## feedback added
    puts "round = ",params[:assignment_helper][:no_of_reviews].to_i
    ##
    @duedate=DueDate.new
    
    # Deadline types used in the deadline_types DB table
    @Submission_deadline=1;
    @Review_deadline=2;
    @Resubmission_deadline=3;
    @Rereview_deadline=4;
    @Review_of_review_deadline=5;
    
    
    if @assignment.save
      submit_duedate=DueDate.new(params[:submit_deadline]);
      submit_duedate.deadline_type_id=@Submission_deadline;
      submit_duedate.assignment_id=@assignment.id;
      submit_duedate.late_policy_id=params[:for_due_date][:late_policy_id];
      ## feedback added
      submit_duedate.round = 1;
      puts "submit round",submit_duedate.round
      ##
      submit_duedate.save;
      
      review_duedate=DueDate.new(params[:review_deadline]);
      review_duedate.deadline_type_id=@Review_deadline;
      review_duedate.assignment_id=@assignment.id;
      review_duedate.late_policy_id=1;
      ## feedback added
      review_duedate.round = 1;
      puts "review round",review_duedate.round
      ##
      review_duedate.save;
      ## feedback added
      max_round = 2;
      ##
      
      if params[:assignment_helper][:no_of_reviews].to_i >= 2
        for resubmit_duedate_key in params[:additional_submit_deadline].keys
          resubmit_duedate=DueDate.new(params[:additional_submit_deadline][resubmit_duedate_key]);
          resubmit_duedate.deadline_type_id=@Resubmission_deadline;
          resubmit_duedate.assignment_id=@assignment.id;
          resubmit_duedate.late_policy_id=params[:for_due_date][:late_policy_id];
          ## feedback added
          resubmit_duedate.round = max_round
          puts "resubmit round",resubmit_duedate.round
          max_round = max_round + 1
          ##
          resubmit_duedate.save;
        end
        ## feedback added
        max_round = 2
        ##
        for rereview_duedate_key in params[:additional_review_deadline].keys
          rereview_duedate=DueDate.new(params[:additional_review_deadline][rereview_duedate_key]);
          rereview_duedate.deadline_type_id=@Rereview_deadline;
          rereview_duedate.assignment_id=@assignment.id;
          rereview_duedate.late_policy_id=params[:for_due_date][:late_policy_id];
          ## feedback added
          rereview_duedate.round = max_round
          puts "rereview round",rereview_duedate.round
          max_round = max_round + 1
          ##
          rereview_duedate.save;
        end
        ## feedback added
        puts "max_round ", max_round
        ##
        
      end      
      reviewofreview_duedate=DueDate.new(params[:reviewofreview_deadline]);
      reviewofreview_duedate.deadline_type_id=@Review_of_review_deadline;
      reviewofreview_duedate.assignment_id=@assignment.id;
      reviewofreview_duedate.late_policy_id=params[:for_due_date][:late_policy_id];
      ## feedback added
      reviewofreview_duedate.round = max_round
      puts "review of review round",reviewofreview_duedate.round
      ##
      reviewofreview_duedate.save;
      
      # Create submission directory for this assignment
      File.makedirs(RAILS_ROOT + "/pg_data/" + params[:assignment][:directory_path])
      flash[:notice] = 'Assignment was successfully created.'
      redirect_to :action => 'list'
      
    else
      @wiki_types = WikiType.find_all
      render :action => 'new'
    end
    
  end
  
  def assign_reviewers
    @assignment = Assignment.find(params[:id])
    @review_strategies = ReviewStrategy.find(:all, :order => 'name')
    @mapping_strategies = MappingStrategy.find(:all, :order => 'name')
  end
  
  def save_reviewer_mappings
    @assignment = Assignment.find(params[:assignment_id])
    @assignment.review_strategy_id = 1
    @assignment.mapping_strategy_id = 1
    
    ## feedback added    
    params[:selection].each {|key, value| puts "#{key} is #{value}" }
    
    mapping_strategy = {}
    params[:selection].each{|a|
      if a[0] =~ /^m_/
        puts "hey"
        mapping_strategy[a[0]] = a[1]
      end
    }
    
    mapping_strategy.each {|key, value| puts "#{key} maps #{value}" }
    ##
    if @assignment.update_attributes(params[:assignment])
      ## feedback added
      ReviewMapping.assign_reviewers(@assignment.id, @assignment.num_reviews, @assignment.num_review_of_reviews, mapping_strategy)
      ##
      flash[:notice] = 'Reviewers assigned successfully.'
      redirect_to :action => 'list'
    else
      @wiki_types = WikiType.find_all
      render :action => 'edit'
    end    
  end
  
  def edit
    @assignment = Assignment.find(params[:id])
    @wiki_types = WikiType.find_all
  end
  
  def update
    @assignment = Assignment.find(params[:id])
    # The update call below updates only the assignment table. The due dates must be updated separately.
    if @assignment.update_attributes(params[:assignment])
      # Iterate over due_dates, from due_date[0] to the maximum due_date
      for due_date_key in params[:due_date].keys
        due_date_temp = DueDate.find(due_date_key)
        due_date_temp.update_attributes(params[:due_date][due_date_key])
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
    @assignment = get(Assignment, params[:id])
    # If the assignment is already deleted, go back to the list of assignments
    if @assignment == nil
      redirect_to :action => 'list' 
    else 
      if @assignment.team_assignment
        logger.info "Assignment destroy"
        teams = Team.find(:all,:conditions => ["assignment_id = ?",@assignment.id])
        teams.each {|team|
          logger.info "#{team.name}"
          team.delete
        }
      end
      if @assignment.due_dates_exist? == false or params['delete'] or @assignment.review_feedback_exist? == false or @assignment.participants_exist? == false
        # The size of an empty directory is 2
        # Delete the directory if it is empty
        begin
          if Dir.entries(RAILS_ROOT + "/pg_data/" + @assignment.directory_path).size == 2
            Dir.delete(RAILS_ROOT + "/pg_data/" + @assignment.directory_path)
          else
            flash[:notice] = "Directory not empty.  Assignment has been deleted, but submitted files remain."
          end
          @assignment.delete_due_dates
          @assignment.delete_review_feedbacks
          @assignment.delete_participants
          @assignment.delete_review_mapping
          @assignment.delete_review_of_review_mapping
          @assignment.delete_review_feedback
          @assignment.destroy
          
          redirect_to :action => 'list'
        rescue
          @assignment.delete_due_dates
          @assignment.delete_review_feedbacks
          @assignment.delete_participants
          @assignment.delete_review_mapping
          @assignment.delete_review_of_review_mapping
          @assignment.delete_review_feedback
          @assignment.destroy
          
          redirect_to :action => 'list'
        end
      end
    end
    
  end
  
  
  def list
    set_up_display_options("ASSIGNMENT")
    @assignments=super(Assignment)
    #    @assignment_pages, @assignments = paginate :assignments, :per_page => 10
  end
  
  def list_team
    @team_pages, @teams = paginate :teams, :per_page => 10
  end
  
  def show_team
    @team = Team.find(params[:id])
  end
  
  def new_team
    @team = Team.new
  end
  
  def view_report
    @assignment = Assignment.find(params[:id])
    @participants = Participant.find(:all,:conditions => ["assignment_id = ?", @assignment.id])
    @sum_of_max = 0
    @sum_of_max_ror = 0
    for question in Questionnaire.find(Assignment.find(@assignment.id).review_questionnaire_id).questions
      @sum_of_max += Questionnaire.find(Assignment.find(@assignment.id).review_questionnaire_id).max_question_score
    end
    for question in Questionnaire.find(Assignment.find(@assignment.id).review_of_review_questionnaire_id).questions
      @sum_of_max_ror += Questionnaire.find(Assignment.find(@assignment.id).review_of_review_questionnaire_id).max_question_score
    end
  end
  
  def ror_for_instructors
    @reviewer_id = session[:user].id
    @assignment_id = params[:id]
    @reviews = Array.new
    review_mappings = ReviewMapping.find(:all,:conditions => ["assignment_id = ?", params[:id]])
    for review_mapping in review_mappings
      if Review.find_by_review_mapping_id(review_mapping.id)
        @reviews << Review.find_by_review_mapping_id(review_mapping.id)
      end
    end
    
  end
  
  def assign_survey
    @assignment = Assignment.find(params[:id])
    @assigned_surveys = SurveyHelper::get_assigned_surveys(@assignment.id)
    @surveys = Array.new
    
    if params['subset'] == "mine"
      @surveys = Questionnaire.find(:all, :conditions => ["type_id = 2 and instructor_id = ?", session[:user].id])
    elsif params['subset'] == "public"
      @surveys = Questionnaire.find(:all, :conditions => ["type_id = 2 and private = 0"])
    else
      @surveys = @assigned_surveys
    end
    
    if params['update']
      if params[:surveys]
        @checked = params[:surveys]
        
        if params['submit_subset'] == "mine"
          @submit_surveys = Questionnaire.find(:all, :conditions => ["type_id = 2 and instructor_id = ?", session[:user].id])
        elsif params['submit_subset'] == "public"
          @submit_surveys = Questionnaire.find(:all, :conditions => ["type_id = 2 and private = 0"])
        else
          @submit_surveys = @assigned_surveys
        end
        
        for survey in @submit_surveys
          unless @checked.include? survey.id
            AssignmentsQuestionnaires.delete_all(["questionnaire_id = ? and assignment_id = ?", survey.id, @assignment.id])
            @assigned_surveys.delete(survey)
          end
        end 
        
        for checked_survey in @checked
          @current = Questionnaire.find(checked_survey)
          unless @assigned_surveys.include? @current
            @new = AssignmentsQuestionnaires.new(:questionnaire_id => checked_survey, :assignment_id => @assignment.id)
            @new.save
            @assigned_surveys << @current
          end
        end
      else
        for survey in @submit_surveys
          AssignmentsQuestionnaires.delete_all(["questionnaire_id = ? and assignment_id = ?", survey.id, @assignment.id])
          @assigned_surveys.delete(survey)
          @surveys.delete(survey)
        end 
      end
    end
    
    @surveys.sort!{|a,b| a.name <=> b.name}

  end
  
  def view_grading_report
    @sum_of_max = 0
    @sum_of_max_ror = 0
    @num_of_reviews = 0;
    @assignment = Assignment.find(params[:id])
    scores = ReviewScore.find_by_sql("select review_id, sum(score) as total_score from review_scores group by review_id order by total_score")
    @scores_by_author = scores.group_by {|score| score.review.review_mapping.author}.sort_by { |participant| participant[0].fullname}
    for question in Questionnaire.find(Assignment.find(@assignment.id).review_questionnaire_id).questions
      @sum_of_max += Questionnaire.find(Assignment.find(@assignment.id).review_questionnaire_id).max_question_score
    end
    for question in Questionnaire.find(Assignment.find(@assignment.id).review_of_review_questionnaire_id).questions
      @sum_of_max_ror += Questionnaire.find(Assignment.find(@assignment.id).review_of_review_questionnaire_id).max_question_score
    end
    for author in @scores_by_author
      temp = 0;
      for grade in author[1]
        if grade.review.review_mapping.assignment_id == @assignment.id
          temp += 1;
        end
      end
      if temp > @num_of_reviews
        @num_of_reviews = temp
      end
    end
  end
    
	def grading_conflict_email_form
		@instructor = session[:user];
    @sum_of_max = 0
    @assignment = Assignment.find(params[:assignment])
    @author = User.find(params[:author])
    @reviewers_email_hash = {}
    @users_grades = Array.new
    all_grades = ReviewScore.find_by_sql("select review_id, sum(score) as total_score from review_scores group by review_id order by total_score") 
    for question in Questionnaire.find(Assignment.find(@assignment.id).review_questionnaire_id).questions
      @sum_of_max += Questionnaire.find(Assignment.find(@assignment.id).review_questionnaire_id).max_question_score
    end
    for grade in all_grades
      if grade.review.review_mapping.author_id.to_s == @author.id.to_s
        @users_grades << grade
        reviewer = grade.review.review_mapping.reviewer
        @reviewers_email_hash[reviewer.fullname.to_s+" <"+reviewer.email.to_s+">"] = reviewer.email.to_s
      end
    end
  end
  
  def send_grading_conflict_email
    email_form = params[:mailer]
    assignment = Assignment.find(email_form[:assignment])
    recipient = User.find(:first, :conditions => ["email = ?", email_form[:recipients]])
    recipients_grade = 0
    all_grades = ReviewScore.find_by_sql("select review_id, sum(score) as total_score from review_scores group by review_id order by total_score") 
    for grade in all_grades
      if grade.review.review_mapping.reviewer_id.to_s == recipient.id.to_s
        recipients_grade = grade.total_score.to_f*100/25
      end
    end
    
    Mailer.deliver_message(
      { :recipients => email_form[:recipients],
        :subject => email_form[:subject],
        :from => email_form[:from],
        :body => {  
          :recipients_name => recipient.fullname,
          :comments => email_form[:comments],
          :assignment_name => assignment.name,
          :recipients_grade => recipients_grade,
          :partial_name => "grading_conflict"
        }
      }
    )   
    
    flash[:notice] = "Your email to " + email_form[:recipients] + " has been sent. If you would like to send an email to another student please do so now, otherwise click Back"
    redirect_to :action => 'grading_conflict_email_form', 
                :assignment => email_form[:assignment], 
                :author => email_form[:author]
  end
  
  def final_grade_report
    @assignment = Assignment.find(params[:assignment])
    @participant = Participant.find(:first, :conditions => ["user_id = ?", params[:author]])
    
  end

end
