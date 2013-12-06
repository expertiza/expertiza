class ResponseController < ApplicationController
  helper :wiki
  helper :submitted_content
  helper :file

  def latestResponseVersion
    #get all previous versions of responses for the response map.
    @array_not_empty=0
    @review_scores=Array.new
    @prev=Response.find_all_by_id(@responseByid.id) #find_by_map_id changed to id
    for element in @prev
      @array_not_empty=1
      @review_scores << element
    end
  end

    def get_scores
      @review_scores = Array.new
      @question_type = Array.new
      @questions.each{
          | question |
        @review_scores << Score.find_by_response_id_and_question_id(@response.id, question.id)
        @question_type << QuestionType.find_by_question_id(question.id)
      }
    end
    def delete
      @response = Response.find(params[:id])
      return if redirect_when_disallowed(@response)             #user cannot delete other people's responses. Needs to be authenticated.
      response_id = @response.id
      @response.delete
      redirect_to :action => 'redirection', :id => response_id, :return => params[:return], :msg => "The response was deleted."
    end
    #Determining the current phase and check if a review is already existing for this stage.
    #If so, edit that version otherwise create a new version.
    def rereview
      @responseByid=Response.find(params[:id])
      get_content
      latestResponseVersion
      #sort all the available versions in descending order.
      if @array_not_empty==1
         @sorted=@review_scores.sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }
         @largest_version_num=@sorted[0]
         @latest_phase=@largest_version_num.created_at
         due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?", @assignment.id])
         @sorted_deadlines=Array.new
         @sorted_deadlines=due_dates.sort { |m1, m2| (m1.due_at and m2.due_at) ? m1.due_at <=> m2.due_at : (m1.due_at ? -1 : 1) }
         current_time=Time.new.getutc
         #get the highest version numbered review
         next_due_date=@sorted_deadlines[0]

         #check in which phase the latest review was done.
         for deadline_version in @sorted_deadlines
           if (@largest_version_num.created_at < deadline_version.due_at)
           break
          end
        end
        for deadline_time in @sorted_deadlines
          if(current_time < deadline_time.due_at)
            break
          end
        end
      end
      #check if the latest review is done in the current phase.
      #if latest review is in current phase then edit the latest one.
      #else create a new version and update it.
      # editing the latest review
      if(deadline_version.due_at== deadline_time.due_at)
        #send it to edit here
        @header = "Edit"
        @next_action = "update"
        @return = params[:return]
        @response = Response.find_by_id_and_version_num(params[:id],@largest_version_num.version_num)
        return if redirect_when_disallowed(@response)
        @modified_object = @response.id  ###-###
        @responseByid = @response.map
        get_content
        @review_scores = Array.new
        @questions.each{
            | question |
          @review_scores << Score.find_by_response_id_and_question_id(@response.id, question.id)
        }
        #**********************
        # Check whether this is Jen's assgt. & if so, use her rubric
        if (@assignment.instructor_id == User.find_by_name("jace_smith").id) && @title == "Review"
          if @assignment.id < 469
            @next_action = "update"  ###-###
            render :action => 'custom_response'
          else
            @next_action = "update"  ###-###
            render :action => 'custom_response_2011'
          end
        else
          # end of special code (except for the end below, to match the if above)
          #**********************
          render :action => 'response'
        end
      else
        #else create a new version and update it.
        @header = "New"
        @next_action = "create"
        @feedback = params[:feedback]
        @responseByid = Response.find(params[:id])
        @return = params[:return]
        @modified_object = @responseByid.id
        get_content
        #**********************
        # Check whether this is Jen's assgt. & if so, use her rubric
        if (@assignment.instructor_id == User.find_by_name("jace_smith").id) && @title == "Review"
          if @assignment.id < 469
            @next_action = "create"  ###-###
            render :action => 'custom_response'
          else
            @next_action = "create"  ###-###
            render :action => 'custom_response_2011'
          end
        else
          # end of special code (except for the end below, to match the if above)
          #**********************
          render :action => 'response'
        end
      end
    if @array_not_empty==1
      @sorted=@review_scores.sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }
      @largest_version_num=@sorted[0]
    end
    @response = Response.find_by_id_and_version_num(@responseByid.id, @largest_version_num.version_num)
    @modified_object = @response.response_id
    get_content
    @review_scores = Array.new
    @question_type = Array.new
    @questions.each {
        |question|
      @review_scores << Score.find_by_response_id_and_question_id(@response.response_id, question.id)
      @question_type << QuestionType.find_by_question_id(question.id)
    }
    # Check whether this is a custom rubric
    if @responseByid.questionnaire.section.eql? "Custom"
      @next_action = "custom_update"
      render :action => 'custom_response'
    else
      # end of special code (except for the end below, to match the if above)
      #**********************
      render :action => 'response'
    end
  end

    def edit
      @header = "Edit"
      @next_action = "update"
      @return = params[:return]
      @response = Response.find(params[:id])
      return if redirect_when_disallowed(@response)
      @responseByid = @response.map
      latestResponseVersion
      if @array_not_empty==1
        @sorted=@review_scores.sort { |m1,m2|(m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1)}
        @largest_version_num=@sorted[0]
      end
      @response = Response.find_by_id_and_version_num(@responseByid.id,@largest_version_num.version_num)
      @modified_object = @response.id
      get_content
      get_scores
      # Check whether this is a custom rubric
      if @responseByid.questionnaire.section.eql? "Custom"
        render :action => 'custom_response'
      else
        # end of special code (except for the end below, to match the if above)
        render :action => 'response'
      end
    end

  def update  ###-### Seems like this method may no longer be used -- not in E806 version of the file
    @response = Response.find(params[:id])
    return if redirect_when_disallowed(@response)
    @myid = @response.response_id
    msg = ""
    begin
      @myid = @response.response_id
      @responseByid = @response.map
      @response.update_attribute('additional_comment', params[:review][:comments])

      @questionnaire = @responseByid.questionnaire
      questions = @questionnaire.questions

      params[:responses].each_pair do |k,v|

        score = Score.find_by_response_id_and_question_id(@response.response_id, questions[k.to_i].id)
        if (score == nil)
          score = Score.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
        end
        score.update_attribute('score', v[:score])
        score.update_attribute('comments', v[:comment])
      end
    rescue
      msg = "Your response was not saved. Cause: "+ $!
    end

    begin
       ResponseHelper.compare_scores(@response, @questionnaire)
       ScoreCache.update_cache(@response.id)
    
      msg = "Your response was successfully saved."
    rescue
      msg = "An error occurred while saving the response: "+$!
    end
    redirect_to :controller => 'response', :action => 'saving', :id => @responseByid.id, :return => params[:return], :msg => msg, :save_options => params[:save_options]
  end  

  ###-### custom_update has been removed in this merge.
    def view
      @response = Response.find(params[:id])
      return if redirect_when_disallowed(@response)
      @responseByid = @response.map
      get_content
      get_scores
    end

    def new_feedback
      review = Response.find(params[:id])
      if review
        reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id, review.map.assignment.id)
        map = FeedbackResponse.find_by_reviewed_object_id_and_reviewer_id(review.id, reviewer.id)
        if map.nil?
          #if no feedback exists by dat user den only create for dat particular response/review
          map = FeedbackResponse.create(:reviewed_object_id => review.id, :reviewer_id => reviewer.id, :reviewee_id => review.map.reviewer.id)
        end
        redirect_to :action => 'new', :id => map.id, :return => "feedback"
      else
        redirect_to :back
      end
    end

    def new
      @header = "New"
      @next_action = "create"
      @feedback = params[:feedback]
      puts (params[:id].to_s)
      @responseByid= Response.find(params[:id])
      @return = params[:return]
      @modified_object = @responseByid.id
      get_content
      # Check whether this is a custom rubric
      if @responseByid.questionnaire.section.eql? "Custom"
        @question_type = Array.new
        @questions.each{
            | question |
          @question_type << QuestionType.find_by_question_id(question.id)
        }
        @next_action = "create"                                                                 #changed part of code changed from custom create to create
        render :action => 'custom_response'
      else
        render :action => 'response'
      end
    end

    def create
      @responseByid=Response.find(params[:id])                 #assignment/review/metareview id is in params id
      @res = 0
      msg = ""
      error_msg = ""
      latestResponseVersion
                                                           #if previous responses exist increment the version number.
      if @array_not_empty==1
        @sorted=@review_scores.sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }
        @largest_version_num=@sorted[0]
        if (@largest_version_num.version_num==nil)
          @version=1
        else
          @version=@largest_version_num.version_num+1
        end

        #if no previous version is available then initial version number is 1
      else
        @version=1
      end
    begin
      @response = Response.find_by_id(@responseByid.id)
      @response.additional_comment = params[:review][:comments]
      @response.version_num = @version
      @response.save

      #@response = Response.create(:map_id => @map.id, :additional_comment => params[:review][:comments],:version_num=>@version)

      @res = @response.response_id
      @questionnaire = @responseByid.questionnaire
      questions = @questionnaire.questions
      params[:responses].each_pair do |k, v|
        score = Score.create(:response_id => @response.response_id, :question_id => questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
      end
    rescue
      error_msg = "Your response was not saved. Cause: " + $!
    end
=begin

    begin
      ResponseHelper.compare_scores(@response, @questionnaire)
      ScoreCache.update_cache(@res)
      #@map.save
      msg = "Your response was successfully saved."
    rescue
      @response.delete
      error_msg = "Your response was not saved. Cause:  + {$!}"
    end
=end

    redirect_to :controller => 'response', :action => 'saving', :id => @responseByid.id, :return => params[:return], :msg => msg, :error_msg => error_msg, :save_options => params[:save_options]
  end

  def custom_create ###-### Is this used?  It is not present in the master branch.
    @responseByid = Response.find(params[:id])
    @responseByid.additional_comment = ""
    @responseByid.save
    #@response = Response.create(:map_id => @map.id, :additional_comment => "")
    @res = @response.response_id
    @questionnaire = @responseByid.questionnaire
    questions = @questionnaire.questions
    for i in 0..questions.size-1
      # Local variable score is unused; can it be removed?
      score = Score.create(:response_id => @response.response_id, :question_id => questions[i].id, :score => @questionnaire.max_question_score, :comments => params[:custom_response][i.to_s])
    end
    msg = "#{@responseByid.get_title} was successfully saved."

    saving
  end

  def saving
    @responseByid = Response.find(params[:id])
    @return = params[:return]
    @responseByid.notification_accepted = false
    @responseByid.save
    #@map.assignment.id == 561 or @map.assignment.id == 559 or 
    if (@responseByid.assignment.id == 562) #Making the automated metareview feature available for one 'ethical analysis 6' assignment only.
                                   #puts("*** saving for me:: #{params[:id]} and metareview selection :save_options - #{params["save_options"]}")
      if (params["save_options"].nil? or params["save_options"].empty?) #default it to with metareviews
        params["save_options"] = "WithMeta"
      end
      #calling the automated metareviewer controller, which calls its corresponding model/view
      if (params[:save_options] == "WithMeta")
        # puts "WithMeta"
        redirect_to :controller => 'automated_metareviews', :action => 'list', :id => @responseByid.id
      elsif (params[:save_options] == "EmailMeta")
        redirect_to :action => 'redirection', :id => @responseByid.id, :return => params[:return], :msg => params[:msg], :error_msg => params[:error_msg]
        # calculate the metareview metrics
        @automated_metareview = AutomatedMetareview.new
        #pass in the response id as a parameter
        @response = Response.find_by_id(params[:id])
        @automated_metareview.calculate_metareview_metrics(@response, params[:id])
        #send email to the reviewer with the metareview details
        @automated_metareview.send_metareview_metrics_email(@response, params[:id])
      elsif (params[:save_options] == "WithoutMeta")
        # puts "WithoutMeta"
        redirect_to :action => 'redirection', :id => @responseByid.id, :return => params[:return], :msg => params[:msg], :error_msg => params[:error_msg]
      end
    else
      redirect_to :action => 'redirection', :id => @responseByid.id, :return => params[:return], :msg => params[:msg], :error_msg => params[:error_msg]
    end
  end

  def redirection
    flash[:error] = params[:error_msg] unless params[:error_msg] and params[:error_msg].empty?
    flash[:note] = params[:msg] unless params[:msg] and params[:msg].empty?

    @responseByid = Response.find(params[:id])
    if params[:return] == "feedback"
      redirect_to :controller => 'grades', :action => 'view_my_scores', :id => @responseByid.reviewer.id
    elsif params[:return] == "teammate"
      redirect_to :controller => 'student_team', :action => 'view', :id => @responseByid.reviewer.id
    elsif params[:return] == "instructor"
      redirect_to :controller => 'grades', :action => 'view', :id => @responseByid.assignment.id
    else
      redirect_to :controller => 'student_review', :action => 'list', :id => @responseByid.reviewer.id
    end
  end

  private

  def get_content
    @title = @responseByid.get_title
    @assignment = @responseByid.assignment
    @participant = @responseByid.reviewer
    @contributor = @responseByid.contributor
    @questionnaire = @responseByid.questionnaire
    @questions = @questionnaire.questions
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score
  end

    def redirect_when_disallowed(response)
      # For author feedback, participants need to be able to read feedback submitted by other teammates.
      # If response is anything but author feedback, only the person who wrote feedback should be able to see it.
      if response.map.read_attribute(:type) == 'FeedbackResponse' && response.map.assignment.team_assignment?
        team = response.map.reviewer.team
        unless team.has_user session[:user]
          redirect_to '/denied?reason=You are not on the team that wrote this feedback'
        else
          return false
        end
        response.map.read_attribute(:type)
      end
      !current_user_id?(response.map.reviewer.user_id)
    end
end
