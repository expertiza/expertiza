describe VmQuestionResponseRow do
  before(:each) do
    @row = VmQuestionResponseRow.new('Question for testing average score', 1, 1, 5, 1)

  end

  describe "#average_score_for_row" do
    it 'returns correct average score for all not null scores' do
      score1 = VmQuestionResponseScoreCell.new(5, '#000000', 'Not null score')
      score2 = VmQuestionResponseScoreCell.new(5, '#000000', 'Not null score')
      score3 = VmQuestionResponseScoreCell.new(0, '#000000', 'Not null score')
      scores = [score1, score2, score3]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(3.33)
    end
  end
end