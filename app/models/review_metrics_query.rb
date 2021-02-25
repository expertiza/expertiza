class ReviewMetricsQuery
  # The certainty threshold is the fraction (between 0 and 1) that says how certain
  # the ML algorithm must be of a tag value before it will ask the author to tag it
  # manually.
  TAG_CERTAINTY_THRESHOLD = 0.9

  # link each tag prompt to the corresponding key in the review hash
  PROMPT_TO_METRIC = {'mention problems?' => 'problem',
                      'suggest solutions?' => 'suggestions',
                      'mention praise?' => 'sentiment',
                      'positive tone?' => 'emotions'}.freeze

  def self.retrieve_from_cache(tag_prompt_deployment_id, review_id)
    AnswerTag.where(answer_id: review_id, tag_prompt_deployment_id: tag_prompt_deployment_id).where.not(confidence_level: nil).first
  end

  def self.cache_ws_results(reviews, tag_prompt_deployments)
    ws_input = {'reviews' => []}
    reviews.each do |review|
      ws_input['reviews'] << {'id' => review.id, 'text' => review.de_tag_comments} if review.comments.present?
    end

    tags = []

    # ask MetricsController to make a call to the review metrics web service
    tag_prompt_deployments.each do |tag_prompt_deployment|
      tag_prompt = tag_prompt_deployment.tag_prompt
      metric = PROMPT_TO_METRIC[tag_prompt.prompt.downcase]
      begin
        ws_output = MetricsController.new.bulk_retrieve_metric(metric, ws_input, false)
        ws_output_confidence = MetricsController.new.bulk_retrieve_metric(metric, ws_input, true)
      rescue StandardError
        break
      else
        next unless ws_output && ws_output['reviews'] && ws_output_confidence && ws_output_confidence['reviews']
        ws_output['reviews'].zip(ws_output_confidence['reviews']).each do |review_with_value, review_with_confidence|
          tag = AnswerTag.where(answer_id: review_with_value['id'],
                                tag_prompt_deployment_id: tag_prompt_deployment.id)
                         .where.not(confidence_level: [nil]).first_or_initialize
          tag.assign_attributes(value: inferred_value(metric, review_with_value),
                                confidence_level: inferred_confidence(metric, review_with_confidence))
          tags << tag
        end
      end
    end

    tags.each(&:save)
  end

  def self.inferred_value(metric, review)
    value = case metric
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
    value ? 1 : -1
  end

  def self.inferred_confidence(metric, review)
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

  def self.confidence(tag_prompt_deployment_id, review_id)
    review = retrieve_from_cache(tag_prompt_deployment_id, review_id)
    review ? review.confidence_level : 0
  end

  def self.confident?(tag_prompt_deployment_id, review_id)
    confidence = confidence(tag_prompt_deployment_id, review_id)
    confidence >= TAG_CERTAINTY_THRESHOLD
  end

  def self.has?(tag_prompt_deployment_id, review_id)
    review = retrieve_from_cache(tag_prompt_deployment_id, review_id)
    review ? review.value == '1' : false
  end

  # return the average number of qualifying comments (comments that meet the description of the
  # tag prompt, e.g. Mention problem?) in a group of reviews. When reviewer is supplied,
  # it returns the average number of qualifying comments made by the reviewer.
  def self.average_number_of_qualifying_comments(tag_prompt_deployment_id, reviewer = nil)
    tags = AnswerTag.where(tag_prompt_deployment_id: tag_prompt_deployment_id, user_id: nil)
    if reviewer
      responses = reviewer.becomes(Participant).reviews.map(&:response).flatten
      answers = responses.map(&:scores).flatten
      tags = tags.where(answer_id: answers.map(&:id))
    end
    analyzed_responses = tags.map {|tag| tag.answer.response }.uniq
    positive_tags = tags.where(value: '1')
    analyzed_responses.count.zero? ? 0 : positive_tags.count / analyzed_responses.count
  end

end
