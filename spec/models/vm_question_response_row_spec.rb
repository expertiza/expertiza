describe VmQuestionResponseRow do
  before(:each) do
    @row = VmQuestionResponseRow.new('Question for testing average score', 1, 1, 5, 1)
  end

  describe "#average_score_for_row" do
    it 'returns correct average score for all not null scores' do
      score1 = VmQuestionResponseScoreCell.new(1, '#000000', 'score value=1')
      score2 = VmQuestionResponseScoreCell.new(2, '#000000', 'score value=2')
      score3 = VmQuestionResponseScoreCell.new(0, '#000000', 'Not null score')
      scores = [score1, score2, score3]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(1)
    end

    it 'returns correct average score for all not null scores' do
      score1 = VmQuestionResponseScoreCell.new(5, '#000000', 'Maximum possible score for 1st question')
      score2 = VmQuestionResponseScoreCell.new(5, '#000000', 'Maximum possible score for 2nd question')
      score3 = VmQuestionResponseScoreCell.new(5, '#000000', 'Maximum possible score for 3rd question')
      scores = [score1, score2, score3]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(5)
    end

    it 'returns correct average score for all not null zero scores' do
      score1 = VmQuestionResponseScoreCell.new(0, '#000000', 'All zero score')
      score2 = VmQuestionResponseScoreCell.new(0, '#000000', 'All zero score')
      score3 = VmQuestionResponseScoreCell.new(0, '#000000', 'All zero score')
      scores = [score1, score2, score3]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(0)
    end

    it 'returns correct average score for mixture of nil & not nil scores' do
      score1 = VmQuestionResponseScoreCell.new(2, '#000000', 'not null score')
      score2 = VmQuestionResponseScoreCell.new(4, '#000000', 'not null score')
      score3 = VmQuestionResponseScoreCell.new(nil, '#000000', 'null score')
      scores = [score1, score2, score3]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(3)
    end

    it 'returns correct average score for mixture of nil & not nil scores' do
      score1 = VmQuestionResponseScoreCell.new(5, '#000000', 'not null score')
      score2 = VmQuestionResponseScoreCell.new(nil, '#000000', 'null score')
      score3 = VmQuestionResponseScoreCell.new(nil, '#000000', 'null score')
      scores = [score1, score2, score3]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(5)
    end

    it 'returns correct average score for mixture of nil, not nil and 0 scores' do
      score1 = VmQuestionResponseScoreCell.new(5, '#000000', 'not null score')
      score2 = VmQuestionResponseScoreCell.new(0, '#000000', 'not null score')
      score3 = VmQuestionResponseScoreCell.new(nil, '#000000', 'null score')
      scores = [score1, score2, score3]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(2.5)
    end

    it 'returns correct average score for all nil scores' do
      score1 = VmQuestionResponseScoreCell.new(nil, '#000000', 'null score')
      score2 = VmQuestionResponseScoreCell.new(nil, '#000000', 'null score')
      scores = [score1, score2]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(nil)
    end

    it 'returns correct average score for mixture of not null and nil ' do
      score1 = VmQuestionResponseScoreCell.new(nil, '#000000', 'null score')
      score2 = VmQuestionResponseScoreCell.new(nil, '#000000', 'null score')
      score3 = VmQuestionResponseScoreCell.new(0, '#000000', 'not null score')
      score4 = VmQuestionResponseScoreCell.new(nil, '#000000', 'not null score')
      score5 = VmQuestionResponseScoreCell.new(nil, '#000000', 'null score')
      scores = [score1, score2, score3, score4, score5]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(0)
    end

    it 'returns correct average score for mixture of not null and nil ' do
      score1 = VmQuestionResponseScoreCell.new(0, '#000000', 'not null score')
      score2 = VmQuestionResponseScoreCell.new(5, '#000000', 'not null score')
      score3 = VmQuestionResponseScoreCell.new(0, '#000000', 'not null score')
      score4 = VmQuestionResponseScoreCell.new(4, '#000000', 'not null score')
      score5 = VmQuestionResponseScoreCell.new(nil, '#000000', 'null score')
      scores = [score1, score2, score3, score4, score5]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(2.25)
    end
  end
end