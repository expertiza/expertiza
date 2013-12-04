class StudentReviewController < ApplicationController
  
  def list 
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    @assignment  = @participant.assignment
    # Find the current phase that the assignment is in.
    @review_phase = @assignment.get_current_stage(AssignmentParticipant.find(params[:id]).topic_id)
    #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    #Changes made for E914
    @review_responses = TeamReviewResponse.find_all_by_reviewer_id(@participant.id)
    @metareview_responses = MetareviewResponse.find_all_by_reviewer_id(@participant.id)
    # Calculate the number of reviews that the user has completed so far.
    @num_reviews_total       = @review_responses.size
    @num_reviews_completed   = 0
    @review_responses.each do |response|
      @num_reviews_completed += 1 if response.response
    end
    @num_reviews_in_progress = @num_reviews_total - @num_reviews_completed
    # Calculate the number of metareviews that the user has completed so far.
    @num_metareviews_total       = @metareview_responses.size
    @num_metareviews_completed   = 0
    @metareview_responses.each do |response|
      @num_metareviews_completed += 1 if response.response
    end
    @num_metareviews_in_progress = @num_metareviews_total - @num_metareviews_completed
    if @assignment.staggered_deadline?
      @review_responses.each { |review_response|
        #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
        # to treat all assignments as team assignments
        participant = AssignmentTeam.get_first_member(review_response.reviewee_id)

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
      deadline_type_id = DeadlineType.find_by_name('review').id

      @metareview_responses.each do |metareview_response|
        review_resp = ResponseMap.find_by_id(metareview_response.reviewed_object_id)
        if review_resp
          #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
          # to treat all assignments as team assignments
          participant = AssignmentTeam.get_first_member(review_resp.reviewee_id)
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
