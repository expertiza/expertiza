describe QuestionnaireTypeNode do
  let(:itemnaire_type_node) { build(:itemnaire_type_node) }
  let(:itemnaire) { build(:itemnaire) }
  let(:itemnaire2) { build(:itemnaire) }
  let(:itemnaire3) { build(:itemnaire) }
  it { should belong_to(:table) }
  it { should belong_to(:node_object) }
  describe '#table' do
    it 'returns the name of the table' do
      expect(QuestionnaireTypeNode.table).to eq('tree_folders')
    end
  end
  describe '#get' do
    it 'gets nodes associated with the parent' do
      tree_folder = double('TreeFolder', id: 1)
      allow(TreeFolder).to receive(:find_by).with(name: 'Questionnaires').and_return(tree_folder)
      allow(TreeFolder).to receive(:where).with(parent_id: 1).and_return([double('FolderNode', id: 1)])
      allow(FolderNode).to receive(:find_by).with(node_object_id: 1).and_return(double('QuestionnaireNode'))
      expect(QuestionnaireTypeNode.get.length).to eq(1)
    end
  end
  describe '#get_partial_name' do
    it 'returns itemnaire_type_actions' do
      expect(itemnaire_type_node.get_partial_name).to eq('itemnaire_type_actions')
    end
  end
  describe '#get_name' do
    it 'returns the name of the associated tree folder' do
      tree_folder = double('TreeFolder', id: 1)
      allow(TreeFolder).to receive(:find).with(1).and_return(tree_folder)
      allow(tree_folder).to receive(:name).and_return('No folder')
      expect(itemnaire_type_node.get_name).to eq('No folder')
    end
  end
  describe '#get_children' do
    it 'returns the children objects' do
      arr = [itemnaire, itemnaire2, itemnaire3]
      allow(QuestionnaireNode).to receive(:get).and_return(arr)
      expect(itemnaire_type_node.get_children.first).to be(itemnaire)
    end
  end
end
