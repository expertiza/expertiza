require 'rails_helper'

RSpec.describe GradesHelper, type: :helper do
  describe '#accordion_title' do
    context 'when last_topic is nil' do
      it 'renders the first accordion with is_first set to true' do
        expect(helper).to receive(:render).with(partial: 'response/accordion', locals: { title: 'new_topic', is_first: true })
        helper.accordion_title(nil, 'new_topic')
      end
    end

    context 'when last_topic is not equal to new_topic' do
      it 'renders a new accordion with is_first set to false' do
        expect(helper).to receive(:render).with(partial: 'response/accordion', locals: { title: 'new_topic', is_first: false })
        helper.accordion_title('old_topic', 'new_topic')
      end
    end

    context 'when last_topic is equal to new_topic' do
      it 'does not render an accordion' do
        expect(helper).not_to receive(:render)
        helper.accordion_title('same_topic', 'same_topic')
      end
    end
  end

  describe '#score_vector' do
    let(:reviews) { [double('Review')] }
    let(:questions) { { some_question: double('Question') } }

    before do
      allow(Response).to receive(:assessment_score).and_return(3)
    end

    it 'calls Response.assessment_score for each review and returns an array of scores' do
      expect(Response).to receive(:assessment_score).with(response: reviews, questions: questions, q_types: [])
      scores = helper.score_vector(reviews, :some_question)
      expect(scores).to eq([3])
    end
  end

  describe '#charts' do
    let(:participant_score) { { some_symbol: { assessments: [double('Review')] } } }

    before do
      allow(helper).to receive(:score_vector).and_return([3, -1, 5])
      allow(GradesController).to receive(:bar_chart).and_return('chart')
    end

    it 'calls score_vector with the assessments for the given symbol and removes negative scores' do
      expect(helper).to receive(:score_vector).with(participant_score[:some_symbol][:assessments], 'some_symbol').and_return([3, 5])
      helper.charts(:some_symbol)
    end

    it 'calls GradesController.bar_chart with the array of scores and assigns the result to @grades_bar_charts' do
      expect(helper).to receive(:score_vector).with(participant_score[:some_symbol][:assessments], 'some_symbol').and_return([3, 5])
      expect(GradesController).to receive(:bar_chart).with([3, 5]).and_return('chart')
      helper.charts(:some_symbol)
      expect(helper.instance_variable_get(:@grades_bar_charts)).to eq('chart')
    end
  end
end
