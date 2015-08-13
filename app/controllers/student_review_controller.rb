class StudentReviewController < ApplicationController
  def action_allowed?
    ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator',
       'Student'].include? current_role_name and ((%w(list).include? action_name) ? are_needed_authorizations_present? : true)
  end


  def list
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    @assignment  = @participant.assignment
    # Find the current phase that the assignment is in.
    @topic_id = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
    @review_phase = @assignment.get_current_stage(@topic_id)
    #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    @review_mappings = ReviewResponseMap.where(reviewer_id: @participant.id)
    @metareview_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)
    # Calculate the number of reviews that the user has completed so far.
    @num_reviews_total       = @review_mappings.size
    @num_reviews_completed   = 0
    @review_mappings.each do |map|
      @num_reviews_completed += 1 if !map.response.empty?
    end
    @num_reviews_in_progress = @num_reviews_total - @num_reviews_completed
    # Calculate the number of metareviews that the user has completed so far.
    @num_metareviews_total       = @metareview_mappings.size
    @num_metareviews_completed   = 0
    @metareview_mappings.each do |map|
      @num_metareviews_completed += 1 if !map.response.empty?
    end
    @num_metareviews_in_progress = @num_metareviews_total - @num_metareviews_completed
    if @assignment.staggered_deadline?
      @review_mappings.each { |review_mapping|
        #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
        # to treat all assignments as team assignments
        participant = AssignmentTeam.first_member(review_mapping.reviewee_id)
        topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
        if participant and topic_id
          review_due_date = TopicDeadline.where(topic_id: topic_id, deadline_type_id: 1).first
          #The logic here is that if the user has at least one reviewee to review then @reviewee_topic_id should
          #not be nil. Enabling and disabling links to individual reviews are handled at the rhtml
          if review_due_date.due_at < Time.now
            @reviewee_topic_id = topic_id
          end
        end
      }
      review_rounds = @assignment.get_review_rounds
      deadline_type_id = DeadlineType.find_by_name('review').id

      @metareview_mappings.each do |metareview_mapping|
        review_mapping = ResponseMap.find(metareview_mapping.reviewed_object_id)
        if review_mapping
          #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
          # to treat all assignments as team assignments
          participant = AssignmentTeam.first_member(review_mapping.reviewee_id)
          topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
          end
        if participant and topic_id
          meta_review_due_date = TopicDeadline.where(topic_id: topic_id, deadline_type_id:deadline_type_id, round:review_rounds).first
          if meta_review_due_date.due_at < Time.now
            @meta_reviewee_topic_id = topic_id
          end
        end
      end
    end
  end


  private
  #authorizations: reader,submitter, reviewer
  def are_needed_authorizations_present?
    @participant = Participant.find(params[:id])
    authorization = Participant.get_authorization(@participant.can_submit, @participant.can_review, @participant.can_take_quiz)
    if authorization == 'submitter'
      return false
    else
      return true
    end
  end
end
