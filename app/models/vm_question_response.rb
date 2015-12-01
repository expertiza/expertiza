#this class, right now, represents each table in the view_team view. the intention may change.
#the important piece to note is that the @listofrows is a  list of type VmQuestionResponse_Row, which represents a row of the heatgrid table.
class VmQuestionResponse

  def initialize()
      @listofrows = []
      @listofreviewers = []
      @listofreviews = []
      @listofteamparticipants = []

  end

  def addQuestions(questions)
    questions.each do |question|
      row = VmQuestionResponseRow.new(question.txt, question.id, question.weight)
      @listofrows << row
    end
  end

  def listofrows
    @listofrows
  end

  def addAnswer(answer)
    # We want to add each response score from this review (answer) to its corresponding
    # question row.
    @listofrows.each do |row|
      if row.question_id == answer.question_id
        # Go ahead and calculate what the color code for this score should be.
        question_max_score = row.weight
      
        # This calculation is a little tricky. We're going to find the percentage for this score,
        # multiply it by 5, and then take the ceiling of that value to get the color code. This
        # should work for any point value except 0 (which we'll handle separately).
        color_code_number = (answer.answer / question_max_score) * 5.ceil
      
        # If the color_code_number is 0, just make it 1. Our color codes are only c1-c5.
        if color_code_number == 0
          color_code_number = 1
        end
      
        # Now construct the color code and we're good to go!
        color_code = "c#{color_code_number}"
        
        row.score_row.push(VmQuestionResponseScoreCell.new(answer.answer, color_code))
      end
    end
  end


  def addReviewers(reviews, responseType)
    if responseType == "ReviewQuestionnaire"
      reviews.each do |review|
        review_mapping = ReviewResponseMap.where(id: review.map_id).first
        participant = Participant.find(review_mapping.reviewer_id)
        @listofreviewers << participant
        @listofreviews << review
      end
    elsif responseType == "AuthorFeedbackQuestionnaire"
           reviews.each do |review|
             review_mapping = FeedbackResponseMap.where(id: review.map_id).first
             participant = Participant.find(review_mapping.reviewer_id)
             @listofreviewers << participant
             @listofreviews << review
           end
     elsif responseType == "TeammateReviewQuestionnaire"
           reviews.each do |review|
             review_mapping = TeammateReviewResponseMap.where(id: review.map_id).first
             participant = Participant.find(review_mapping.reviewer_id)
             @listofreviewers << participant
             @listofreviews << review
           end


      elsif responseType == "MetareviewQuestionnaire"
           reviews.each do |review|
             review_mapping = MetareviewResponseMap.where(id: review.map_id).first
             participant = Participant.find(review_mapping.reviewer_id)
             @listofreviewers << participant
             @listofreviews << review
           end
         end




  end

  def addTeamMembers(team)
    @listofteamparticipants = team.participants
  end

  def listofteamparticipants
    @listofteamparticipants
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
        ##question_max_score = row.weight

        # This calculation is a little tricky. We're going to find the percentage for this score,
        # multiply it by 5, and then take the ceiling of that value to get the color code. This
        # should work for any point value except 0 (which we'll handle separately).
        ##color_code_number = (answer.answer / question_max_score) * 5.ceil

        # If the color_code_number is 0, just make it 1. Our color codes are only c1-c5.
        ##if color_code_number == 0
        ##  color_code_number = 1
        ##end

        # Now construct the color code and we're good to go!
        ##color_code = "c#{color_code_number}"
         color_code = "c0"
        row.score_row.push(VmQuestionResponseScoreCell.new(answer.answer, color_code))
      end
    end
  end
end
