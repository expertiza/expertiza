class AdviceController < ApplicationController

  # Modify the advice associated with a questionnaire
  def edit_advice
    params[:id] = flash[:id]
    @questionnaire = get(Questionnaire, params[:id])

    for question in @questionnaire.questions
      if question.true_false
        num_questions = 2
      else
        num_questions = @questionnaire.max_question_score - @questionnaire.min_question_score
      end

      sorted_advice = question.question_advices.sort {|x,y| y.score <=> x.score }
      if question.question_advices.length != num_questions or
          sorted_advice[0].score != @questionnaire.min_question_score or
          sorted_advice[sorted_advice.length-1] != @questionnaire.max_question_score
        #  The number of advices for this question has changed.
        QuestionnaireHelper::adjust_advice_size(@questionnaire, question)
      end
    end
    @questionnaire = get(Questionnaire, params[:id])
  end

  # save the advice for a questionnaire
  def save_advice

    params[:id] = flash[:id]
    @questionnaire = get(Questionnaire, params[:id])

    begin
      for advice_key in params[:advice].keys
        QuestionAdvice.update(advice_key, params[:advice][advice_key])
      end
      flash[:notice] = "The questionnaire's question advice was successfully saved"
      redirect_to :action => 'list', :controller => 'questionnaire'

    rescue ActiveRecord::RecordNotFound
      render :action => 'edit_advice'
    end
  end


end
