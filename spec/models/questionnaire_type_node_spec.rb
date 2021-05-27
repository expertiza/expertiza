describe QuestionnaireTypeNode do
  it { should belong_to(:table) }
  it { should belong_to(:node_object) }
  describe '#table' do
    it 'returns the name of the table' do
      expect(QuestionnaireTypeNode.table).to eq("tree_folders")
    end
  end
  describe '#get' do
    it 'gets nodes associated with the parent' do
      tree_folder = double('TreeFolder', id: 1)
      allow(TreeFolder).to receive(:find_by).with(name: 'Questionnaires').and_return(tree_folder)
      allow(TreeFolder).to receive(:where).with(parent_id: 1).and_return([double('FolderNode', id: 1)])
      allow(FolderNode).to receive(:find_by).with(node_object_id: 1).and_return(double('QuestionnaireNode'))
      expect(QuestionnaireTypeNode.get().length).to eq(1)
    end
  end
end