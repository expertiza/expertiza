class MultipleChoiceRadioType
	
	@question_type = "MultipleChoiceRadio"

	def update_option_type(quiz_question_choice,parameters,question_id,option_number)
		puts "SSZ 1: #{parameters}"
		puts "SSZ 1: #{parameters[:quiz_question_choices]}"
		puts "SSZ 1: #{parameters[:quiz_question_choices][question_id.to_s]}"
		puts "SSZ 1: #{parameters[:quiz_question_choices][question_id.to_s][@question_type]}"
		puts "SSZ 1: #{parameters[:quiz_question_choices][question_id.to_s][@question_type][:correctindex]}"

		if parameters[:quiz_question_choices][question_id.to_s][@question_type][:correctindex] == option_number.to_s
            quiz_question_choice.update_attributes(iscorrect: '1', txt: parameters[:quiz_question_choices][question_id.to_s][@question_type][option_number.to_s][:txt])
        else
            quiz_question_choice.update_attributes(iscorrect: '0', txt: parameters[:quiz_question_choices][question_id.to_s][@question_type][option_number.to_s][:txt])
        end
	end
end