require 'rails_helper'

RSpec.describe ScoreCalculationHelper, type: :helper do
  include ScoreCalculationHelper

  describe '#weighted_score' do
    it 'calculates the correct weighted score with valid inputs' do
      scores = [80, 90, 100]
      weights = [1, 2, 3]
      expect(weighted_score(scores, weights)).to eq((80 * 1 + 90 * 2 + 100 * 3) / 6.0)
    end

    it 'returns 0 when all scores are 0' do
      scores = [0, 0, 0]
      weights = [1, 2, 3]
      expect(weighted_score(scores, weights)).to eq(0.0)
    end

    it 'handles cases where weights are equal' do
      scores = [80, 90, 100]
      weights = [1, 1, 1]
      expect(weighted_score(scores, weights)).to eq(90.0)
    end
  end

  describe '#apply_penalty' do
    it 'reduces the score by the correct percentage penalty' do
      score = 100
      penalty = 20
      expect(apply_penalty(score, penalty)).to eq(80.0)
    end

    it 'returns the same score if penalty is 0' do
      score = 100
      penalty = 0
      expect(apply_penalty(score, penalty)).to eq(100.0)
    end

    it 'returns 0 if the penalty is 100%' do
      score = 100
      penalty = 100
      expect(apply_penalty(score, penalty)).to eq(0.0)
    end

    it 'handles fractional penalties correctly' do
      score = 100
      penalty = 12.5
      expect(apply_penalty(score, penalty)).to eq(87.5)
    end

    it 'raises an error if penalty is negative' do
      score = 100
      penalty = -20
      expect { apply_penalty(score, penalty) }.to raise_error(ArgumentError)
    end
  end
end
