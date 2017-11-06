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
    VmQuestionResponseScoreCell.new nil, '#ffffff', "3"
  end
  let(:vm_q) do
    VmQuestionResponseRow.new 'This is my first question', 1, 1, 100, 1.00, [sc1, sc2, sc3]
  end
  it 'returns the question text of the vm_q' do
    expect(vm_q.questionText).to eq('This is my first question')
  end
  it 'returns the question weight of the vm_q' do
    expect(vm_q.weight).to eq(1)
  end
  it 'returns the question sequence of the vm_q' do
    expect(vm_q.question_seq).to eq(1.00)
  end
  it 'should return average score of all scores added together' do
    expect(vm_q.average_score_for_row).to eq(2)
  end
  let(:vm_q2) do
    VmQuestionResponseRow.new 'This is my second question', 2, 2, 120, 2.00, [sc1, sc2, sc4]
  end
  it 'should return average score without counting nil' do
    expect(vm_q2.average_score_for_row).to eq(1.5)
  end
  let(:vm_q3) do
    VmQuestionResponseRow.new 'This is my third question', 3, 10, 150, 3.00
  end
  it 'returns the question text of the vm_q3' do
    expect(vm_q3.questionText).to eq('This is my third question')
  end
  it 'returns the question weight of the vm_q3' do
    expect(vm_q3.weight).to eq(10)
  end
  it 'returns the question sequence of the vm_q3' do
    expect(vm_q3.question_seq).to eq(3.00)
  end
  it 'should return average score nil' do
    expect(vm_q3.average_score_for_row).to eq(nil)
  end
end