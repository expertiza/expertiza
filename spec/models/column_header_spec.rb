describe ColumnHeader do
  describe '#complete' do
    it 'returns the header' do
      ch = ColumnHeader.new
      ch.txt = 'Question 1'
      expect(ch.complete(1, nil)).to eq('<tr><th style="width: 15%">Question 1</th>')
    end
  end
  describe '#view_completed_item' do
    it 'returns the header' do
      ch = ColumnHeader.new
      ch.txt = 'Question 1'
      expect(ch.view_completed_item(1, nil)).to eq('<tr><th style="width: 15%">Question 1</th>')
    end
  end
end
