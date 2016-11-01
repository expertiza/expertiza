require 'rails_helper'
require 'pry'

describe 'Airbrake-1781551925379466692' do # still have problem
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

describe 'Aribrake-1805332790232222219' do
	it 'will not raise error if instance variables are not nil' do
		rc = ResponseController.new
		# http://www.rubydoc.info/github/rspec/rspec-mocks/RSpec%2FMocks%2FMessageExpectation%3Awith
		# With a stub, if the message might be received with other args as well, 
		# you should stub a default value first, 
		# and then stub or mock the same message using with to constrain to specific arguments.
		allow(@assignment).to receive(:try){}
		allow(@questionnaire).to receive(:try){}
		allow(@assignment).to receive(:try).with('id'.to_sym).and_return(1)
		allow(@questionnaire).to receive(:try).with('id'.to_sym).and_return(1)
		create(:assignment_questionnaire)
		expect{rc.send(:set_dropdown_or_scale)}.not_to raise_error(NoMethodError)
		expect(rc.send(:set_dropdown_or_scale)).to eq('dropdown')
	end

	it 'will not raise error even if instance variables are nil' do
		rc = ResponseController.new
		allow(@assignment).to receive(:try){}
		allow(@questionnaire).to receive(:try){}
		allow(@assignment).to receive(:try).with('id'.to_sym).and_return(nil)
		allow(@questionnaire).to receive(:try).with('id'.to_sym).and_return(nil)
		expect{rc.send(:set_dropdown_or_scale)}.not_to raise_error(NoMethodError)
	end
end