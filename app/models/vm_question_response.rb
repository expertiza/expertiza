# This is a new model create by E1577 (heat map)
# represents each table in the view_team view.
# the important piece to note is that the @listofrows is a  list of type VmQuestionResponse_Row, which represents a row of the heatgrid table.
class VmQuestionResponse
  attr_reader :name, :rounds, :round, :itemnaire_type, :itemnaire_display_type, :list_of_reviews, :list_of_rows, :list_of_reviewers, :max_score

  @itemnaire = nil
  @assignment = nil

  def initialize(itemnaire, assignment = nil, round = nil)
    @assignment = assignment
    @itemnaire = itemnaire
    @round = round
    if itemnaire.type == 'ReviewQuestionnaire'
      @round = round || AssignmentQuestionnaire.find_by(assignment_id: @assignment.id, itemnaire_id: itemnaire.id).used_in_round
    end

    @rounds = @assignment.rounds_of_reviews

    @list_of_rows = []
    @list_of_reviewers = []
    @list_of_reviews = []
    @list_of_team_participants = []
    @max_score = itemnaire.max_item_score
    @itemnaire_type = itemnaire.type
    @itemnaire_display_type = itemnaire.display_type
    @rounds = rounds

    @name  = itemnaire.name
  end

  def add_items(items)
    items.each do |item|
      # Get the maximum score for this item. For some unknown, godforsaken reason, the max
      # score for the item is stored not on the item, but on the itemnaire. Neat.
      corresponding_itemnaire = item.itemnaire
      item_max_score = corresponding_itemnaire.max_item_score
      # if this item is a header (table header, section header, column header), ignore this item
      unless item.is_a? QuestionnaireHeader
        row = VmQuestionResponseRow.new(item.txt, item.id, item.weight, item_max_score, item.seq)
        @list_of_rows << row
      end
    end
  end

  def add_reviews(participant, team, vary)
    if @itemnaire_type == 'ReviewQuestionnaire'
      reviews = if vary
                  ReviewResponseMap.get_responses_for_team_round(team, @round)
                else
                  ReviewResponseMap.assessments_for(team)
                end
      reviews.each do |review|
        review_mapping = ReviewResponseMap.find(review.map_id)
        if review_mapping.present?
          participant = Participant.find(review_mapping.reviewer_id)
          @list_of_reviewers << participant
        end
      end
      @list_of_reviews = reviews
    elsif @itemnaire_type == 'AuthorFeedbackQuestionnaire' # ISSUE E-1967 updated
      reviews = []
      # finding feedbacks where current participant of assignment (author) is reviewer
      feedbacks = FeedbackResponseMap.where(reviewer_id: participant.id)
      feedbacks.each do |feedback|
        # finding the participant ids for each reviewee of feedback
        # participant is really reviewee here.
        participant = Participant.find_by(id: feedback.reviewee_id)
        # finding the all the responses for the feedback
        response = Response.where(map_id: feedback.id).order('updated_at').last
        if response
          reviews << response
          @list_of_reviews << response
        end
        @list_of_reviewers << participant
      end
    elsif @itemnaire_type == 'TeammateReviewQuestionnaire'
      reviews = participant.teammate_reviews
      reviews.each do |review|
        review_mapping = TeammateReviewResponseMap.find_by(id: review.map_id)
        participant = Participant.find(review_mapping.reviewer_id)
        # commenting out teamreviews. I just realized that teammate reviews are hidden during the current semester,
        # and I don't know how to implement the logic, so I'm being safe.
        @list_of_reviewers << participant
        @list_of_reviews << review
      end
    elsif @itemnaire_type == 'MetareviewQuestionnaire'
      reviews = participant.metareviews
      reviews.each do |review|
        review_mapping = MetareviewResponseMap.find_by(id: review.map_id)
        participant = Participant.find(review_mapping.reviewer_id)
        @list_of_reviewers << participant
        @list_of_reviews << review
      end
    end
    reviews.each do |review|
      answers = Answer.where(response_id: review.response_id)
      answers.each do |answer|
        add_answer(answer)
      end
    end
  end

  def display_team_members(ip_address = nil)
    @output = ''
    if @itemnaire_type == 'MetareviewQuestionnaire' || @itemnaire_type == 'ReviewQuestionnaire'
      @output = 'Team members:'
      @list_of_team_participants.each do |participant|
        @output = @output + ' (' + participant.fullname(ip_address) + ') '
      end

    end

    @output
  end

  def add_team_members(team)
    @list_of_team_participants = team.participants
  end

  def max_score_for_itemnaire
    @max_score * @list_of_rows.length
  end

  def add_answer(answer)
    # We want to add each response score from this review (answer) to its corresponding
    # item row.
    @list_of_rows.each do |row|
      next unless row.item_id == answer.item_id

      # Go ahead and calculate what the color code for this score should be.
      item_max_score = row.item_max_score

      # This calculation is a little tricky. We're going to find the percentage for this score,
      # multiply it by 5, and then take the ceiling of that value to get the color code. This
      # should work for any point value except 0 (which we'll handle separately).
      color_code_number = 0
      if answer.answer.is_a? Numeric
        color_code_number = ((answer.answer.to_f / item_max_score.to_f) * 5.0).ceil
        # Color code c0 is reserved for null spaces in the table which will be gray.
        color_code_number = 1 if color_code_number.zero?
      end

      # Find out the tag prompts associated with the item
      tag_deps = TagPromptDeployment.where(itemnaire_id: @itemnaire.id, assignment_id: @assignment.id)
      vm_tag_prompts = []

      item = Question.find(answer.item_id)

      # check if the tag prompt applies for this item type and if the comment length is above the threshold
      # if it does, then associate this answer with the tag_prompt and tag deployment (the setting)
      tag_deps.each do |tag_dep|
        if (tag_dep.item_type == item.type) && (answer.comments.length > tag_dep.answer_length_threshold)
          vm_tag_prompts.append(VmTagPromptAnswer.new(answer, TagPrompt.find(tag_dep.tag_prompt_id), tag_dep))
        end
      end
      # end tag_prompt code

      # Now construct the color code and we're good to go!
      color_code = "c#{color_code_number}"
      row.score_row.push(VmQuestionResponseScoreCell.new(answer.answer, color_code, answer.comments, vm_tag_prompts))
    end
  end

  # This method calls all the methods that are responsible for calculating different metrics.If any new metric is introduced, please call the method that calculates the metric values from this method.
  def calculate_metrics
    number_of_comments_greater_than_10_words
    number_of_comments_greater_than_20_words
  end

  # This method is responsible for checking whether a review comment contains more than 10 words.
  def number_of_comments_greater_than_10_words
    @list_of_reviews.each do |review|
      answers = Answer.where(response_id: review.response_id)
      answers.each do |answer|
        @list_of_rows.each do |row|
          row.metric_hash["> 10 Word Comments"] = 0 if row.metric_hash["> 10 Word Comments"].nil?
          row.metric_hash["> 10 Word Comments"] = row.metric_hash["> 10 Word Comments"] + 1 if row.item_id == answer.item_id && answer.comments && answer.comments.split.size > 10
        end
      end
    end
  end

  # In case if new metirc is added. This is a dummy metric added for manual testing and will be removed.
  def number_of_comments_greater_than_20_words
    @list_of_reviews.each do |review|
      answers = Answer.where(response_id: review.response_id)
      answers.each do |answer|
        @list_of_rows.each do |row|
          row.metric_hash["> 20 Word Comments"] = 0 if row.metric_hash["> 20 Word Comments"].nil?
          row.metric_hash["> 20 Word Comments"] = row.metric_hash["> 20 Word Comments"] + 1 if row.item_id == answer.item_id && answer.comments && answer.comments.split.size > 20
        end
      end
    end
  end
end
