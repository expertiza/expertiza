require "rails_helper"

describe ReviewMetricsQuery do
  let!(:assignment) { create(:assignment, name: 'Assignment 101') }
  let!(:team_1) { create(:assignment_team) }
  let!(:questionnaire) { create(:questionnaire) }
  let!(:question_1) { create(:question, questionnaire: questionnaire, weight: 1, type: "Criterion") }
  let!(:question_2) { create(:question, questionnaire: questionnaire, weight: 1, type: "Criterion") }
  let!(:response_map_1) { create(:review_response_map, reviewee: team_1, assignment: assignment) }
  let!(:response_1) { create(:response, response_map: response_map_1, is_submitted: true, round: 1) }
  let!(:answer_1) { create(:answer, question: question_1, response: response_1) }
  let!(:answer_2) { create(:answer, question: question_2, response: response_1) }
  let!(:response_map_2) { create(:review_response_map, reviewee: team_1, assignment: assignment) }
  let!(:response_2) { create(:response, response_map: response_map_2, is_submitted: true, round: 2) }
  let!(:answer_3) { create(:answer, question: question_1, response: response_2) }

  before(:each) do
    queried_results = {'problem' => [{'id' => answer_1.id, 'problems' => 'Absent'},
                                     {'id' => answer_2.id, 'problems' => 'Present'}],
                       'problem_confidence' => [{'id' => answer_1.id, 'confidence' => 0.1},
                                                {'id' => answer_2.id, 'confidence' => 0.7}],
                       'sentiment' => [{'id' => answer_1.id, 'sentiment_tone' => 'Positive'},
                                       {'id' => answer_2.id, 'sentiment_tone' => 'Mixed'}],
                       'sentiment_confidence' => [{'id' => answer_1.id, 'confidence' => 1},
                                                  {'id' => answer_2.id, 'confidence' => 0}]}
    ReviewMetricsQuery.instance.instance_variable_set(:@queried_results, queried_results)
  end

  describe 'confidence' do
    it 'returns the confidence value of a particular answer tag' do
      prompt_message = 'Mention Problems?'
      confidence = ReviewMetricsQuery.confidence(prompt_message, answer_2.id)
      expect(confidence).to eq(0.7)
    end
    it 'returns the flipped confidence value when the determined value is Absent' do
      prompt_message = 'Mention Problems?'
      confidence = ReviewMetricsQuery.confidence(prompt_message, answer_1.id)
      expect(confidence).to eq(0.9)
    end
    it 'returns 0 if there is no corresponding metric for the input tag' do
      prompt_message = 'DNE'
      confidence = ReviewMetricsQuery.confidence(prompt_message, answer_1.id)
      expect(confidence).to eq(0)
    end
  end

  describe 'has' do
    it 'returns the predicted value of a particular answer tag' do
      prompt_message = 'Mention Problems?'
      value = ReviewMetricsQuery.has(prompt_message, answer_2.id)
      expect(value).to be true
      prompt_message = 'Mention Praise?'
      value = ReviewMetricsQuery.has(prompt_message, answer_2.id)
      expect(value).to be false
    end
    it 'returns false if there is no corresponding metric for the input tag' do
      prompt_message = 'DNE'
      confidence = ReviewMetricsQuery.has(prompt_message, answer_1.id)
      expect(confidence).to be false
    end
  end

  describe 'cache_ws_results' do
    it 'calls web service when the look-up value has not been cached to local' do
      expect_any_instance_of(ReviewMetricsQuery).to receive(:cache_ws_results).and_return(nil)
      prompt_message = 'Suggest Solutions?'
      ReviewMetricsQuery.confidence(prompt_message, answer_1.id)
    end
  end

  describe 'reviews_to_be_cached' do
    it 'finds all other reviews under the same ReviewResponseMap as the input review' do
      reviews = ReviewMetricsQuery.instance.reviews_to_be_cached(answer_1.id)
      expect(reviews.count).to eq(3)
    end

    it 'finds reviews for the round that the input review is in' do
      allow_any_instance_of(Assignment).to receive(:varying_rubrics_by_round?).and_return(true)
      reviews = ReviewMetricsQuery.instance.reviews_to_be_cached(answer_1.id)
      expect(reviews.count).to eq(2)
      reviews = ReviewMetricsQuery.instance.reviews_to_be_cached(answer_3.id)
      expect(reviews.count).to eq(1)
    end
  end
end
