describe MarkupStyle do
  it 'is invalid without valid attributes' do
    expect(MarkupStyle.new).not_to be_valid
  end
  it 'is valid with valid attributes' do
    expect(MarkupStyle.new(name: 'Header for Question')).to be_valid
  end
  it 'can access name' do
    ms = MarkupStyle.new(name: 'Header for Question')
    expect(ms.name).to eq('Header for Question')
  end
end
