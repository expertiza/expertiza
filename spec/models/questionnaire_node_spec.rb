describe QuestionnaireNode do
	let(:questionnaire) do
    build(id: 1, name: 'questionnaire', ta_id: 8, course_id: 1, private: false, min_question_score: 0, max_question_score: 5, type: 'ReviewQuestionnaire')
  end
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
end