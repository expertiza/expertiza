class AdviceController < ApplicationController
  include AuthorizationHelper
  # If current user is TA then only current user can edit and update the advice
  def action_allowed?
    current_user_has_ta_privileges?
  end

  # Modify the advice associated with a questionnaire
  def edit_advice
    #Stores the questionnaire with given id in URL
    @questionnaire = Questionnaire.find(params[:id])

    # For each question in a quentionnaire, this method adjusts the advice size if the advice size is <,> nummber of advices or 
    #the max or min score of the advices does not correspond to the max or min score of questionnaire respectively  
    @questionnaire.questions.each do |question|

      #if the question is a scored question, store the number of advices corresponsing to that question (max_score - min_score), else 0
      num_questions = if question.is_a?(ScoredQuestion)  #bug -> num_questions should be num_advices
                        @questionnaire.max_question_score - @questionnaire.min_question_score   #bug -> should add +1
                      else
                        0
                      end

      #sorting question advices in descending order by score
      sorted_advice = question.question_advices.sort_by { |x| -x.score }

      #Checks the condition for adjusting the advice size
      next unless (question.question_advices.length != num_questions) ||
                  sorted_advice.empty? ||
                  (sorted_advice[0].score != @questionnaire.min_question_score) || #bug -> should match with max_question_score 
                  (sorted_advice[sorted_advice.length - 1] != @questionnaire.max_question_score) #bug -> should match with min_question_score 

      #  The number of advices for this question has changed.
      QuestionnaireHelper.adjust_advice_size(@questionnaire, question)
    end
  end

  # save the advice for a questionnaire
  def save_advice
    #Stores the questionnaire with given id in URL
    @questionnaire = Questionnaire.find(params[:id])
    begin
      # checks if advice is present or not
      unless params[:advice].nil?
        params[:advice].each_key do |advice_key|
          QuestionAdvice.update(advice_key, advice: params[:advice][advice_key.to_sym][:advice])  #Updates the advice corresponding to the key
        end
        flash[:notice] = 'The advice was successfully saved!'
      end
    rescue ActiveRecord::RecordNotFound
      render action: 'edit_advice', id: params[:id]   #If record not found, redirects to edit_advice
    end
    redirect_to action: 'edit_advice', id: params[:id]
  end
end
