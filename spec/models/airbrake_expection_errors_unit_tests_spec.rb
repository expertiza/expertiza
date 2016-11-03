require 'rails_helper'
require 'pry'
describe 'Airbrake-1781551925379466692' do
	before(:each) do
		questionnaire = Questionnaire.new
		@qs = VmQuestionResponse.new(questionnaire, 1, 2)
		#@list_of_reviews = [Response.new(id: 1)]
		@qs.instance_variable_set(:@list_of_reviews, [instance_double('Response', response_id: 1)])
	end

	it 'can deal with comment is not nil' do
		#@list_of_rows = [VmQuestionResponseRow.new('', 1, 1, 5, 0)]
		@qs.instance_variable_set(:@list_of_rows, [instance_double('VmQuestionResponseRow', 
																	questionText: '', 
																	question_id: 1, 
																	weight: 1, 
																	question_max_score: 5, seq: 0)])
		allow(Answer).to receive(:where).with(any_args).
						 and_return([double("Answer", question_id: 1, response_id: 1, comments: 'hehe')])
		expect{@qs.get_number_of_comments_greater_than_10_words}.not_to raise_error(NoMethodError)
	end

	it 'can deal with comment is nil' do
		@qs.instance_variable_set(:@list_of_rows, [instance_double('VmQuestionResponseRow', 
																	questionText: '', 
																	question_id: 1, 
																	weight: 1, 
																	question_max_score: 5, seq: 0)])
		allow(Answer).to receive(:where).with(any_args).
						 and_return([double("Answer", question_id: 1, response_id: 1, comments: nil)])

		expect{@qs.get_number_of_comments_greater_than_10_words}.not_to raise_error(NoMethodError)
	end
end