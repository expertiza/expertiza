require "rails_helper"

describe ReviewMetricsQuery do
  let!(:assignment) { create(:assignment, name: 'Assignment 101') }
  let!(:questionnaire) { create(:questionnaire) }
  let!(:answer) { create(:answer) }
  let!(:tag_prompt_1) { create(:tag_prompt, prompt: "Mention Problems?") }
  let!(:tag_prompt_2) { create(:tag_prompt, prompt: "Suggest Solutions?") }
  let!(:tag_prompt_3) { create(:tag_prompt, prompt: "Mention Praise?") }
  let!(:tag_prompt_4) { create(:tag_prompt, prompt: "Positive Tone?") }
  let!(:tag_prompt_deployment_1) { create(:tag_prompt_deployment, assignment: assignment, questionnaire: questionnaire, tag_prompt: tag_prompt_1) }
  let!(:tag_prompt_deployment_2) { create(:tag_prompt_deployment, assignment: assignment, questionnaire: questionnaire, tag_prompt: tag_prompt_2) }
  let!(:tag_prompt_deployment_3) { create(:tag_prompt_deployment, assignment: assignment, questionnaire: questionnaire, tag_prompt: tag_prompt_3) }
  let!(:tag_prompt_deployment_4) { create(:tag_prompt_deployment, assignment: assignment, questionnaire: questionnaire, tag_prompt: tag_prompt_4) }
  let!(:answer_tag_1) { create(:answer_tag, tag_prompt_deployment: tag_prompt_deployment_1, value: 1, confidence_level: 0.2) }
  let!(:answer_tag_2) { create(:answer_tag, tag_prompt_deployment: tag_prompt_deployment_2, value: 0, confidence_level: 0.9) }
  let!(:answer_tag_4) { create(:answer_tag, tag_prompt_deployment: tag_prompt_deployment_4, value: 1, confidence_level: 0.8) }

  before(:each) do
    stub_const("ReviewMetricsQuery::TAG_CERTAINTY_THRESHOLD", 0.8)
  end

  describe 'confident?' do
    it 'returns true if the confidence level is higher than or equal to the TAG_CERTAINTY_THRESHOLD' do
      expect(ReviewMetricsQuery.confident?(tag_prompt_deployment_2.id, answer.id)).to be(true)
      expect(ReviewMetricsQuery.confident?(tag_prompt_deployment_4.id, answer.id)).to be(true)
    end
    it 'returns false if the confidence level is lower than the TAG_CERTAINTY_THRESHOLD' do
      expect(ReviewMetricsQuery.confident?(tag_prompt_deployment_1.id, answer.id)).to be(false)
    end
  end

  describe 'confidence' do
    it 'returns the confidence level of certain metric prediction on the inputted answer' do
      expect(ReviewMetricsQuery.confidence(tag_prompt_deployment_2.id, answer.id)).to eq(0.9)
    end
  end

  describe 'has?' do
    it 'returns the predicted value of the inputted answer' do
      expect(ReviewMetricsQuery.has?(tag_prompt_deployment_1.id, answer.id)).to be(true)
      expect(ReviewMetricsQuery.has?(tag_prompt_deployment_2.id, answer.id)).to be(false)
    end
    it 'returns false if there is no corresponding metric for the input tag' do
      expect(ReviewMetricsQuery.has?(-1, answer.id)).to be(false)
    end
  end

  describe 'cache_ws_results' do
    before :each do
      value_output = {"reviews" => [{"id" => answer.id, "text" => answer.comments, "Praise" => "None"}]}
      confidence_output = {"reviews" => [{"id" => answer.id, "text" => answer.comments, "confidence" => 0.23}]}
      @controller = MetricsController.new
      allow(MetricsController).to receive("new").and_return(@controller).twice
      allow(MetricsController).to receive("new").and_return(@controller).twice
      allow(@controller).to receive(:bulk_retrieve_metric).with(anything, anything, false).and_return(value_output)
      allow(@controller).to receive(:bulk_retrieve_metric).with(anything, anything, true).and_return(confidence_output)
    end
    it 'calls the web service' do
      expect(@controller).to receive(:bulk_retrieve_metric).twice
      ReviewMetricsQuery.instance.cache_ws_results([answer], [tag_prompt_deployment_3], false)
    end
    it 'parses the web service results to AnswerTag objects and make them available in @queried_results' do
      ReviewMetricsQuery.instance.cache_ws_results([answer], [tag_prompt_deployment_3], false)
      parsed_answer_tag = ReviewMetricsQuery.instance.instance_variable_get(:@queried_results).find {|a| a.tag_prompt_deployment == tag_prompt_deployment_3}
      expect(parsed_answer_tag.value).to eq("-1")
      expect(parsed_answer_tag.confidence_level).to eq(0.23)
    end
    it 'saves parsed AnswerTag objects to database when cache_to_ws is set to true' do
      expect(AnswerTag.count).to eq(3)
      ReviewMetricsQuery.instance.cache_ws_results([answer], [tag_prompt_deployment_3], true)
      expect(AnswerTag.count).to eq(4)
    end
  end

  describe 'translate_value' do
    it 'translates text into value 1 or -1' do
      review = {"id" => answer.id, "text" => answer.comments, "Praise" => "None"}
      result = ReviewMetricsQuery.instance.translate_value('emotions', review)
      expect(result).to eq(-1)

      review = {"id" => answer.id, "text" => answer.comments, "sentiment_tone" => "Positive"}
      result = ReviewMetricsQuery.instance.translate_value('sentiment', review)
      expect(result).to eq(1)
    end
  end

  describe 'translate_confidence' do
    it 'flips the confidence level when the determined value is Absent' do
      review = {"id" => answer.id, "text" => answer.comments, "problems" => "Absent", "confidence" => 0.02}
      result = ReviewMetricsQuery.instance.translate_confidence('problem', review)
      expect(result).to eq(1 - 0.02)
    end
  end
end
