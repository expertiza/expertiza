class MultipleChoiceRadioType
	
	def initialize
    	@question_type = "MultipleChoiceRadio"
  	end

	def update_option_type(quiz_question_choice,parameters,question_id,option_number)
		if parameters[:quiz_question_choices][question_id.to_s][@question_type][:correctindex] == option_number.to_s
            quiz_question_choice.update_attributes(iscorrect: '1', txt: parameters[:quiz_question_choices][question_id.to_s][@question_type][option_number.to_s][:txt])
        else
            quiz_question_choice.update_attributes(iscorrect: '0', txt: parameters[:quiz_question_choices][question_id.to_s][@question_type][option_number.to_s][:txt])
        end
	end
end