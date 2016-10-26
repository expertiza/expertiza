require 'rails_helper'

describe Answer do

	describe "#test get total score" do
			let!(:questionnaire) {create(:questionnaire)}
			let!(:question1) {create(:question,:questionnaire => questionnaire,:weight=>1)}
			let!(:question2) {create(:question,:questionnaire => questionnaire,:weight=>2)}
			let!(:response_record) {create(:response_record,:id => 1)}
			
			it "returns total score when required conditions are met" do
				# stub for ScoreView.find_by_sql to revent prevent unit testing sql db queries
				ScoreView.stub(:find_by_sql).and_return([double("scoreview",weighted_score: 20,sum_of_weights: 5,q1_max_question_score: 4)])
				Answer.stub(:where).and_return([double("row1",question_id: 1,answer: "1")])
				expect(Answer.get_total_score(response: [response_record], questions: [question1])).to be 100.0
				#calculation = (weighted_score / (sum_of_weights * max_question_score)) * 100
				# 4.0
			end

			it "returns total score when one answer is nil for scored question and its weight gets removed from sum_of_weights" do
				ScoreView.stub(:find_by_sql).and_return([double("scoreview",weighted_score: 20,sum_of_weights: 5,q1_max_question_score: 4)])
				Answer.stub(:where).and_return([double("row1",question_id: 1,answer: nil)])
				expect(Answer.get_total_score(response: [response_record], questions: [question1])).to be_within(0.01).of(125.0)
			end			

			it "returns -1 when answer is nil for scored question which makes sum of weights = 0" do
				ScoreView.stub(:find_by_sql).and_return([double("scoreview",weighted_score: 20,sum_of_weights: 1,q1_max_question_score: 5)])
				Answer.stub(:where).and_return([double("row1",question_id: 1,answer: nil)])
				expect(Answer.get_total_score(response: [response_record], questions: [question1])).to be -1.0
			end

			it "returns -1 when weighted_score of questionnaireData is nil" do
				ScoreView.stub(:find_by_sql).and_return([double("scoreview",weighted_score: nil,sum_of_weights: 5,q1_max_question_score: 5)])
				Answer.stub(:where).and_return([double("row1",question_id: 1,answer: nil)])
				expect(Answer.get_total_score(response: [response_record], questions: [question1])).to be -1.0
			end

			
	end







	describe "submission valid?" do
		let!(:rm){create(:response_record)}


		it "Checking for when valid due date objects are passed back to @sorted_deadlines" do
			rm.id = 1
			rm.additional_comment = "Test"
			due_date1 = AssignmentDueDate.new
			due_date2 = AssignmentDueDate.new
			due_date1.due_at = Time.new-24
			due_date2.due_at = Time.new-24
			due_date1.deadline_type_id = 4
			due_date2.deadline_type_id = 2
			ResubmissionTime1, ResubmissionTime2 = Time.new-24, Time.new-48
			AssignmentDueDate.stub_chain(:where, :order).and_return(due_date1, due_date2)
			ResubmissionTime.stub_chain(:where, :order).and_return(ResubmissionTime1, ResubmissionTime2)
			expect(Answer.submission_valid?(rm)).to be nil
		end


		it "Checking when no due date objects are passed back to @sorted_deadlines" do
			rm.id = 1
			rm.additional_comment = "Test"
			AssignmentDueDate.stub_chain(:where, :order).and_return(nil)
			expect{Answer.submission_valid?(rm)}.to raise_error
		end



	end




	
end
