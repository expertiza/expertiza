class StudentTaskController < ApplicationController
  helper :submitted_content

  def list
    if session[:user].is_new_user
      redirect_to :controller => 'eula', :action => 'display'
    end
    @participants = AssignmentParticipant.find_all_by_user_id(session[:user].id, :order => "parent_id DESC")

     ########Tasks and Notifications##################
    @tasknotstarted = Array.new
    @taskrevisions = Array.new
    @notifications = Array.new

     for participant in @participants
      stage = participant.assignment.get_current_stage(participant.topic_id)
      duedate = participant.assignment.get_stage_deadline(participant.topic_id)


      if participant.assignment != nil and
              duedate != "Complete"


        if stage == "submission" or stage == "resubmission"

          current_folder = DisplayOption.new
          current_folder.name = ""

          files = participant.get_files(participant.get_path + current_folder.name)
          url = participant.submitted_hyperlink
          if  (participant.resubmission_times.size >0 and files.length > 0) or (!url.nil? and url!= '')
            @taskrevisions << participant
          else
            @tasknotstarted << participant
          end
        elsif  stage == "review" or stage == "rereview"

          #Checking the notifications
          rmaps = ParticipantReviewResponseMap.find_all_by_reviewee_id_and_reviewed_object_id(participant.id, participant.assignment.id)

          for rmap in rmaps
            if rmap.notification_accepted == false
              @notifications << participant
              break;
            end
          end
          ############

          if participant.assignment.team_assignment
            maps = TeamReviewResponseMap.find_all_by_reviewer_id(participant.id)
          else
            maps = ParticipantReviewResponseMap.find_all_by_reviewer_id(participant.id)
          end
          rev = !(maps.size == 0)
          for map in maps
            if !map.response
              rev = false
              break
            end
          end
          if rev
            @taskrevisions << participant
          else
            @tasknotstarted << participant
          end
        elsif stage == "metareview"

          #Checking metareview notifications
          rmaps = ParticipantReviewResponseMap.find_all_by_reviewer_id_and_reviewed_object_id(participant.id, participant.parent_id)
          for rmap in rmaps
            mmaps = MetareviewResponseMap.find_all_by_reviewee_id_and_reviewed_object_id(rmap.reviewer_id, rmap.id)
            if !mmaps.nil?
              for mmap in mmaps
                if mmap.notification_accepted == false
                  @notifications << participant
                  break
                end
              end

            end

          end
          ##################


          maps = MetareviewResponseMap.find_all_by_reviewer_id(participant.id)
          rev = !(maps.size == 0)
          for map in maps
            if !map.response
              rev = false
              break
            end
          end
          if rev
            @taskrevisions << participant
          else
            @tasknotstarted << participant
          end

        end
      end
    end


  end

  def view
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    
    @assignment = @participant.assignment    
    @can_provide_suggestions = Assignment.find(@assignment.id).allow_suggestions
    @reviewee_topic_id = nil
    #Even if one of the reviewee's work is ready for review "Other's work" link should be active
    if @assignment.staggered_deadline?
      if @assignment.team_assignment
        review_mappings = TeamReviewResponseMap.find_all_by_reviewer_id(@participant.id)
      else
        review_mappings = ParticipantReviewResponseMap.find_all_by_reviewer_id(@participant.id)
      end

      review_mappings.each { |review_mapping|
          if @assignment.team_assignment
            participant = AssignmentTeam.get_first_member(review_mapping.reviewee_id)
          else
            participant = review_mapping.reviewee
          end

          if !participant.nil? and !participant.topic_id.nil?
            review_due_date = TopicDeadline.find_by_topic_id_and_deadline_type_id(participant.topic_id,1)

          if review_due_date.due_at < Time.now && @assignment.get_current_stage(participant.topic_id) != 'Complete'
            @reviewee_topic_id = participant.topic_id
          end
        end
      }
    end
  end

  def others_work
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    
    @assignment = @participant.assignment
    # Finding the current phase that we are in
    due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?", @assignment.id])
    @very_last_due_date = DueDate.find(:all, :order => "due_at DESC", :limit =>1, :conditions => ["assignment_id = ?", @assignment.id])
    next_due_date = @very_last_due_date[0]
    for due_date in due_dates
      if due_date.due_at > Time.now
        if due_date.due_at < next_due_date.due_at
          next_due_date = due_date
        end
      end
    end

    @review_phase = next_due_date.deadline_type_id;
    if next_due_date.review_of_review_allowed_id == DueDate::LATE or next_due_date.review_of_review_allowed_id == DueDate::OK
      if @review_phase == DeadlineType.find_by_name("metareview").id
        @can_view_metareview = true
      end
    end

    @review_mappings = ResponseMap.find_all_by_reviewer_id(@participant.id)
    @review_of_review_mappings = MetareviewResponseMap.find_all_by_reviewer_id(@participant.id)
  end

  def your_work

  end

  def reportgen
    @assgn = []
    @scores = []
    @ranges = []
    @type = []
    @teams = []
    @user = User.new(params[:userform])
    @res = User.find_by_name(@user.name)
    if @user.name!=""
      @participant = Participant.find_all_by_user_id(@res.id)
      for participant in @participant do
        @temp=ScoreCache.find_all_by_reviewee_id(participant.id)
        @teams=AssignmentParticipant.find(:all, :conditions => ["parent_id=? and user_id=?", participant.parent_id, participant.user_id])
        puts @temp.size
        puts @teams.size
        for tscore in @temp do
          @assgn<<Assignment.find(participant.parent_id).name
          @scores<<tscore.score
          @ranges<<tscore.range
          @type<<tscore.object_type
        end
        for team in @teams do
          @temp=ScoreCache.find_all_by_reviewee_id(team.team)
        end
        for tscore in @temp do
          @assgn<<Assignment.find(participant.parent_id).name
          @scores<<tscore.score
          @ranges<<tscore.range
          @type<<tscore.object_type
        end
      end

    end

  end

  def viewreviews
    @scoreid = []
    @additionalcomment = []
    if params[:id]=="TeammateReviewResponseMap" || params[:id]=="ParticipantReviewResponseMap"
      @participant_id = Participant.find(:all, :conditions=> ["parent_id=? and user_id=?", Assignment.find_by_name(params[:assgn]).id, params[:user]])
    else
      @participant_id = AssignmentParticipant.find(:all, :conditions => ["parent_id=? and user_id=?", Assignment.find_by_name(params[:assgn]).id, params[:user]])
    end
    for participant in @participant_id do
      if params[:id]== "TeammateReviewResponseMap" || params[:id]=="ParticipantReviewResponseMap"
        @validresponses = ResponseMap.find(:all, :conditions => ["reviewed_object_id=? and reviewee_id=? and type=?", Assignment.find_by_name(params[:assgn]).id, participant.id, params[:id]])
      else
        @validresponses = ResponseMap.find(:all, :conditions => ["reviewed_object_id=? and reviewee_id=? and type=?", Assignment.find_by_name(params[:assgn]).id, participant.team, params[:id]])
      end
      #@validresponses = @validresponses.sort!(&:reviewer_id)
      for validresponse in @validresponses do
        @responseid = Response.find(:all, :conditions=> ["map_id=?", validresponse.id])
        for response in @responseid
          @indivresponses = Score.find(:all, :conditions => ["response_id=?", response.id])
          @additionalcomment << response.additional_comment
          for responses in @indivresponses do
            @scoreid << responses.id
          end
        end
      end
    end
    puts @scoreid.size
  end

  def percentage
    @countmeta =0
    @countfeed=0
    @countteammate=0
    @countpart=0
    @countteamreview=0
    @assignment=0
    @course=0
    @user=User.find_by_name(params[:name])
    if (@user.nil?)
      @msg = "USER NOT FOUND"
    else
      @teamid= TeamsUser.find_all_by_user_id(@user.id)
      @participant = Participant.find_all_by_user_id(@user.id)
      @participant.each do |part|
        if (part[:type] == "AssignmentParticipant")
          @assignment+=1
        end
        if (part[:type] == "CourseParticipant")
          @course+=1
        end
        @response= ResponseMap.find_all_by_reviewer_id(part.id)
        @response.each do |resp|
          if (resp[:type] == "MetareviewResponseMap")
            @countmeta +=1
          end
          if (resp[:type] == "FeedbackResponseMap")
            @countfeed +=1
          end
          if (resp[:type] == "TeammateReviewResponseMap")
            @countteammate +=1
          end
          if (resp[:type] == "ParticipantReviewResponseMap")
            @countpart +=1
          end
          if (resp[:type] == "TeamReviewResponseMap")
            @countteamreview +=1
          end
        end
      end
    end
    render(:action=>'percentage')
  end
end
