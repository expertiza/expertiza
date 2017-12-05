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
    @regular_review_mappings = []
    @calibration_review_mappings = []

    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    @assignment = @participant.assignment
    # Find the current phase that the assignment is in.
    @topic_id = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
    @review_phase = @assignment.get_current_stage(@topic_id)
    # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments

    @review_mappings = ReviewResponseMap.where(reviewer_id: @participant.id)
    puts "reviewer_id: #{@participant.id}"
    # if it is an calibrated assignment, change the response_map order in a certain way
    @review_mappings = @review_mappings.sort_by {|mapping| mapping.id % 5 } if @assignment.is_calibrated == true
    @metareview_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)
    # Calculate the number of reviews that the user has completed so far.




    @calibration_deadline = @assignment.due_dates.find_by_deadline_type_id(12)






    @num_reviews_total = @review_mappings.size
    # Add the reviews which are requested and not began.
    @num_regular_reviews_completed = 0
    @num_calibration_reviews_completed = 0
    @num_regular_reviews_total = 0
    @num_calibration_reviews_total = 0
    assignment_submission_due_date = @assignment.due_dates.select {|due_date| due_date.deadline_type_id == 1 }.first.due_at
    puts "map_num = #{@re}"
    @review_mappings.each do |map|
      puts "1 #{map.response.count}"
      next if map.response.empty?
      puts '2'
      if map.response.last.updated_at < assignment_submission_due_date
        puts '3'
        # @calibration_review_mappings.push(map)
        @num_calibration_reviews_completed += 1 if map.response.last.is_submitted
      else
        puts '4'
        # @regular_review_mappings.push(map)
        @num_regular_reviews_completed += 1 if map.response.last.is_submitted
      end
      # puts @calibration_review_mappings.to_s
    end
    @review_mappings.each do |map|
      if map.updated_at < assignment_submission_due_date
        @calibration_review_mappings.push(map)
        @num_calibration_reviews_total += 1
      else
        @regular_review_mappings.push(map)
        @num_regular_reviews_total += 1
      end
    end

    @num_calibration_reviews_in_progress = @num_calibration_reviews_total - @num_calibration_reviews_completed
    @num_regular_reviews_in_progress = @num_regular_reviews_total - @num_regular_reviews_completed

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
