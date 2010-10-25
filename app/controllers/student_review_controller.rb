class StudentReviewController < ApplicationController
  def list
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
    # Finding the current phase that we are in
    @review_phase = @assignment.get_current_stage(AssignmentParticipant.find(params[:id]).topic_id)
    
    if @assignment.team_assignment
      @review_mappings = TeamReviewResponseMap.find_all_by_reviewer_id(@participant.id)
    else           
      @review_mappings = ParticipantReviewResponseMap.find_all_by_reviewer_id(@participant.id)
    end
    @metareview_mappings = MetareviewResponseMap.find_all_by_reviewer_id(@participant.id)    

    if @assignment.staggered_deadline?
      @review_mappings.each { |review_mapping|
          if @assignment.team_assignment
            user_id = TeamsUser.find_all_by_team_id(review_mapping.reviewee_id)[0].user_id
            participant = Participant.find_by_user_id_and_parent_id(user_id,@assignment.id)
          else
            participant = Participant.find_by_id(review_mapping.reviewee_id)
          end

          if !participant.topic_id.nil?
            review_due_date = TopicDeadline.find_by_topic_id_and_deadline_type_id(participant.topic_id,1)

            #The logic here is that if the user has at least one reviewee to review then @reviewee_topic_id should
            #not be nil. Enabling and disabling links to individual reviews are handled at the rhtml
            if review_due_date.due_at < Time.now
              @reviewee_topic_id = participant.topic_id
            end
          end
        }

      review_rounds = @assignment.get_review_rounds
      if review_rounds == 1
        deadline_type_id = DeadlineType.find_by_name('review').id
      else
        deadline_type_id = DeadlineType.find_by_name('rereview').id        
      end


      @metareview_mappings.each { |metareview_mapping|
        #
        review_mapping = ResponseMap.find(metareview_mapping.reviewed_object_id)
        if @assignment.team_assignment?
          team = TeamsUser.find_all_by_team_id(review_mapping.reviewee_id)
          participant = Participant.find_by_user_id_and_parent_id(team.first.user_id,@assignment.id)
        else
          participant = Participant.find(review_mapping.reviewee_id)
        end
         if !participant.topic_id.nil?
            meta_review_due_date = TopicDeadline.find_by_topic_id_and_deadline_type_id_and_round(participant.topic_id,deadline_type_id,review_rounds)

            if meta_review_due_date.due_at < Time.now
              @meta_reviewee_topic_id = participant.topic_id
            end
          end
       }
    end

  end  
  
end
