require 'rails_helper'

describe CompletedReviewCounterService do
  describe '.count_reviews' do
    let(:submitted_response)   { double('Response', is_submitted: true) }
    let(:unsubmitted_response) { double('Response', is_submitted: false) }

    context 'when all reviews are submitted' do
      let(:reviews) do
        [
          double('ReviewMap', response: [submitted_response]),
          double('ReviewMap', response: [submitted_response])
        ]
      end

      it 'returns the correct count' do
        count = described_class.count_reviews(reviews)
        expect(count).to eq(2)
      end
    end

    context 'when some reviews are not submitted' do
      let(:reviews) do
        [
          double('ReviewMap', response: [submitted_response]),
          double('ReviewMap', response: [unsubmitted_response])
        ]
      end

      it 'counts only submitted reviews' do
        count = described_class.count_reviews(reviews)
        expect(count).to eq(1)
      end
    end

    context 'when reviews have empty responses' do
      let(:reviews) do
        [
          double('ReviewMap', response: []),
          double('ReviewMap', response: [submitted_response]),
          double('ReviewMap', response: [])
        ]
      end

      it 'ignores reviews with no responses' do
        count = described_class.count_reviews(reviews)
        expect(count).to eq(1)
      end
    end

    context 'when reviews are completely empty' do
      let(:reviews) { [] }

      it 'returns zero' do
        count = described_class.count_reviews(reviews)
        expect(count).to eq(0)
      end
    end
  end
end
