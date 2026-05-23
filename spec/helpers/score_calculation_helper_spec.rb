require 'rails_helper'

RSpec.describe ScoreCalculationHelper, type: :helper do
  include ScoreCalculationHelper

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
