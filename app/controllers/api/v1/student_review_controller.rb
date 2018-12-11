module Api::V1
  class StudentReviewController < BasicApiController
    def action_allowed?
      ['Instructor',
      'Teaching Assistant',
      'Administrator',
      'Super-Administrator',
      'Student'].include? current_role_name and
      ((%w[list].include? action_name) ? are_needed_authorizations_present?(params[:id], "submitter") : true)
    end

    def list
      @participant = AssignmentParticipant.find(params[:id])
      skip = false
      if (!current_user_id?(@participant.user_id))
        skip = true
      end
      if !skip
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

        @num_reviews_total = @review_mappings.size
        # Add the reviews which are requested and not began.
        @num_reviews_completed = 0
        puts @participant.user_id
        @candidate_reviews = []
        @review_mappings.each do |map|
          @latest_response = nil
          if !map.response.empty?
            array_not_empty = 0
            @sorted_responses = Array.new
            @prev = Response.where(:map_id => map.id)
            for element in @prev
                    array_not_empty = 1
                      @sorted_responses << element
            end
            if (array_not_empty == 1)
                @sorted_responses = @sorted_responses.sort_by {|obj| obj.updated_at} # the latest should be at the last
                @latest_response = @sorted_responses.last
            end 
          end
          temp = {} 
          if map.type.to_s == "MetareviewResponseMap"
            review_mapping = ResponseMap.find(map.reviewed_object_id)
            candidate = AssignmentTeam.get_first_member(review_mapping.reviewee_id)
          else
            candidate = AssignmentTeam.get_first_member(map.reviewee_id)
          end 
          if candidate
                topic_id = SignedUpTeam.topic_id(candidate.parent_id, candidate.user_id)
                temp[:map] = map
                if @latest_response!=nil
                  temp[:latest_response_id] = @latest_response.id 
                end
                temp[:id] = SignUpTopic.find(topic_id).topic_identifier
                temp[:name] = SignUpTopic.find(topic_id).topic_name
                @candidate_reviews << temp
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
        @topic_id = SignedUpTeam.topic_id(@assignment.id, @participant.user_id)
        
      
        @candidate_topics_to_review = @assignment.candidate_topics_to_review(@participant).to_a 
        @candidate_topics_to_review.sort! { |a, b| a.id <=> b.id } 
        @non_reviewable_topics = @assignment.sign_up_topics - @candidate_topics_to_review 
        @non_reviewable_topics.sort! { |a, b| a.id <=> b.id }

        render json: {
                      status: :ok,
                      candidate_reviews_started: @candidate_reviews,
                      review_mappings: @review_mappings,
                      candidate_topics_to_review: @candidate_topics_to_review,
                      non_reviewable_topics: @non_reviewable_topics,
                      num_reviews_in_progress: @num_reviews_in_progress
                    }
      else 
        render json: {status: :ok, data: 'access denied'}
      end
    end

  end
end