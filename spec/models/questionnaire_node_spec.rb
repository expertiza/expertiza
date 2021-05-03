describe QuestionnaireNode do
	let(:questionnaire) {build (:questionnaire)}
  let(:questionnaire_node) {build (:questionnaire_node)}
  it { should belong_to(:questionnaire) }
  it { should belong_to(:node_object) }
  describe '#table' do
    it 'returns the name of the table' do
      expect(QuestionnaireNode.table).to eq('questionnaires')
    end
  end
  describe '#is_leaf' do
    it 'returns whether the node is a leaf' do
      expect(questionnaire_node.is_leaf).to eq(true)
    end
  end
  describe '#get_modified_date' do
    it 'returns when the questionnaire was last changed' do
      allow(Questionnaire).to receive(:find_by).with(id: 0).and_return(questionnaire)
      allow(questionnaire).to receive(:updated_at).and_return('2011-11-11 11:11:11')
      expect(questionnaire_node.get_modified_date).to eq('2011-11-11 11:11:11')
    end
  end
  describe '#get_creation_date' do
    it 'returns when the questionnaire was created' do
      allow(Questionnaire).to receive(:find_by).with(id: 0).and_return(questionnaire)
      allow(questionnaire).to receive(:created_at).and_return('2011-11-11 11:11:11')
      expect(questionnaire_node.get_creation_date).to eq('2011-11-11 11:11:11')
    end
  end
  describe '#get_private' do
    it 'returns whether the associated questionnaire is private' do
      allow(Questionnaire).to receive(:find_by).with(id: 0).and_return(questionnaire)
      allow(questionnaire).to receive(:private).and_return(true)
      expect(questionnaire_node.get_private).to eq(true)
    end
  end
  describe '#get_instructor_id' do
    it 'returns whether the associated instructor id with the questionnaire' do
      allow(Questionnaire).to receive(:find_by).with(id: 0).and_return(questionnaire)
      allow(questionnaire).to receive(:instructor_id).and_return(1)
      expect(questionnaire_node.get_instructor_id).to eq(1)
    end
  end
  describe '#get_name' do
    it 'returns questionnaire name' do
      allow(Questionnaire).to receive(:find_by).with(id: 0).and_return(questionnaire)
      allow(questionnaire).to receive(:name).and_return('CSC 517 Assignment 1')
      expect(questionnaire_node.get_name).to eq('CSC 517 Assignment 1')
    end
  end
end