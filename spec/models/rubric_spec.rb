describe Rubric do
  it 'is not valid without a name' do
    expect(Rubric.new(name: nil, max_question_score: 100, min_question_score: 0)).to_not be_valid
  end
  it 'is valid with a name, max and min question scores' do
    expect(Rubric.new(name: 'Test Assignment Rubric', max_question_score: 100, min_question_score: 0)).to be_valid
  end
end
