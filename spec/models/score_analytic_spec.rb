class ScoreAnalyticTestDummyClass
  attr_accessor :comments
  require 'analytic/score_analytic'
  include ScoreAnalytic
  def initialize(comments)
    @comments = comments
  end
end

describe ScoreAnalytic do
  describe '#unique_character_count' do
    it 'returns the unique number of characters' do
      satdc = ScoreAnalyticTestDummyClass.new('a b c')
      expect(satdc.unique_character_count).to eq(3)
    end
  end
  describe '#character_count' do
    it 'returns the number of characters' do
      satdc = ScoreAnalyticTestDummyClass.new('a b c')
      expect(satdc.character_count).to eq(5)
    end
  end
  describe '#word_count' do
    it 'returns the number of words' do
      satdc = ScoreAnalyticTestDummyClass.new('hello world')
      expect(satdc.word_count).to eq(2)
    end
  end
end
