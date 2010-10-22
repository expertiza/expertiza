class QuizQuestionnaire < Questionnaire
  DEFAULT_MIN_QUESTION_SCORE = 1
  DEFAULT_MAX_QUESTION_SCORE = 4
       
  def after_initialize
      self.display_type = 'Quiz' 
  end
  
  def delete        
    self.questions.each{
      | question |
        question.delete        
    }

    self.destroy      
  end
  
  def get_participant_by_user_id(the_user_id)
    Participant.find_by_user_id_and_quiz_id(the_user_id, id)
  end
end
