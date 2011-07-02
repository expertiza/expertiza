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

          urls = participant.get_hyperlinks
          if  (participant.resubmission_times.size >0) or (!urls.empty?)
            @taskrevisions << participant
          else
            @tasknotstarted << participant
          end
        elsif  stage == "review" or stage == "rereview"

          #Checking the notifications
          rmaps = ParticipantReviewResponseMap.find_all_by_reviewee_id_and_reviewed_object_id(participant.id, participant.assignment.id)

          for rmap in rmaps
            if (!rmap.response.nil? && rmap.notification_accepted == false)
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

      review_mappings.each do |review_mapping|
        if @assignment.team_assignment
          participant = AssignmentTeam.get_first_member(review_mapping.reviewee_id)
        else
          participant = review_mapping.reviewee
        end

        if !participant.nil? and !participant.topic_id.nil?
          review_due_date = TopicDeadline.find_by_topic_id_and_deadline_type_id(participant.topic_id, 1)

          if review_due_date.due_at < Time.now && @assignment.get_current_stage(participant.topic_id) != 'Complete'
            @reviewee_topic_id = participant.topic_id
          end
        end
      end
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
end
