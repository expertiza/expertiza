# This is a new model create by E1577 (heat map)
# represents each table in the view_team view.
# the important piece to note is that the @listofrows is a  list of type VmQuestionResponse_Row, which represents a row of the heatgrid table.
class VmQuestionResponse
  attr_reader :name, :rounds, :round, :questionnaire_type, :questionnaire_display_type, :list_of_reviews, :list_of_rows, :list_of_reviewers, :max_score

  @questionnaire = nil
  @assignment = nil

  def initialize(questionnaire, assignment = nil, round = nil)
    @assignment = assignment
    @questionnaire = questionnaire
    if questionnaire.type == 'ReviewQuestionnaire'
      @round = round || AssignmentQuestionnaire.find_by(assignment_id: @assignment.id, questionnaire_id: questionnaire.id).used_in_round
    end

    @rounds = @assignment.rounds_of_reviews

    @list_of_rows = []
    @list_of_reviewers = []
    @list_of_reviews = []
    @list_of_team_participants = []
    @max_score = questionnaire.max_question_score
    @questionnaire_type = questionnaire.type
    @questionnaire_display_type = questionnaire.display_type
    @rounds = rounds
    @round = round
    @name  = questionnaire.name
  end

  def add_questions(questions)
    questions.each do |question|
      # Get the maximum score for this question. For some unknown, godforsaken reason, the max
      # score for the question is stored not on the question, but on the questionnaire. Neat.
      corresponding_questionnaire = question.questionnaire
      question_max_score = corresponding_questionnaire.max_question_score
      # if this question is a header (table header, section header, column header), ignore this question
      unless question.is_a? QuestionnaireHeader
        row = VmQuestionResponseRow.new(question.txt, question.id, question.weight, question_max_score, question.seq)
        @list_of_rows << row
      end
    end
  end

  def add_reviews(participant, team, vary)
    if @questionnaire_type == 'ReviewQuestionnaire'
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
    elsif @questionnaire_type == 'AuthorFeedbackQuestionnaire' # ISSUE E-1967 updated
      reviews = []
      # finding feedbacks where current pariticipant of assignment (author) is reviewer
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
    elsif @questionnaire_type == 'TeammateReviewQuestionnaire'
      reviews = participant.teammate_reviews
      reviews.each do |review|
        review_mapping = TeammateReviewResponseMap.find_by(id: review.map_id)
        participant = Participant.find(review_mapping.reviewer_id)
        # commenting out teamreviews. I just realized that teammate reviews are hidden during the current semester,
        # and I don't know how to implement the logic, so I'm being safe.
        @list_of_reviewers << participant
        @list_of_reviews << review
      end
    elsif @questionnaire_type == 'MetareviewQuestionnaire'
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
    if @questionnaire_type == 'MetareviewQuestionnaire' || @questionnaire_type == 'ReviewQuestionnaire'
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

  def max_score_for_questionnaire
    @max_score * @list_of_rows.length
  end

  def add_answer(answer)
    # We want to add each response score from this review (answer) to its corresponding
    # question row.
    @list_of_rows.each do |row|
      next unless row.question_id == answer.question_id

      # Go ahead and calculate what the color code for this score should be.
      question_max_score = row.question_max_score

      # This calculation is a little tricky. We're going to find the percentage for this score,
      # multiply it by 5, and then take the ceiling of that value to get the color code. This
      # should work for any point value except 0 (which we'll handle separately).
      color_code_number = 0
      if answer.answer.is_a? Numeric
        color_code_number = ((answer.answer.to_f / question_max_score.to_f) * 5.0).ceil
        # Color code c0 is reserved for null spaces in the table which will be gray.
        color_code_number = 1 if color_code_number.zero?
      end

      # Find out the tag prompts associated with the question
      tag_deps = TagPromptDeployment.where(questionnaire_id: @questionnaire.id, assignment_id: @assignment.id)
      vm_tag_prompts = []

      question = Question.find(answer.question_id)

      # check if the tag prompt applies for this question type and if the comment length is above the threshold
      # if it does, then associate this answer with the tag_prompt and tag deployment (the setting)
      tag_deps.each do |tag_dep|
        if (tag_dep.question_type == question.type) && (answer.comments.length > tag_dep.answer_length_threshold)
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
          row.metric_hash["> 10 Word Comments"] = row.metric_hash["> 10 Word Comments"] + 1 if row.question_id == answer.question_id && answer.comments && answer.comments.split.size > 10
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
          row.metric_hash["> 20 Word Comments"] = row.metric_hash["> 20 Word Comments"] + 1 if row.question_id == answer.question_id && answer.comments && answer.comments.split.size > 1
        end
      end
    end
  end
end
