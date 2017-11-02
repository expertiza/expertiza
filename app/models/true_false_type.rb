class TrueFalseType

	@question_type = "TrueFalse"

	def update_option_type(quiz_question_choice,parameters,question_id,option_number)
		if parameters[:quiz_question_choices][question_id.to_s][@question_type][1.to_s][:iscorrect] == "True" # the statement is correct
            if quiz_question_choice.txt == "True"
                quiz_question_choice.update_attributes(iscorrect: '1') # the statement is correct so "True" is the right answer
            else
                quiz_question_choice.update_attributes(iscorrect: '0')
            end
        else # the statement is not correct
            if quiz_question_choice.txt == "True"
                quiz_question_choice.update_attributes(iscorrect: '0')
            else
                quiz_question_choice.update_attributes(iscorrect: '1') # the statement is not correct so "False" is the right answer
            end
        end
	end

end