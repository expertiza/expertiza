# This is a new model create by E1577 (heat map)
# represents each table in the view_team view.
# the important piece to note is that the @listofrows is a  list of type VmQuestionResponse_Row, which represents a row of the heatgrid table.
class VmQuestionResponse
  @questionnaire = nil
  @assignment = nil
  @self_reviews = nil # we will be storing the self review values in this variable, nil if no self review present

  def initialize(questionnaire, assignment=nil)
    @assignment = assignment
    @questionnaire = questionnaire
    if questionnaire.type == "ReviewQuestionnaire"
      @round = AssignmentQuestionnaire.find_by(assignment_id: @assignment.id, questionnaire_id: questionnaire.id).used_in_round
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
    # this is the variable which contains the summation of differences between weighted self review and weighted peer review averages
    # the weighted averages are calculated in model vm_question_response_score_cell and the values are summed up in add_answer method
    @aggregate_self_review_composite_score = 0
  end

  attr_reader :name

  def add_questions(questions)
    questions.each do |question|
      # Get the maximum score for this question. For some unknown, godforsaken reason, the max
      # score for the question is stored not on the question, but on the questionnaire. Neat.
      corresponding_questionnaire = Questionnaire.find_by(id: question.questionnaire.id)
      question_max_score = corresponding_questionnaire.max_question_score
      # if this question is a header (table header, section header, column header), ignore this question
      unless question.is_a? QuestionnaireHeader
        row = VmQuestionResponseRow.new(question.txt, question.id, question.weight, question_max_score, question.seq)
        @list_of_rows << row
      end
    end
  end

  def add_reviews(participant, team, vary)
    if @questionnaire_type == "ReviewQuestionnaire"
      reviews = if vary
                  ReviewResponseMap.get_responses_for_team_round(team, @round)
                else
                  ReviewResponseMap.get_assessments_for(team)
                end
      # This gets the self review scores that are saved as the part of self assesing that a user performs after submission
      # Here the data will be nil, if no self review is done by the user.
      self_reviews = SelfReviewResponseMap.get_assessments_for(team)

      reviews.each do |review|
        review_mapping = ReviewResponseMap.find(review.map_id)
        if review_mapping.present?
          participant = Participant.find(review_mapping.reviewer_id)
          @list_of_reviewers << participant
        end
      end
      @list_of_reviews = reviews
      # the self reviews that are returned by the self review response map is stored here to which add_answer is called to store the marks
      @self_reviews = self_reviews
    elsif @questionnaire_type == "AuthorFeedbackQuestionnaire"
      reviews = participant.feedback # feedback reviews
      reviews.each do |review|
        review_mapping = FeedbackResponseMap.where(id: review.map_id).first
        participant = Participant.find(review_mapping.reviewer_id)
        @list_of_reviewers << participant
        @list_of_reviews << review
      end
    elsif @questionnaire_type == "TeammateReviewQuestionnaire"
      reviews = participant.teammate_reviews
      reviews.each do |review|
        review_mapping = TeammateReviewResponseMap.where(id: review.map_id).first
        participant = Participant.find(review_mapping.reviewer_id)
        # commenting out teamreviews. I just realized that teammate reviews are hidden during the current semester,
        # and I don't know how to implement the logic, so I'm being safe.
        @list_of_reviewers << participant
        @list_of_reviews << review
      end
    elsif @questionnaire_type == "MetareviewQuestionnaire"
      reviews = participant.metareviews
      reviews.each do |review|
        review_mapping = MetareviewResponseMap.where(id: review.map_id).first
        participant = Participant.find(review_mapping.reviewer_id)
        @list_of_reviewers << participant
        @list_of_reviews << review
      end
    end

    reviews.each do |review|
      answers = Answer.where(response_id: review.response_id)
      answers.each do |answer|
        #add answer signature is changed to cater to both peer review and self review.
        add_answer(answer,"ResponseReview")
      end
    end

    # Adding answers to self review object for each questions in the questionnaires
     if self_reviews
      answers = Answer.where(response_id: self_reviews[0].response_id)
      answers.each do |answer|
        add_answer(answer,"SelfReview")
      end
    end
   
  end

  def display_team_members
    @output = ""
    if @questionnaire_type == "MetareviewQuestionnaire" || @questionnaire_type == "ReviewQuestionnaire"
      @output = "Team members:"
      @list_of_team_participants.each do |participant|
        @output = @output + " (" + participant.fullname + ") "
      end

    end

    @output
  end

  def add_team_members(team)
    @list_of_team_participants = team.participants
  end

  def listofteamparticipants
    @list_of_team_participants
  end

  attr_reader :max_score

  def max_score_for_questionnaire
    @max_score * @list_of_rows.length
  end

  def max_score_for_questionnaire
    @max_score * @list_of_rows.length
  end

  attr_reader :rounds

  attr_reader :round

  attr_reader :questionnaire_type

  attr_reader :questionnaire_display_type

  attr_reader :list_of_reviews

  attr_reader :self_reviews

  attr_reader :list_of_rows

  attr_reader :list_of_reviewers

  attr_reader :aggregate_self_review_composite_score

  # This finds the total computed composite score by summing up all the self review scores that are computed in VmQuestionResponseRow
  # and gives a percentage value by averaging it with the number of questions
  def computed_self_review_score
   total_self_review_composite_score =0
   if @list_of_rows.length > 0
    total_self_review_composite_score = @aggregate_self_review_composite_score * 100 / @list_of_rows.length
   end
  total_self_review_composite_score.round(2)
  end

  # Add answer method should be taking care of both self review and peer review
  # the type of review is sent to this method to take care of both these reviews
  def add_answer(answer,review_type)
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
        color_code_number = 1 if color_code_number == 0
      end

      # Find out the tag prompts assosiated with the question
      tag_deps = TagPromptDeployment.where(questionnaire_id: @questionnaire.id, assignment_id: @assignment.id)
      vm_tag_prompts = []

      question = Question.find(answer.question_id)

      # check if the tag prompt applies for thsi question type and if the comment length is above the threshold
      # if it does, then associate this answer with the tag_prompt and tag deployment (the setting)
      tag_deps.each do |tag_dep|
        if tag_dep.question_type == question.type and answer.comments.length > tag_dep.answer_length_threshold
          vm_tag_prompts.append(VmTagPromptAnswer.new(answer, TagPrompt.find(tag_dep.tag_prompt_id),tag_dep))
        end
      end
      # end tag_prompt code

      # Now construct the color code and we're good to go!
      color_code = "c#{color_code_number}"

      # Depending upon the type of review, the score generation has to take place. If the review is of type response, it pushes the 
      # peer review scores in the array for each question. If it is of type self review, then the scores are saved in a parameter called
      # self_review_score for each record and also the summation of these values are saved for later use.
      if review_type == "ResponseReview"
      row.score_row.push(VmQuestionResponseScoreCell.new(answer.answer, color_code, answer.comments, vm_tag_prompts))
      else
      row.self_review_score = VmQuestionResponseScoreCell.new(answer.answer, color_code, answer.comments, vm_tag_prompts)
      @aggregate_self_review_composite_score += row.weighted_diff_for_row
      end
    end
  end

  def get_number_of_comments_greater_than_10_words
    first_time = true
    
    @list_of_reviews.each do |review|
      answers = Answer.where(response_id: review.response_id)
      answers.each do |answer|
        @list_of_rows.each do |row|
          if row.question_id == answer.question_id && answer.comments && answer.comments.split.size > 10
            row.countofcomments = row.countofcomments + 1
          end
        end
      end
    end
  end
end
