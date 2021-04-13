class ReviewMetricsQuery
  # link each tag prompt to the corresponding key in the review hash
  PROMPT_TO_METRIC = {'mention problems?' => 'problem',
                      'suggest solutions?' => 'suggestions',
                      'mention praise?' => 'sentiment',
                      'positive tone?' => 'emotions'}.freeze
  NUMBER_OF_MOST_UNCERTAIN_MACHINE_TAGS = 100

  # Cache tag certainty threshold for different assignment teams
  # The certainty threshold is the fraction (between 0 and 1) that says how certain
  # the ML algorithm must be of a tag value before it will ask the author to tag it
  # manually.
  @@thresholds = {}

  # return all machine tags for the review (Answer object)
  # when tag_prompt_deployment_id is supplied, return only its tag
  def self.machine_tags(review_id, tag_prompt_deployment_id=nil)
    tags = AnswerTag.where(answer_id: review_id).where.not(confidence_level: nil)
    tags = tags.where(tag_prompt_deployment_id: tag_prompt_deployment_id) if tag_prompt_deployment_id
    tags
  end

  def self.cache_ws_results(reviews, tag_prompt_deployments)
    tags = []
    # send every 10 reviews per request (web service returns failure if request body is too large)
    reviews.each_slice(10) do |rs|
      # prepare input
      ws_input = {'reviews' => []}
      rs.each do |review|
        ws_input['reviews'] << {'id' => review.id, 'text' => review.de_tag_comments} if review.comments.present?
      end
      tag_prompt_deployments.each do |tag_prompt_deployment|
        tag_prompt = tag_prompt_deployment.tag_prompt
        metric = PROMPT_TO_METRIC[tag_prompt.prompt.downcase]
        begin
          # these two can be merged into one call
          ws_output = MetricsController.new.bulk_retrieve_metric(metric, ws_input, false)
          ws_output_confidence = MetricsController.new.bulk_retrieve_metric(metric, ws_input, true)
        rescue StandardError # rescue any error thrown from the MetricsController so the code can keep running
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
    end
    tags.each(&:save)
  end

  # cache different tag certainty threshold for different teams
  # only open NUMBER_OF_MOST_UNCERTAIN_MACHINE_TAGS for students to tag
  def self.cache_threshold(team)
    machine_tags = []
    TagPromptDeployment.where(assignment_id: team.assignment.id).find_each do |tag_dep|
      questions_ids = Question.where(questionnaire_id: tag_dep.questionnaire.id, type: tag_dep.question_type).map(&:id)
      ans = Answer.where(question_id: questions_ids, response_id: team.all_responses.map(&:id))
      ans = ans.where("length(comments) > ?", tag_dep.answer_length_threshold.to_s) unless tag_dep.answer_length_threshold.nil?
      machine_tags += machine_tags(ans.map(&:id), tag_dep.id) # how many tags that are tagged by machine
    end
    confidence_levels = machine_tags.map(&:confidence_level).compact.sort_by(&:-@)
    threshold = confidence_levels.last(NUMBER_OF_MOST_UNCERTAIN_MACHINE_TAGS).first
    @@thresholds[team.id] = threshold || 0
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

  def self.confident?(tag_prompt_deployment_id, review_id)
    response_map = Answer.find(review_id).response.response_map
    team = AssignmentTeam.find(response_map.reviewee_id)
    cache_threshold(team) unless @@thresholds[team.id]
    tag = machine_tags(review_id, tag_prompt_deployment_id).first
    confidence = tag ? tag.confidence_level : 0
    confidence > @@thresholds[team.id]
  end

  def self.has?(tag_prompt_deployment_id, review_id)
    tag = machine_tags(review_id, tag_prompt_deployment_id).first
    tag ? tag.value == '1' : false
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
