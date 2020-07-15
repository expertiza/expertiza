class ReviewMetricsQuery
  include Singleton

  # The certainty threshold is the fraction (between 0 and 1) that says how certain
  # the ML algorithm must be of a tag value before it will ask the author to tag it
  # manually.
  TAG_CERTAINTY_THRESHOLD = 0.8

  # link each tag prompt to the corresponding key in the review hash
  PROMPT_TO_METRIC = {'Mention Problems?' => 'problem',
                      'Suggest Solutions?' => 'suggestions',
                      'Mention Praise?' => 'sentiment',
                      'Positive Tone?' => 'emotions'}.freeze

  def initialize
    # structure of @queried_results = {request => queried_result, request => queried_result}
    # where request can be either metric or metric_confidence
    # and queried result is the response gotten from the web service
    @queried_results = {}
  end

  def confidence(metric, review_id)
    return 0 unless metric

    request = metric + '_confidence'
    review = retrieve_from_cache(request, review_id)
    confidence = review['confidence'].to_f

    # translate the meaning of 'confidence'
    # from 'confidence of the positive'
    # to 'confidence of the predicted value (present or absent)'
    if (metric == 'problem' || metric == 'suggestions') && (confidence < 0.5)
      1 - confidence
    else
      confidence
    end
  end

  def has(metric, review_id)
    return false unless metric

    review = retrieve_from_cache(metric, review_id)
    case metric
    when 'problem'
      review['problems'] == 'Present'
    when 'suggestions'
      review['suggestions'] == 'Present'
    when 'emotions'
      review['Praise'] != 'None'
    when 'sentiment'
      review['sentiment_tone'] == 'Positive'
    else
      false
    end
  end

  def retrieve_from_cache(request, review_id)
    review = {}
    review = @queried_results[request].find {|review| review['id'] == review_id } if @queried_results[request]
    # if not yet cached
    if review.blank?
      # cache it, along with other reviews that may also need to be cached
      cache_ws_results(request, review_id)
      review = @queried_results[request].find {|r| r['id'] == review_id } if @queried_results[request]
    end
    review
  end

  def cache_ws_results(request, review_id)
    ws_input = {'reviews' => []}
    # see if this set of reviews has already been retrieved by a query
    reviews = @queried_results.find {|_key, value| value.find {|r| r['id'] == review_id } }

    if reviews
      # use output from previous query which is already in a format used by the ws
      # thus avoid the need to gather the same data from the database again
      ws_input['reviews'] = reviews[1]
    else
      reviews = reviews_to_be_cached(review_id)
      reviews.each do |review|
        ws_input['reviews'] << {'id' => review.id, 'text' => review.comments}
      end
    end

    # ask MetricsController to make a call to the review metrics web service
    confidence = request.split('_').count > 1
    ws_output = MetricsController.new.bulk_service_retrival(ws_input, request.split('_')[0], confidence)
    @queried_results[request] = ws_output['reviews']
  end

  # find all reviews that may be displayed in the requesting page
  def reviews_to_be_cached(review_id)
    answer = Answer.find(review_id)
    response = answer.response
    response_map = response.response_map
    team = AssignmentTeam.find(response_map.reviewee_id)
    assignment = team.assignment
    responses = if assignment.varying_rubrics_by_round?
                  ReviewResponseMap.get_responses_for_team_round(team, response.round)
                else
                  ReviewResponseMap.get_assessments_for(team)
                end
    responses.map(&:scores).flatten
  end

  # =============== Caller's interfaces ===============

  # usage: ReviewMetricQuery.confidence(tag_dep.tag_prompt.prompt, answer.id)
  def self.confidence(prompt, review_id)
    ReviewMetricsQuery.instance.confidence(PROMPT_TO_METRIC[prompt], review_id)
  end

  # usage: ReviewMetricQuery.confident?(tag_dep.tag_prompt.prompt, answer.id)
  # answer_tagging would most likely to use this method since it returns either
  # true or false
  def self.confident?(prompt, review_id)
    confidence = ReviewMetricsQuery.instance.confidence(PROMPT_TO_METRIC[prompt], review_id)
    confidence > TAG_CERTAINTY_THRESHOLD
  end

  # usage: ReviewMetricQuery.has(tag_dep.tag_prompt.prompt, answer.id)
  def self.has(prompt, review_id)
    ReviewMetricsQuery.instance.has(PROMPT_TO_METRIC[prompt], review_id)
  end

  # =============== End of caller's interfaces ===============
end