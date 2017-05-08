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
    # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments

    # These variables are used by the flash message to display statistics to users
    @record = Response.where(map_id: params[:map])
    @all_records = Response.all
    @map = ResponseMap.all
    @review_record = ReviewMetricMapping.all
    @review_metrics = ReviewMetric.all
    @my_reviewer_id = params[:id]
    @my_map = params[:map]

    unless @record[0].nil?
      @percentages = calculate_percentages(@record[0].id)
    end

    @review_mappings = ReviewResponseMap.where(reviewer_id: @participant.id)
    # if it is an calibrated assignment, change the response_map order in a certain way
    @review_mappings = @review_mappings.sort_by {|mapping| mapping.id % 5 } if @assignment.is_calibrated == true
    @metareview_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)
    # Calculate the number of reviews that the user has completed so far.

    @num_reviews_total = @review_mappings.size
    # Add the reviews which are requested and not began.
    @num_reviews_completed = 0
    @review_mappings.each do |map|
      @num_reviews_completed += 1 if (!map.response.empty? && map.response.last.is_submitted)
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

  def calculate_percentages(record_id)
    single_response = Response.where(id: record_id)
    mapped_response = ResponseMap.where(id: single_response[0].map_id)
    review_maps = ResponseMap.where(reviewed_object_id: mapped_response[0].reviewed_object_id)
    keys = [[0.00, 0.00, 0.00, 0.00], [0.00, 0.00, 0.00, 0.00], [0.00, 0.00, 0.00, 0.00], [0.00, 0.00, 0.00, 0.00]]
    response_count = [0.00, 0.00, 0.00, 0.00, 0.00, 0.00]
    word_counter = [0, 0, 0, 0, 0, 0]
    suggestive_count = [0, 0, 0, 0, 0, 0]
    problem_count = [0, 0, 0, 0, 0, 0]
    offensive_count = [0, 0, 0, 0, 0, 0]

    review_maps.each do |my_assignment|
      my_responses = Response.where(map_id: my_assignment.id)
      my_responses.each do |each_response|
        response_count[each_response.round - 1] += 1
        my_review_metric = ReviewMetricMapping.where(responses_id: each_response.id)
        my_review_metric.each do |my_metric|
          word_counter[each_response.round - 1] += my_metric.value if my_metric.review_metrics_id == 1 && my_metric.value > 0
          suggestive_count[each_response.round - 1] += 1 if my_metric.review_metrics_id == 2 && my_metric.value > 0
          problem_count[each_response.round - 1] += 1 if my_metric.review_metrics_id == 3 && my_metric.value > 0
          offensive_count[each_response.round - 1] += 1 if my_metric.review_metrics_id == 4 && my_metric.value > 0
        end
      end
    end

    (0..5).each do |i|
      unless response_count[i].zero?
        keys[i][0] = word_counter[i] / response_count[i]
        keys[i][1] = (suggestive_count[i] / response_count[i]) * 100
        keys[i][2] = (problem_count[i] / response_count[i]) * 100
        keys[i][3] = (offensive_count[i] / response_count[i]) * 100
      end
    end
  end
end
