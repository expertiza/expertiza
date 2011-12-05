class QuestionAdviceController < ApplicationController

  def updateAdvice
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
  def create
    updateAdvice
  end

  def save
    puts "in save in question_advice"
    begin
      for advice_key in params[:question_advice].keys
        QuestionAdvice.update(advice_key, params[:question_advice][advice_key])
      end
      flash[:notice] = "The questionnaire's question advice was successfully saved"
      redirect_to :controller => 'tree_display', :action => 'list'

    rescue ActiveRecord::RecordNotFound
      render :action => 'edit_advice'
    end
  end

  def edit
    updateAdvice
  end

  def delete
  end

end
