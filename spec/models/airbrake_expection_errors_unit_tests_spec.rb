require 'rails_helper'
require 'pry'
describe 'Airbrake-1781551925379466692' do
	it 'can deal with comment is nil' do
		questionnaire = Questionnaire.new
		qs = VmQuestionResponse.new(questionnaire, 1, 2)
		@list_of_reviews = [Response.new(id: 1)]
		@list_of_rows = [VmQuestionResponseRow.new('', 1, 1, 5, 0)]
		# Answer.where(response_id: review.response_id)
		allow(Answer).to receive(:where).with({response_id: 1}).
						 and_return([double("Answer", question_id: 1, response_id: 1, comments: nil)])
		expect{qs.get_number_of_comments_greater_than_10_words}.to raise_error(NoMethodError)
	end
end