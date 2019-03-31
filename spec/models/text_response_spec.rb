describe 'TextResponse' do
  let(:tr) { TextResponse.new(id: 1, seq: 1.0, txt: 'text response text', size: 40) }

  it "is valid with valid attributes" do
    expect(tr).to be_valid
  end

  it "is invalid without valid attributes" do
    expect(TextResponse.new).not_to be_valid
  end

  describe '#edit' do
    it 'includes an input tag with size 6' do
      expect(tr.edit(1)).to match(/<input/).and match(/size="6"/)
    end
    it 'includes an input tag with size 10' do
      expect(tr.edit(2)).to match(/<input/).and match(/size="10"/)
    end
    it 'include a textarea tag with 50 cols and 1 row' do
      expect(tr.edit(0)).to match(/<textarea/).and match(/rows="1"/).and match(/cols="50"/)
    end
  end
end