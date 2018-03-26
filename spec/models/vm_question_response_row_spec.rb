describe VmQuestionResponseRow do
  before(:each) do
    @row = VmQuestionResponseRow.new('Question for testing average score', 1, 1, 5, 1)
  end

  describe "#average_score_for_row" do
    it 'returns correct average score for all not null scores' do
      score1 = VmQuestionResponseScoreCell.new(1, '#000000', 'Case_1_score_value1 = 1')
      score2 = VmQuestionResponseScoreCell.new(2, '#000000', 'Case_1_score_value2 = 2')
      score3 = VmQuestionResponseScoreCell.new(0, '#000000', 'Case_1_score_value3 =0')
      scores = [score1, score2, score3]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(1)
    end

    it 'returns correct average score for all not null scores' do
      score1 = VmQuestionResponseScoreCell.new(5, '#000000', 'Case_2_score_value1 = 5')
      score2 = VmQuestionResponseScoreCell.new(4, '#000000', 'Case_2_score_value2 = 4')
      score3 = VmQuestionResponseScoreCell.new(3, '#000000', 'Case_2_score_value3 = 3')
      scores = [score1, score2, score3]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(4)
    end

    it 'returns correct average score for all not null zero scores' do
      score1 = VmQuestionResponseScoreCell.new(0, '#000000', 'Case_3_score_value1 = 0')
      score2 = VmQuestionResponseScoreCell.new(0, '#000000', 'Case 3_score_value2 = 0')
      score3 = VmQuestionResponseScoreCell.new(0, '#000000', 'Case_3_score_value3 = 0')
      scores = [score1, score2, score3]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(0)
    end

    it 'returns correct average score for mixture of nil & not nil scores' do
      score1 = VmQuestionResponseScoreCell.new(2, '#000000', 'Case_4_score_value1 = 2')
      score2 = VmQuestionResponseScoreCell.new(4, '#000000', 'Case_4_score_value2 = 4')
      score3 = VmQuestionResponseScoreCell.new(nil, '#000000', 'Case_4_score_value3 = nil')
      scores = [score1, score2, score3]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(3)
    end

    it 'returns correct average score for mixture of nil & not nil scores' do
      score1 = VmQuestionResponseScoreCell.new(5, '#000000', 'Case_5_score_value1 = 5')
      score2 = VmQuestionResponseScoreCell.new(nil, '#000000', 'Case_5_score_value2 = nil')
      score3 = VmQuestionResponseScoreCell.new(nil, '#000000', 'Case_5_score_value3 = nil')
      scores = [score1, score2, score3]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(5)
    end

    it 'returns correct average score for mixture of nil, not nil and 0 scores' do
      score1 = VmQuestionResponseScoreCell.new(5, '#000000', 'Case_6_score_value1 = 5')
      score2 = VmQuestionResponseScoreCell.new(0, '#000000', 'Case_6_score_value2 = 0')
      score3 = VmQuestionResponseScoreCell.new(nil, '#000000', 'Case_6_score_value3 = nil')
      scores = [score1, score2, score3]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(2.5)
    end

    it 'returns correct average score for all nil scores' do
      score1 = VmQuestionResponseScoreCell.new(nil, '#000000', 'Case_7_score_value1 = nil')
      score2 = VmQuestionResponseScoreCell.new(nil, '#000000', 'Case_7_score_value2 = nil')
      scores = [score1, score2]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(nil)
    end

    it 'returns correct average score for mixture of not null and nil ' do
      score1 = VmQuestionResponseScoreCell.new(nil, '#000000', 'Case_8_score_value1 = nil')
      score2 = VmQuestionResponseScoreCell.new(nil, '#000000', 'Case_8_score_value2 = nil')
      score3 = VmQuestionResponseScoreCell.new(0, '#000000', 'Case_8_score_value3 = 0')
      score4 = VmQuestionResponseScoreCell.new(nil, '#000000', 'Case_8_score_value4 = nil')
      score5 = VmQuestionResponseScoreCell.new(nil, '#000000', 'Case_8_score_value5 = nil')
      scores = [score1, score2, score3, score4, score5]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(0)
    end

    it 'returns correct average score for mixture of not null and nil ' do
      score1 = VmQuestionResponseScoreCell.new(0, '#000000', 'Case_9_score_value1 = 0')
      score2 = VmQuestionResponseScoreCell.new(5, '#000000', 'Case_9_score_value2 = 5')
      score3 = VmQuestionResponseScoreCell.new(0, '#000000', 'Case_9_score_value3 = 0')
      score4 = VmQuestionResponseScoreCell.new(4, '#000000', 'Case_9_score_value4 = 4')
      score5 = VmQuestionResponseScoreCell.new(nil, '#000000', 'Case_9_score_value5 = nil')
      scores = [score1, score2, score3, score4, score5]
      @row.instance_variable_set(:@score_row, scores)
      expect(@row.average_score_for_row).to eq(2.25)
    end
  end
end
