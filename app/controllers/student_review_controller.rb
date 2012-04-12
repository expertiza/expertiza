class StudentReviewController < ApplicationController
  
  def list 
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    @assignment  = @participant.assignment
    # Find the current phase that the assignment is in.
    @review_phase = @assignment.get_current_stage(AssignmentParticipant.find(params[:id]).topic_id)
    if @assignment.team_assignment
      @review_mappings = TeamReviewResponseMap.find_all_by_reviewer_id(@participant.id)
    else           
      @review_mappings = ParticipantReviewResponseMap.find_all_by_reviewer_id(@participant.id)
    end
    @metareview_mappings = MetareviewResponseMap.find_all_by_reviewer_id(@participant.id)  
    # Calculate the number of reviews that the user has completed so far.
    @num_reviews_total       = @review_mappings.size
    @num_reviews_completed   = 0
    @review_mappings.each do |map|
      @num_reviews_completed += 1 if map.response
    end
    @num_reviews_in_progress = @num_reviews_total - @num_reviews_completed
    # Calculate the number of metareviews that the user has completed so far.
    @num_metareviews_total       = @metareview_mappings.size
    @num_metareviews_completed   = 0
    @metareview_mappings.each do |map|
      @num_metareviews_completed += 1 if map.response
    end
    @num_metareviews_in_progress = @num_metareviews_total - @num_metareviews_completed
    if @assignment.staggered_deadline?
      @review_mappings.each { |review_mapping|
        if @assignment.team_assignment?
          participant = AssignmentTeam.get_first_member(review_mapping.reviewee_id)
        else
          participant = review_mapping.reviewee
        end

        if !participant.nil? and !participant.topic_id.nil?
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
      @metareview_mappings.each do |metareview_mapping|
        review_mapping = ResponseMap.find_by_id(metareview_mapping.reviewed_object_id)
        if review_mapping
          if @assignment.team_assignment?
            participant = AssignmentTeam.get_first_member(review_mapping.reviewee_id)
          else
            participant = review_mapping.reviewee
          end
        end
        if participant && participant.topic_id
          meta_review_due_date = TopicDeadline.find_by_topic_id_and_deadline_type_id_and_round(participant.topic_id,deadline_type_id,review_rounds)
          if meta_review_due_date.due_at < Time.now
            @meta_reviewee_topic_id = participant.topic_id
          end
        end
      end
    end
  end  
  
end
