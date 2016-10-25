require 'rails_helper'

describe Answer do

	describe "#test get total score" do
			let!(:questionnaire) {create(:questionnaire)}
			let!(:question1) {create(:question,:questionnaire => questionnaire)}
			let!(:response_record) {create(:response_record,:id => 1)}
			
			it "returns total score when required conditions are met" do
				# stub for ScoreView.find_by_sql to revent prevent unit testing sql db queries
				ScoreView.stub(:find_by_sql).and_return([double("scoreview",weighted_score: 2,sum_of_weights: 10,q1_max_question_score: 5)])
				Answer.stub(:where).and_return([double("row1",question_id: 1,answer: "1")])
				expect(Answer.get_total_score(response: [response_record], questions: [question1])).to be 4.0
				#calculation = (weighted_score / (sum_of_weights * max_question_score)) * 100
				# 4.0
			end

			it "returns total score when answer is nil and question is scored where sum of weights becomes < 0" do
				ScoreView.stub(:find_by_sql).and_return([double("scoreview",weighted_score: 2,sum_of_weights: 0,q1_max_question_score: 5)])
				Answer.stub(:where).and_return([double("row1",question_id: 1,answer: nil)])
				expect(Answer.get_total_score(response: [response_record], questions: [question1])).to be -1.0
			end
	end
	
end
