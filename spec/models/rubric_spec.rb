describe Rubric do
  it 'is valid with valid attributes' do
    expect(Rubric.new).to be_valid
  end
  it 'is invalid without the prescence of a name' do
    expect(Rubric.new(name: nil)).to_not be_valid
  end
  it 'is invalid without a numerical max question score' do
    expect(Rubric.new(max_question_score: 'Not an number')).to_not be_valid
  end
  it 'is invalid without a numerical min question score' do
    expect(Rubric.new(min_question_score: 'Not an number')).to_not be_valid
  end
  describe '#update_mapping' do
    rubric = Rubric.new()
    response = rubric.update_mapping
    expect(response).to render_template(:list)
  end
end
