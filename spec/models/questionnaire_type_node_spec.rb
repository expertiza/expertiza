describe QuestionnaireTypeNode do
  it { should belong_to(:table) }
  it { should belong_to(:node_object) }
  describe '#table' do
    it 'returns the name of the table' do
      expect(QuestionnaireTypeNode.table).to eq("tree_folders")
    end
  end
end