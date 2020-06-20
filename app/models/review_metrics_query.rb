class ReviewMetricsQuery
  include Singleton

  # The certainty threshold is the fraction (between 0 and 1) that says how certain
  # the ML algorithm must be of a tag value before it will ask the author to tag it
  # manually.
  TAG_CERTAINTY_THRESHOLD = 0.8

  # link each tag prompt to the corresponding key in the review hash
  PROMPT_TO_METRIC = {"Mention Problems?" => :Problem,
                      "Suggest Solutions?" => :Suggestions,
                      "Mention Praise?" => :Sentiment,
                      "Positive Tone?" => :Emotion}.freeze

  def initialize
    # queried_result is an array of reviews, where each review is a hash that maps several of its attributes like "Suggestions", and "Emotion" to the result determined by the WS.
    @queried_result = []
  end

  # metric: :Sentiment, :Suggestions, :Emotion, and :Problem
  def confidence(metric, review_id)
    review = review_from_cache(review_id)
    confidence = review[:Confidence][metric]
    confidence ||= 0 # in case that there is no corresponding metric for this tag_prompt
    confidence
  end

  # metric: :Suggestions, and :Problem
  def has(metric, review_id)
    review = review_from_cache(review_id)
    review[metric] == "Present"
  end

  # ----------------- helper methods ----------------- #

  # find the review that matches the review_id
  def review_from_cache(review_id)
    review = @queried_result.find {|review| review[:id] == review_id }
    # if not yet cached
    unless review
      # cache it, along with other reviews that may also need to be cached
      cache_ws_results(review_id)
      review = @queried_result.find {|r| r[:id] == review_id }
    end
    review
  end

  def cache_ws_results(review_id)
    reviews = reviews_to_be_cached(review_id)
    # put reviews in a format that the WS can understand
    ws_input = {reviews: []}
    reviews.each do |review|
      ws_input[:reviews] << {id: review.id, text: review.comments}
    end
    # ask MetricsController to make a call to the review metrics web service
    ws_output = MetricsController.new.confidence_metric(ws_input)
    @queried_result = ws_output[:reviews]
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
    # let the instance method do the job
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
    # let the instance method do the job
    ReviewMetricsQuery.instance.has(PROMPT_TO_METRIC[prompt], review_id)
  end

  # =============== End of caller's interfaces ===============
end