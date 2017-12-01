class StudentReviewController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator',
     'Student'].include? current_role_name and
    ((%w(list).include? action_name) ? are_needed_authorizations_present?(params[:id], "submitter") : true)
  end

  def list
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    @assignment = @participant.assignment
    # Find the current phase that the assignment is in.
    @topic_id = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
    @review_phase = @assignment.get_current_stage(@topic_id)
    @first_submission_due_date= AssignmentDueDate.where(parent_id: @assignment.id, deadline_type_id: '1').first.due_at
    puts "##########################first submission"

    puts @first_submission_due_date
    # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    @peer_reviews=Array.new
    puts "##########################is_calibrated"
    if @assignment.is_calibrated?
      @calibration_reviews=Array.new
      calibration_due_date = AssignmentDueDate.where(parent_id: @assignment.id, deadline_type_id: '12').last.due_at
      puts "##########################"
      puts Time.now
      puts calibration_due_date

      if Time.now <= calibration_due_date
          puts "During calibration period"
          @calibration_reviews=ReviewResponseMap.where(reviewer_id: @participant.id)
          puts "#########################"
          puts @calibration_reviews
      else
        @review_mappings=ReviewResponseMap.where(reviewer_id: @participant.id)
        @review_mappings.each do |review_map|
          if review_map.created_at <= calibration_due_date
            @calibration_reviews << review_map
          else
            puts "##inside else ##"
            @peer_reviews << review_map
          end  
        end
      end
      @calibration_reviews = @calibration_reviews.sort_by {|mapping| mapping.id % 5 }
    else
      @peer_reviews = ReviewResponseMap.where(reviewer_id: @participant.id)
    end
    
    puts "###########PEER REVIEWS##############"
    puts @peer_reviews
    # if it is an calibrated assignment, change the response_map order in a certain way

    @metareview_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)
    # Calculate the number of reviews that the user has completed so far.

    @num_reviews_total = @peer_reviews.size
    # Add the reviews which are requested and not began.
    @num_reviews_completed = 0
    @peer_reviews.each do |map|
      @num_reviews_completed += 1 if !map.response.empty? && map.response.last.is_submitted
    end

    @num_reviews_in_progress = @num_reviews_total - @num_reviews_completed
    # Calculate the number of metareviews that the user has completed so far.
    @num_metareviews_total       = @metareview_mappings.size
    @num_metareviews_completed   = 0
    @metareview_mappings.each do |map|
      @num_metareviews_completed += 1 unless map.response.empty?
    end
    @num_metareviews_in_progress = @num_metareviews_total - @num_metareviews_completed
    @topic_id = SignedUpTeam.topic_id(@assignment.id, @participant.user_id)
  end
end
