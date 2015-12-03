#this class, right now, represents each table in the view_team view. the intention may change.
#the important piece to note is that the @listofrows is a  list of type VmQuestionResponse_Row, which represents a row of the heatgrid table.
class VmQuestionResponse

  def initialize(max_score, questionnaire_type,question_display_type,round,rounds)
      @listofrows = []
      @listofreviewers = []
      @listofreviews = []
      @listofteamparticipants = []
      @max_score = max_score
      @questionnaire_type = questionnaire_type
      @questionnaire_display_type = question_display_type
      @rounds = rounds
      @round = round
 end

  def addQuestions(questions)
    questions.each do |question|
      # Get the maximum score for this question. For some unknown, godforsaken reason, the max
      # score for the question is stored not on the question, but on the questionnaire. Neat.
      corresponding_questionnaire = Questionnaire.find_by(id: question.questionnaire.id)
      question_max_score = corresponding_questionnaire.max_question_score
      row = VmQuestionResponseRow.new(question.txt, question.id, question.weight, question_max_score)
      @listofrows << row
    end
  end

  def addReviewers(participant,team)

    if @questionnaire_type == "ReviewQuestionnaire"
     # if @rounds = 1
     # reviews = participant.reviews()     #regular reviews
     # else
      reviews = ResponseMap.get_assessments_for_round(team ,@round,@rounds)
     # end
      reviews.each do |review|
        review_mapping = ReviewResponseMap.where(id: review.map_id).first
         if review_mapping.present?
            participant = Participant.find(review_mapping.reviewer_id)
           # #review = Response.find(id: review_mapping.review_id)
            @listofreviewers << participant
            @listofreviews << review
         end
      end
    elsif @questionnaire_type == "AuthorFeedbackQuestionnaire"
      reviews = participant.feedback()     #feedback reviews
           reviews.each do |review|
             review_mapping = FeedbackResponseMap.where(id: review.map_id).first
             participant = Participant.find(review_mapping.reviewer_id)
             @listofreviewers << participant
             @listofreviews << review
           end
    elsif @questionnaire_type == "TeammateReviewQuestionnaire"
      reviews = participant.teammate_reviews()
           reviews.each do |review|
             review_mapping = TeammateReviewResponseMap.where(id: review.map_id).first
             participant = Participant.find(review_mapping.reviewer_id)
             @listofreviewers << participant
             @listofreviews << review
           end


    elsif @questionnaire_type == "MetareviewQuestionnaire"
      reviews = participant.metareviews()
           reviews.each do |review|
             review_mapping = MetareviewResponseMap.where(id: review.map_id).first
             participant = Participant.find(review_mapping.reviewer_id)
             @listofreviewers << participant
             @listofreviews << review
           end
      end

    reviews.each do |review|
      answers = Answer.where(response_id: review.response_id)
      answers.each do |answer|
        addAnswer(answer)
      end
    end

  end

  def displayTeamMembers
    @output = ""
   if @questionnaire_type == "MetareviewQuestionnaire"  ||      @questionnaire_type == "ReviewQuestionnaire"
       @output = "Team members:"
      @listofteamparticipants.each do |participant|
         @output = @output  +  " (" + participant.fullname + ") "
      end

   end

    @output

   end

  def addTeamMembers(team)
    @listofteamparticipants = team.participants
  end

  def listofteamparticipants
    @listofteamparticipants
  end

  def max_score
    @max_score
  end

  def rounds
    @rounds
  end

  def round
    @round
  end

  def questionnaire_type
    @questionnaire_type
  end

  def questionnaire_display_type
    @questionnaire_display_type
  end

  def listofreviews
    @listofreviews
  end
  def listofrows
    @listofrows

  end

  def listofreviewers
    @listofreviewers
  end

  def addAnswer(answer)
    # We want to add each response score from this review (answer) to its corresponding
    # question row.
    @listofrows.each do |row|
      if row.question_id == answer.question_id
        # Go ahead and calculate what the color code for this score should be.
        question_max_score = row.question_max_score

        # This calculation is a little tricky. We're going to find the percentage for this score,
        # multiply it by 5, and then take the ceiling of that value to get the color code. This
        # should work for any point value except 0 (which we'll handle separately).
        color_code_number = 0
        if answer.answer.is_a? Numeric
          color_code_number = ((answer.answer.to_f / question_max_score.to_f) * 5.0).ceil

          # Color code c0 is reserved for null spaces in the table which will be gray.
          if color_code_number == 0
            color_code_number = 1
          end
        end

        # Now construct the color code and we're good to go!
        color_code = "c#{color_code_number}"
        row.score_row.push(VmQuestionResponseScoreCell.new(answer.answer, color_code, answer.comments))
      end
    end
  end

  # This is going to calculate the average of each column, store it in an array, and
  # return that array.
  def get_average_review_scores
    # First things first, initialize our array.
    average_review_scores = Array.new(@listofrows[0].score_row.length){ |i| 0.0 }

    # Now iterate over each row and sum the values in the score_row in the corresponding
    # index of our new array.
    @listofrows.each do |row|
      row.score_row.each_index do |index|
        score_value = row.score_row[index].score_value
        if (score_value.is_a? Numeric)
          average_review_scores[index] += score_value.to_f
        end
      end
    end

    # All that's left is to divide each entry by the number of questions in the
    # review, i.e., the number of rows, round it to two digits after the decimal,
    # and return it.
    average_review_scores.each_index do |index|
      average_review_scores[index] /= @listofrows.length.to_f
    end

    return average_review_scores
  end

  def get_number_of_comments_greater_than_10_words()

    first_time = true

    @listofreviews.each do |review|
      answers = Answer.where(response_id: review.response_id)
      questionnaire = review.questionnaire_by_answer(answers.first)
      answers.each do |answer|
        @listofrows.each do |row|
          if row.question_id == answer.question_id && answer.comments.to_s.length >10
            row.countofcomments =  row.countofcomments + 1
          end
        end
      end
    end
  end
end
