class VmQuestionResponse

  def initialize()
      @listofrows = []
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
        color_code = "c" + color_code_number
        
        row.score_row.push(VmQuestionResponseScoreCell.new(answer.answer, color_code))
      end
    end
  end
  
end
