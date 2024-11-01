describe Institution do
  subject do
    described_class.new(name: 'NC State University')
  end
  it 'is valid with valid a name' do
    expect(subject).to be_valid
  end

  it 'is not valid without a name' do
    subject.name = nil
    expect(subject).to_not be_valid
  end
end
