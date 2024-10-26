module ResponseHelper
  # E2218: this module contains methods that are used in response_controller class

  # locks a response based on an authenticated user
  def lock_response(map,curr_response)
    if map_team_reviewing_enabled?(map.team_reviewing_enabled)
      this_response = Lock.get_lock(curr_response, current_user, Lock::DEFAULT_TIMEOUT)
      if this_response.nil?
        response_lock_action
      end
      return this_response
    end
    return curr_response
  end

  # E-1973 - helper method to check if the current user is the reviewer
  # if the reviewer is an assignment team, we have to check if the current user is on the team
  def current_user_is_reviewer?(map, _reviewer_id)
    map.reviewer.current_user_is_reviewer? current_user.try(:id)
  end

  # sorts the items passed by sequence number in ascending order
  def sort_items(items)
    items.sort_by(&:seq)
  end

  # Assigns total contribution for cake item across all reviewers to a hash map
  # Key : item_id, Value : total score for cake item
  def store_total_cake_score
    reviewee = ResponseMap.select(:reviewee_id, :type).where(id: @response.map_id.to_s).first
    @total_score = Cake.get_total_score_for_items(reviewee.type,
                                                      @review_items,
                                                      @participant.id,
                                                      @assignment.id,
                                                      reviewee.reviewee_id)
  end

  # new_response if a flag parameter indicating that if user is requesting a new rubric to fill
  # if true: we figure out which itemnaire to use based on current time and records in assignment_itemnaires table
  # e.g. student click "Begin" or "Update" to start filling out a rubric for others' work
  # if false: we figure out which itemnaire to display base on @response object
  # e.g. student click "Edit" or "View"
  def set_content(new_response = false)
    @title = @map.get_title
    if @map.survey?
      @survey_parent = @map.survey_parent
    else
      @assignment = @map.assignment
    end
    @participant = @map.reviewer
    @contributor = @map.contributor
    new_response ? itemnaire_from_response_map : itemnaire_from_response
    set_dropdown_or_scale
    @review_items = sort_items(@itemnaire.items)
    @min = @itemnaire.min_item_score
    @max = @itemnaire.max_item_score
    # The new response is created here so that the controller has access to it in the new method
    # This response object is populated later in the new method
    if new_response
      #Sometimes the response is already created and the new controller is called again (page refresh)
      @response = Response.where(map_id: @map.id, round: @current_round.to_i).order(updated_at: :desc).first
      if @response.nil?
        @response = Response.create(map_id: @map.id, additional_comment: '', round: @current_round.to_i, is_submitted: 0)
      end
    end
  end
end
