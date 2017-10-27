describe VmQuestionResponseRow do
  let(:sc1) do
    VmQuestionResponseScoreCell.new 1, '#ffffff', "1"
  end

  let(:sc2) do
    VmQuestionResponseScoreCell.new 2, '#ffffff', "2"
  end

  let(:sc3) do
    VmQuestionResponseScoreCell.new 3, '#ffffff', "3"
  end

  let(:sc4) do
    VmQuestionResponseScoreCell.new 1, '#ffffff', "1"
  end

  let(:sc5) do
    VmQuestionResponseScoreCell.new nil, '#ffffff', "2"
  end

  let(:sc6) do
    VmQuestionResponseScoreCell.new 3, '#ffffff', "3"
  end

  let(:vm_q) do
    VmQuestionResponseRow.new 'This is my first question', 1, 1, 100, 1.00, [sc1, sc2, sc3]
  end

  it 'should return average score of all scores added together' do
    expect(vm_q.average_score_for_row).to eq(2)
  end

  let(:vm_q2) do
    VmQuestionResponseRow.new 'This is my first question', 1, 1, 100, 1.00, [sc4, sc5, sc6]
  end

  it 'should return average score without counting nil' do
    expect(vm_q2.average_score_for_row).to eq(2)
  end
end
