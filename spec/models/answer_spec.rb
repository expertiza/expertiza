require 'rails_helper'

describe Answer do

	describe "#test get total score" do
			let!(:questionnaire) {create(:questionnaire)}
			let!(:question1) {create(:question,:questionnaire => questionnaire,:weight=>1)}
			let!(:question2) {create(:question,:questionnaire => questionnaire,:weight=>2)}
			let!(:response_record) {create(:response_record,:id => 1)}
			
			it "returns total score when required conditions are met" do
				# stub for ScoreView.find_by_sql to revent prevent unit testing sql db queries
				ScoreView.stub(:find_by_sql).and_return([double("scoreview",weighted_score: 20,sum_of_weights: 5,q1_max_question_score: 5)])
				Answer.stub(:where).and_return([double("row1",question_id: 1,answer: "1")])
				expect(Answer.get_total_score(response: [response_record], questions: [question1])).to be 80.0
				#calculation = (weighted_score / (sum_of_weights * max_question_score)) * 100
				# 4.0
			end

			it "returns total score when one answer is nil for scored question and its weight gets removed from sum_of_weights" do
				ScoreView.stub(:find_by_sql).and_return([double("scoreview",weighted_score: 20,sum_of_weights: 5,q1_max_question_score: 5)])
				Answer.stub(:where).and_return([double("row1",question_id: 1,answer: nil)])
				expect(Answer.get_total_score(response: [response_record], questions: [question1])).to be_within(0.01).of(100.0)
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
	
end
