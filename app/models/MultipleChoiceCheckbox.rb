class MultipleChoiceCheckbox

	@question_type = "MultipleChoiceCheckbox"

	def update_attributes(quiz_question_choice,parameters,question_id,option_number)
		#parameters[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s]
		if parameters[:quiz_question_choices][question_id.to_s][@question_type][option_number.to_s]
            quiz_question_choice.update_attributes(iscorrect: params[:quiz_question_choices][question_id.to_s][@question_type][option_number.to_s][:iscorrect], txt: params[:quiz_question_choices][question_id.to_s][@question_type][option_number.to_s][:txt])
        else
            quiz_question_choice.update_attributes(iscorrect: '0', txt: params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
        end
	end

end