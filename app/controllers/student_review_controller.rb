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
    @assignment = @participant.assignment
    # Find the current phase that the assignment is in.
    @topic_id = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
    @review_phase = @assignment.get_current_stage(@topic_id)
    # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    @review_mappings = ReviewResponseMap.where(reviewer_id: @participant.id)
    # if it is an calibrated assignment, change the response_map order in a certain way
    @review_mappings = @review_mappings.sort_by {|mapping| mapping.id % 5 } if @assignment.is_calibrated == true
    @metareview_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)
    # Calculate the number of reviews that the user has completed so far.
    @num_reviews_total = @review_mappings.map {|response| response.response.size }.sum
    # Add the reviews which are requested and not began.
    @review_mappings.map do |response|
      @num_reviews_total += 1 if response.response.empty?
    end
    @num_reviews_completed = 0
    @review_mappings.each do |map|
      current_round = map.response.map(&:round).max
      map.response.each do |response|
        @num_reviews_completed += 1 if !current_round.eql?(response.round) || response.is_submitted
      end
    end
    @num_reviews_in_progress = @num_reviews_total - @num_reviews_completed
    # Calculate the number of metareviews that the user has completed so far.
    @num_metareviews_total       = @metareview_mappings.size
    @num_metareviews_completed   = 0
    @metareview_mappings.each do |map|
      @num_metareviews_completed += 1 unless map.response.empty?
    end
    @num_metareviews_in_progress = @num_metareviews_total - @num_metareviews_completed
    if @assignment.staggered_deadline?
      @review_mappings.each do |review_mapping|
        # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
        # to treat all assignments as team assignments
        participant = AssignmentTeam.first_member(review_mapping.reviewee_id)
        topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
        next unless participant and topic_id
        review_due_date = TopicDeadline.where(topic_id: topic_id, deadline_type_id: 1).first
        # The logic here is that if the user has at least one reviewee to review then @reviewee_topic_id should
        # not be nil. Enabling and disabling links to individual reviews are handled at the rhtml
        @reviewee_topic_id = topic_id if review_due_date.due_at < Time.now
      end
      review_rounds = @assignment.get_review_rounds
      deadline_type_id = DeadlineType.find_by_name('review').id

      @metareview_mappings.each do |metareview_mapping|
        review_mapping = ResponseMap.find(metareview_mapping.reviewed_object_id)
        if review_mapping
          # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
          # to treat all assignments as team assignments
          participant = AssignmentTeam.first_member(review_mapping.reviewee_id)
          topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
          end
        next unless participant and topic_id
        meta_review_due_date = TopicDeadline.where(topic_id: topic_id, deadline_type_id: deadline_type_id, round: review_rounds).first
        if meta_review_due_date.due_at < Time.now
          @meta_reviewee_topic_id = topic_id
        end
      end
    end
  end

  private

  # authorizations: reader,submitter, reviewer
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
