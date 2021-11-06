class AdviceController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    current_user_has_ta_privileges?
  end

  # Modify the advice associated with a questionnaire
  def edit_advice
    @questionnaire = Questionnaire.find(params[:id])

    @questionnaire.questions.each do |question|
      num_questions = if question.is_a?(ScoredQuestion)
                        @questionnaire.max_question_score - @questionnaire.min_question_score
                      else
                        0
                      end

      sorted_advice = question.question_advices.sort_by {|x| -x.score }
      if question.question_advices.length != num_questions or
        sorted_advice.empty? or
        sorted_advice[0].score != @questionnaire.min_question_score or
        sorted_advice[sorted_advice.length - 1] != @questionnaire.max_question_score
        #  The number of advices for this question has changed.
        QuestionnaireHelper.adjust_advice_size(@questionnaire, question)
      end
    end
  end

  # save the advice for a questionnaire
  def save_advice
    @questionnaire = Questionnaire.find(params[:id])
    begin
      unless params[:advice].nil?
        params[:advice].each_key do |advice_key|
          QuestionAdvice.update(advice_key, advice: params[:advice][advice_key.to_sym][:advice])
        end
        flash[:notice] = "The advice was successfully saved!"
      end
    rescue ActiveRecord::RecordNotFound
      render action: 'edit_advice', id: params[:id]
    end
    redirect_to action: 'edit_advice', id: params[:id]
  end
end
